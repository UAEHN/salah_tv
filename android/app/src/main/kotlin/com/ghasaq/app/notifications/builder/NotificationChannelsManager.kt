package com.ghasaq.app.notifications.builder

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import org.json.JSONArray
import org.json.JSONObject

/**
 * Creates every notification channel the engine ever uses, idempotently.
 * Safe to call from initialize, sync, boot, or worker — Android dedupes
 * by id and a no-op call costs ~1ms.
 *
 * Channel IDs match the legacy Dart implementation exactly (see
 * [NotificationChannelIds]) so users carry over per-channel preferences.
 */
class NotificationChannelsManager(private val context: Context) {

    private val nm: NotificationManager =
        context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    fun ensureAll() {
        ensureBuiltInAdhans()
        ensureBuiltInIqama()
        ensureSilent(NotificationChannelIds.PRE_ADHAN, "Pre-adhan reminder")
        ensureSilent(NotificationChannelIds.IQAMA, "Iqama alert")
        ensureSilent(NotificationChannelIds.PRE_IQAMA, "Pre-iqama reminder")
        ensureSilent(NotificationChannelIds.ADHKAR, "Adhkar reminder")
        ensureSilent(NotificationChannelIds.AL_KAHF, "Friday Surah Al-Kahf reminder")
        ensureSilent(NotificationChannelIds.GENERAL_PUSH, "General announcements")
    }

    private fun ensureBuiltInAdhans() {
        NotificationChannelIds.builtInAdhans.forEach { (_, raw) ->
            val resId = context.resources.getIdentifier(raw, "raw", context.packageName)
            if (resId == 0) return@forEach
            val uri = Uri.parse("android.resource://${context.packageName}/$resId")
            ensureAdhan(NotificationChannelIds.adhanChannelId(raw), uri)
        }
    }

    /** Creates a custom-adhan channel for a SAF-imported file URI. */
    fun ensureCustomAdhan(fileName: String, contentUri: String) {
        ensureSounded(
            NotificationChannelIds.customAdhanChannelId(fileName),
            ADHAN_NAME, ADHAN_DESC, Uri.parse(contentUri),
        )
    }

    /** Default iqama channel carrying the bundled `res/raw/iqama.mp3` sound. */
    private fun ensureBuiltInIqama() {
        val resId = context.resources.getIdentifier(
            NotificationChannelIds.IQAMA_RAW, "raw", context.packageName,
        )
        if (resId == 0) return
        val uri = Uri.parse("android.resource://${context.packageName}/$resId")
        ensureSounded(NotificationChannelIds.IQAMA_V2, IQAMA_NAME, IQAMA_DESC, uri)
    }

    /** Creates a custom-iqama channel for a SAF-imported file URI. */
    fun ensureCustomIqama(fileName: String, contentUri: String) {
        ensureSounded(
            NotificationChannelIds.customIqamaChannelId(fileName),
            IQAMA_NAME, IQAMA_DESC, Uri.parse(contentUri),
        )
    }

    private fun ensureAdhan(channelId: String, soundUri: Uri) =
        ensureSounded(channelId, ADHAN_NAME, ADHAN_DESC, soundUri)

    /**
     * Creates a high-importance channel with an explicit sound. Sound is set
     * once at creation — Android makes it immutable afterward, which is why
     * upgrading a silent channel means minting a new id (see IQAMA_V2).
     */
    private fun ensureSounded(
        channelId: String,
        name: String,
        desc: String,
        soundUri: Uri,
    ) {
        if (nm.getNotificationChannel(channelId) != null) return
        val attrs = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()
        val ch = NotificationChannel(
            channelId,
            name,
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = desc
            setSound(soundUri, attrs)
            enableVibration(true)
            setShowBadge(true)
        }
        nm.createNotificationChannel(ch)
    }

    private fun ensureSilent(channelId: String, name: String) {
        if (nm.getNotificationChannel(channelId) != null) return
        val ch = NotificationChannel(
            channelId, name, NotificationManager.IMPORTANCE_HIGH,
        ).apply { enableVibration(true) }
        nm.createNotificationChannel(ch)
    }

    fun snapshot(): JSONArray {
        val arr = JSONArray()
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return arr
        val ids = mutableListOf(
            PRE_ADHAN_ID,
            IQAMA_ID,
            IQAMA_V2_ID,
            PRE_IQAMA_ID,
            ADHKAR_ID,
            AL_KAHF_ID,
            GENERAL_PUSH_ID,
        )
        NotificationChannelIds.builtInAdhans.forEach { (_, raw) ->
            ids.add(NotificationChannelIds.adhanChannelId(raw))
        }
        nm.notificationChannels
            .filter {
                it.id.startsWith(NotificationChannelIds.ADHAN_CUSTOM_PREFIX) ||
                    it.id.startsWith(NotificationChannelIds.IQAMA_CUSTOM_PREFIX)
            }
            .forEach { ids.add(it.id) }
        ids.distinct().forEach { id ->
            val ch = nm.getNotificationChannel(id)
            arr.put(JSONObject().apply {
                put("id", id)
                put("exists", ch != null)
                if (ch != null) {
                    put("importance", ch.importance)
                    put("blocked", ch.importance == NotificationManager.IMPORTANCE_NONE)
                    put("sound", ch.sound?.toString() ?: JSONObject.NULL)
                    put("shouldVibrate", ch.shouldVibrate())
                    put("canBypassDnd", ch.canBypassDnd())
                }
            })
        }
        return arr
    }

    companion object {
        private const val ADHAN_NAME = "Prayer times"
        private const val ADHAN_DESC = "Notifications for the five daily prayers"
        private const val IQAMA_NAME = "Iqama"
        private const val IQAMA_DESC = "Sound when it is time for the iqama"
        private const val PRE_ADHAN_ID = NotificationChannelIds.PRE_ADHAN
        private const val IQAMA_ID = NotificationChannelIds.IQAMA
        private const val IQAMA_V2_ID = NotificationChannelIds.IQAMA_V2
        private const val PRE_IQAMA_ID = NotificationChannelIds.PRE_IQAMA
        private const val ADHKAR_ID = NotificationChannelIds.ADHKAR
        private const val AL_KAHF_ID = NotificationChannelIds.AL_KAHF
        private const val GENERAL_PUSH_ID = NotificationChannelIds.GENERAL_PUSH
    }
}
