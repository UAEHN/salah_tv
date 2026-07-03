package com.ghasaq.app

import android.Manifest
import android.app.UiModeManager
import android.content.ContentUris
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.os.PowerManager
import android.provider.MediaStore
import android.provider.Settings
import android.view.View
import android.view.WindowManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.view.WindowCompat
import com.ghasaq.app.notifications.channel.NotificationMethodChannel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {

    // Held while the runtime audio-permission dialog is open so the
    // `requestAudioPermission` channel call resolves only AFTER the user
    // decides — letting the TV browser load files immediately, with no manual
    // "retry" tap. Completed in [onRequestPermissionsResult].
    private var pendingAudioPermissionResult: MethodChannel.Result? = null

    private companion object {
        const val AUDIO_PERMISSION_REQUEST_CODE = 0xA0D1
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        WindowCompat.setDecorFitsSystemWindows(window, false)
        // Keep the display alive AND force it on. FLAG_KEEP_SCREEN_ON alone is
        // revoked by some TV boxes after hours, letting the display sleep and
        // destroying the focused window → "No focused window" ANR + a frozen
        // surface that never repaints. We re-assert these flags on every resume
        // / focus gain (see onResume / onWindowFocusChanged) so the window is
        // never torn down out from under the Flutter engine.
        keepScreenAwake()
        requestHighRefreshRate()
        // Cold-start tap: stash payload so Flutter can pull it after splash.
        intent?.let { stashTapPayload(it, isWarm = false) }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // Warm tap: app already running, dispatch immediately to Flutter.
        stashTapPayload(intent, isWarm = true)
    }

    // TV firmwares can clear FLAG_KEEP_SCREEN_ON when the system briefly takes
    // over (system overlay, OTA check, power save), which lets the display sleep
    // and tears down the focused window. Re-assert on every resume so the
    // display never sleeps out from under the running app.
    override fun onResume() {
        super.onResume()
        keepScreenAwake()
        applyImmersiveMode()
    }

    private fun stashTapPayload(intent: Intent, isWarm: Boolean) {
        val payload = intent.getStringExtra("ghasaq.notif.payload") ?: return
        if (payload.isEmpty()) return
        NotificationMethodChannel.routeTap(payload, isWarm)
    }

    // Re-apply immersive mode whenever the window regains focus.
    // On TV boxes the system can briefly steal focus (system overlay, OTA
    // notification, etc.), which makes Android report "No focused window"
    // for any subsequent input event and triggers an ANR after 5 seconds.
    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) {
            keepScreenAwake()
            applyImmersiveMode()
        }
    }

    /**
     * Forces the display on and keeps it from sleeping / being torn down.
     * [FLAG_TURN_SCREEN_ON] + [setShowWhenLocked]/[setTurnScreenOn] (API 27+)
     * make the window re-acquire the display even if the system put it to
     * sleep, which is what destroys the focused window on stubborn TV boxes.
     */
    private fun keepScreenAwake() {
        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON,
        )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        }
    }

    private fun applyImmersiveMode() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.setDecorFitsSystemWindows(false)
            window.insetsController?.let { ic ->
                ic.hide(
                    android.view.WindowInsets.Type.statusBars() or
                    android.view.WindowInsets.Type.navigationBars()
                )
                ic.systemBarsBehavior =
                    android.view.WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            }
        } else {
            @Suppress("DEPRECATION")
            window.decorView.systemUiVisibility = (
                View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                or View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                or View.SYSTEM_UI_FLAG_FULLSCREEN
            )
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Register the native notification engine channel before any other
        // platform channel so that early-init Flutter code can call into it
        // without races.
        NotificationMethodChannel(
            applicationContext,
            flutterEngine.dartExecutor.binaryMessenger,
        )
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "ghasaq/platform",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isTV" -> result.success(isTvDevice())
                "openUrl" -> {
                    val url = call.argument<String>("url")
                    if (url != null) {
                        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(true)
                    } else {
                        result.error("INVALID_URL", "URL is null", null)
                    }
                }
                "publishAdhanSound" -> handlePublishAdhanSound(call, result)
                "unpublishAdhanSound" -> handleUnpublishAdhanSound(call, result)
                "hasAudioPermission" -> result.success(hasAudioPermission())
                "requestAudioPermission" -> {
                    if (hasAudioPermission()) {
                        result.success(true)
                    } else {
                        // Defer until onRequestPermissionsResult so Dart can
                        // re-check + load the list right after the user grants,
                        // instead of waiting for a manual refresh tap.
                        pendingAudioPermissionResult?.success(false)
                        pendingAudioPermissionResult = result
                        requestAudioPermission()
                    }
                }
                "listAudioFolders" -> result.success(listAudioFolders())
                "listAudioInFolder" -> {
                    val bucketId = call.argument<String>("bucketId")
                    if (bucketId == null) {
                        result.error("INVALID_ARGS", "bucketId null", null)
                    } else {
                        result.success(listAudioInFolder(bucketId))
                    }
                }
                "copyUriToTemp" -> handleCopyUriToTemp(call, result)
                "hasSystemFilePicker" -> result.success(hasSystemFilePicker())
                "getAudioState" -> {
                    val am = getSystemService(AUDIO_SERVICE) as android.media.AudioManager
                    val stream = android.media.AudioManager.STREAM_MUSIC
                    val volume = am.getStreamVolume(stream)
                    val muted = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        am.isStreamMute(stream)
                    } else {
                        false
                    }
                    result.success(
                        mapOf(
                            "volume" to volume,
                            "maxVolume" to am.getStreamMaxVolume(stream),
                            "muted" to (muted || volume <= 0),
                        ),
                    )
                }
                "ensureMediaAudible" -> {
                    val am = getSystemService(AUDIO_SERVICE) as android.media.AudioManager
                    val stream = android.media.AudioManager.STREAM_MUSIC
                    val before = am.getStreamVolume(stream)
                    val max = am.getStreamMaxVolume(stream)
                    val wasMuted = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        am.isStreamMute(stream)
                    } else {
                        false
                    }
                    if (before <= 0 || wasMuted) {
                        val target = kotlin.math.max(1, max / 3)
                        am.setStreamVolume(stream, target, 0)
                    }
                    val after = am.getStreamVolume(stream)
                    val mutedAfter = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        am.isStreamMute(stream)
                    } else {
                        false
                    }
                    result.success(
                        mapOf(
                            "beforeVolume" to before,
                            "afterVolume" to after,
                            "maxVolume" to max,
                            "wasMuted" to (wasMuted || before <= 0),
                            "muted" to (mutedAfter || after <= 0),
                        ),
                    )
                }
                "isBatteryOptimizationIgnored" -> {
                    val pm = getSystemService(POWER_SERVICE) as PowerManager
                    result.success(pm.isIgnoringBatteryOptimizations(packageName))
                }
                "requestIgnoreBatteryOptimization" -> {
                    val intent = Intent(
                        Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                        Uri.parse("package:$packageName"),
                    )
                    startActivity(intent)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    /**
     * Registers an imported adhan audio file with MediaStore as a system
     * notification sound (`IS_NOTIFICATION=1`). The returned content URI is
     * globally readable by the notification subsystem on every Android
     * version / OEM without runtime URI permission grants — the canonical
     * way to ship a user-picked sound to notification channels.
     */
    private fun handlePublishAdhanSound(
        call: io.flutter.plugin.common.MethodCall,
        result: MethodChannel.Result,
    ) {
        val path = call.argument<String>("path")
        val displayName = call.argument<String>("displayName")
        val mimeType = call.argument<String>("mimeType") ?: "audio/mpeg"
        if (path == null || displayName == null) {
            result.error("INVALID_ARGS", "path/displayName null", null)
            return
        }
        try {
            val uri = publishToMediaStore(File(path), displayName, mimeType)
            result.success(uri.toString())
        } catch (e: Exception) {
            result.error("PUBLISH_FAILED", e.message, null)
        }
    }

    private fun publishToMediaStore(
        src: File,
        displayName: String,
        mimeType: String,
    ): Uri {
        val resolver = applicationContext.contentResolver
        val collection = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
        val values = ContentValues().apply {
            put(MediaStore.Audio.Media.DISPLAY_NAME, displayName)
            put(MediaStore.Audio.Media.MIME_TYPE, mimeType)
            put(MediaStore.Audio.Media.IS_NOTIFICATION, 1)
            put(MediaStore.Audio.Media.IS_MUSIC, 0)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put(
                    MediaStore.Audio.Media.RELATIVE_PATH,
                    "${Environment.DIRECTORY_NOTIFICATIONS}/Ghasaq",
                )
                put(MediaStore.Audio.Media.IS_PENDING, 1)
            }
        }
        val uri = resolver.insert(collection, values)
            ?: throw IllegalStateException("MediaStore.insert returned null")
        resolver.openOutputStream(uri)?.use { out ->
            src.inputStream().use { it.copyTo(out) }
        } ?: throw IllegalStateException("Cannot open output stream for $uri")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val done = ContentValues().apply {
                put(MediaStore.Audio.Media.IS_PENDING, 0)
            }
            resolver.update(uri, done, null, null)
        }
        return uri
    }

    private fun handleUnpublishAdhanSound(
        call: io.flutter.plugin.common.MethodCall,
        result: MethodChannel.Result,
    ) {
        val uriStr = call.argument<String>("uri")
        if (uriStr == null) {
            result.error("INVALID_ARGS", "uri null", null)
            return
        }
        try {
            val deleted = applicationContext.contentResolver.delete(
                Uri.parse(uriStr),
                null,
                null,
            )
            result.success(deleted > 0)
        } catch (e: Exception) {
            result.error("UNPUBLISH_FAILED", e.message, null)
        }
    }

    // ── TV custom-sound MediaStore audio browser (Play-compliant) ───────────

    /** The minimum-scope read permission for audio on this OS version. */
    private val audioPermission: String
        get() = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            Manifest.permission.READ_MEDIA_AUDIO
        } else {
            Manifest.permission.READ_EXTERNAL_STORAGE
        }

    private fun hasAudioPermission(): Boolean =
        ContextCompat.checkSelfPermission(this, audioPermission) ==
            PackageManager.PERMISSION_GRANTED

    /** Standard runtime permission dialog. The result is delivered to Dart in
     *  [onRequestPermissionsResult] so the browser loads files without a
     *  manual retry. */
    private fun requestAudioPermission() {
        ActivityCompat.requestPermissions(
            this,
            arrayOf(audioPermission),
            AUDIO_PERMISSION_REQUEST_CODE,
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray,
    ) {
        // Forward to Flutter plugins first (file_picker etc. rely on this).
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != AUDIO_PERMISSION_REQUEST_CODE) return
        val granted = grantResults.isNotEmpty() &&
            grantResults[0] == PackageManager.PERMISSION_GRANTED
        pendingAudioPermissionResult?.success(granted)
        pendingAudioPermissionResult = null
    }

    /** Audio collections to query across every mounted volume (incl. USB). */
    private fun audioCollections(): List<Uri> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            return MediaStore.getExternalVolumeNames(this)
                .map { MediaStore.Audio.Media.getContentUri(it) }
        }
        return listOf(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI)
    }

    /** Distinct folders (MediaStore buckets) that contain audio. */
    private fun listAudioFolders(): List<Map<String, Any>> {
        val folders = LinkedHashMap<String, Map<String, Any>>()
        val proj = arrayOf(
            MediaStore.Audio.Media.BUCKET_ID,
            MediaStore.Audio.Media.BUCKET_DISPLAY_NAME,
        )
        for (col in audioCollections()) {
            try {
                contentResolver.query(
                    col,
                    proj,
                    null,
                    null,
                    "${MediaStore.Audio.Media.BUCKET_DISPLAY_NAME} ASC",
                )?.use { c ->
                    val idIdx = c.getColumnIndexOrThrow(MediaStore.Audio.Media.BUCKET_ID)
                    val nameIdx =
                        c.getColumnIndexOrThrow(MediaStore.Audio.Media.BUCKET_DISPLAY_NAME)
                    while (c.moveToNext()) {
                        val id = c.getString(idIdx) ?: continue
                        val name = c.getString(nameIdx) ?: id
                        folders.getOrPut(id) { mapOf("id" to id, "name" to name) }
                    }
                }
            } catch (_: Exception) {
                // Volume vanished mid-query (USB removed) — skip it.
            }
        }
        return folders.values.toList()
    }

    /** Audio files in [bucketId], filtered to importable extensions. */
    private fun listAudioInFolder(bucketId: String): List<Map<String, Any>> {
        val out = mutableListOf<Map<String, Any>>()
        val proj = arrayOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.DISPLAY_NAME,
        )
        val sel = "${MediaStore.Audio.Media.BUCKET_ID} = ?"
        val allowed = setOf("mp3", "wav", "ogg", "m4a")
        for (col in audioCollections()) {
            try {
                contentResolver.query(
                    col,
                    proj,
                    sel,
                    arrayOf(bucketId),
                    "${MediaStore.Audio.Media.DISPLAY_NAME} ASC",
                )?.use { c ->
                    val idIdx = c.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
                    val nameIdx =
                        c.getColumnIndexOrThrow(MediaStore.Audio.Media.DISPLAY_NAME)
                    while (c.moveToNext()) {
                        val name = c.getString(nameIdx) ?: continue
                        val ext = name.substringAfterLast('.', "").lowercase()
                        if (ext !in allowed) continue
                        val uri = ContentUris.withAppendedId(col, c.getLong(idIdx))
                        out.add(mapOf("uri" to uri.toString(), "name" to name))
                    }
                }
            } catch (_: Exception) {
                // Volume vanished mid-query (USB removed) — skip it.
            }
        }
        return out
    }

    /**
     * Whether a system document picker (SAF) can handle audio selection. Many
     * TV boxes (e.g. Mi TV) ship no DocumentsUI, so the SAF fallback button is
     * hidden when this is false to avoid a dead "no app can do this" message.
     */
    private fun hasSystemFilePicker(): Boolean {
        val intent = Intent(Intent.ACTION_GET_CONTENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "audio/*"
        }
        return intent.resolveActivity(packageManager) != null
    }

    /**
     * Copies a picked `content://` audio file into cacheDir and returns the
     * temp path. The existing import use-case then copies it into the app's
     * `custom_adhans/` dir, so the browser never needs raw filesystem access.
     */
    private fun handleCopyUriToTemp(
        call: io.flutter.plugin.common.MethodCall,
        result: MethodChannel.Result,
    ) {
        val uriStr = call.argument<String>("uri")
        val displayName = call.argument<String>("displayName") ?: "import.mp3"
        if (uriStr == null) {
            result.error("INVALID_ARGS", "uri null", null)
            return
        }
        try {
            val safe = displayName.replace(Regex("[^A-Za-z0-9._-]"), "_")
            val dst = File(cacheDir, "import_${System.currentTimeMillis()}_$safe")
            contentResolver.openInputStream(Uri.parse(uriStr))?.use { input ->
                dst.outputStream().use { input.copyTo(it) }
            } ?: throw IllegalStateException("openInputStream returned null")
            result.success(dst.absolutePath)
        } catch (e: Exception) {
            result.error("COPY_FAILED", e.message, null)
        }
    }

    /**
     * Requests the highest refresh rate the display supports (90/120/144Hz).
     * Android keeps the display at 60Hz by default unless the app explicitly
     * requests a higher mode via preferredDisplayModeId.
     */
    private fun requestHighRefreshRate() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return

        val display = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            display
        } else {
            @Suppress("DEPRECATION")
            windowManager.defaultDisplay
        }

        val bestMode = display?.supportedModes
            ?.maxByOrNull { it.refreshRate }
            ?: return

        window.attributes = window.attributes.apply {
            preferredDisplayModeId = bestMode.modeId
        }
    }

    private fun isTvDevice(): Boolean {
        val uiModeManager = getSystemService(Context.UI_MODE_SERVICE) as? UiModeManager
        val currentMode = resources.configuration.uiMode and Configuration.UI_MODE_TYPE_MASK
        return currentMode == Configuration.UI_MODE_TYPE_TELEVISION ||
            uiModeManager?.currentModeType == Configuration.UI_MODE_TYPE_TELEVISION
    }
}
