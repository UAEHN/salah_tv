package com.ghasaq.app.notifications.builder

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.media.AudioAttributes
import android.net.Uri

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
        ensureSilent(NotificationChannelIds.PRE_ADHAN, "Pre-adhan reminder")
        ensureSilent(NotificationChannelIds.IQAMA, "Iqama alert")
        ensureSilent(NotificationChannelIds.PRE_IQAMA, "Pre-iqama reminder")
        ensureSilent(NotificationChannelIds.ADHKAR, "Adhkar reminder")
        ensureSilent(NotificationChannelIds.AL_KAHF, "Friday Surah Al-Kahf reminder")
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
        ensureAdhan(
            NotificationChannelIds.customAdhanChannelId(fileName),
            Uri.parse(contentUri),
        )
    }

    private fun ensureAdhan(channelId: String, soundUri: Uri) {
        if (nm.getNotificationChannel(channelId) != null) return
        val attrs = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()
        val ch = NotificationChannel(
            channelId,
            ADHAN_NAME,
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = ADHAN_DESC
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

    companion object {
        private const val ADHAN_NAME = "Prayer times"
        private const val ADHAN_DESC = "Notifications for the five daily prayers"
    }
}
