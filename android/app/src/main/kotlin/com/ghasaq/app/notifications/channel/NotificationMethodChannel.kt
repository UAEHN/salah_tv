package com.ghasaq.app.notifications.channel

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import com.ghasaq.app.notifications.engine.PrayerAlarmEngine
import com.ghasaq.app.notifications.oem.OemKillerHelper
import com.ghasaq.app.notifications.permissions.PermissionGate
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

/**
 * Wires the Flutter side ([NativeNotificationEngine]) to [PrayerAlarmEngine].
 * Validation, parsing, and side-effects are handled in the engine — this
 * class only routes calls and serialises results back to JSON-compatible
 * primitives accepted by the standard MethodChannel codec.
 *
 * Method contract is documented in
 * lib/features/notifications/data/native_notification_engine.dart.
 */
class NotificationMethodChannel(
    private val context: Context,
    binaryMessenger: BinaryMessenger,
) {

    private val channel = MethodChannel(binaryMessenger, CHANNEL_NAME)
    private val engine = PrayerAlarmEngine(context.applicationContext)

    init {
        channel.setMethodCallHandler { call, result -> dispatch(call, result) }
        instance = this
    }

    /** Buffered cold-start payload — Flutter pulls it after splash. */
    private var pendingPayload: String? = null

    /** Called by MainActivity when a notification tap routes a payload to us. */
    fun onTap(payload: String, isWarm: Boolean) {
        if (isWarm) {
            channel.invokeMethod("onTap", payload)
        } else {
            pendingPayload = payload
        }
    }

    private fun dispatch(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "initialize" -> result.success(engine.initialize())
                "sync" -> {
                    val json = (call.arguments as? String)?.let { JSONObject(it) }
                    if (json == null) {
                        result.error("BAD_ARGS", "sync expects a JSON string", null)
                        return
                    }
                    result.success(engine.sync(json))
                }
                "cancelAll" -> {
                    engine.cancelAll()
                    result.success(null)
                }
                "runTest" -> result.success(engine.runTest())
                "consumePendingTapPayload" -> {
                    val p = pendingPayload
                    pendingPayload = null
                    result.success(p)
                }
                "getHealth" -> {
                    val perms = PermissionGate.snapshot(context)
                    val payload = JSONObject().apply {
                        perms.forEach { (k, v) -> put(k, v) }
                        put("scheduleLog", engine.readScheduleLog())
                        put("oem", OemKillerHelper.snapshot(context))
                    }
                    result.success(payload.toString())
                }
                "openOemAutostart" -> result.success(OemKillerHelper.openAutostart(context))
                "openExactAlarmSettings" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        val i = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM)
                            .setData(Uri.parse("package:${context.packageName}"))
                            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        context.startActivity(i)
                    }
                    result.success(true)
                }
                "openNotificationSettings" -> {
                    val i = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                        .putExtra(Settings.EXTRA_APP_PACKAGE, context.packageName)
                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    context.startActivity(i)
                    result.success(true)
                }
                "requestPostNotifications" -> {
                    // Only API 33+ exposes the runtime POST_NOTIFICATIONS dialog.
                    // Below that, notifications are granted by default.
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        val i = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                            .putExtra(Settings.EXTRA_APP_PACKAGE, context.packageName)
                            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        context.startActivity(i)
                    }
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            result.error("ENGINE_ERROR", e.message, null)
        }
    }

    companion object {
        const val CHANNEL_NAME = "ghasaq/notifications"

        /** Set during init so [MainActivity] can route tap payloads. */
        private var instance: NotificationMethodChannel? = null

        fun routeTap(payload: String, isWarm: Boolean) {
            instance?.onTap(payload, isWarm)
        }
    }
}
