package com.ghasaq.app.notifications.builder

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.ghasaq.app.MainActivity
import com.ghasaq.app.R
import com.ghasaq.app.notifications.models.NotificationType
import com.ghasaq.app.notifications.models.ScheduledNotification

/**
 * Builds and posts the right notification kind for a [ScheduledNotification].
 * The channel determines sound + importance — the builder only contributes
 * content, smallIcon, category and the tap intent.
 */
class NotificationDispatcher(private val context: Context) {

    fun post(n: ScheduledNotification) {
        val mgr = NotificationManagerCompat.from(context)
        val builder = NotificationCompat.Builder(context, n.channelId)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(n.title)
            // Hide Android's auto-injected timestamp ("20:25" on the right of
            // the title) — the user wants no numbers on these notifications.
            .setShowWhen(false)
            .setAutoCancel(true)
            .setOnlyAlertOnce(false)
            .setContentIntent(buildTapIntent(n))
        // Prayer/iqama/adhkar pass an empty body by design (whole message in
        // the title). Al-Kahf carries a real body — render it + expand on
        // long-press via BigTextStyle so the full hadith reference fits.
        if (n.body.isNotEmpty()) {
            builder
                .setContentText(n.body)
                .setStyle(NotificationCompat.BigTextStyle().bigText(n.body))
        }
        when (n.type) {
            NotificationType.ADHAN -> applyAdhan(builder)
            NotificationType.PRE_ADHAN, NotificationType.PRE_IQAMA -> applyReminder(builder)
            NotificationType.IQAMA -> applyIqama(builder)
            NotificationType.ADHKAR_MORNING, NotificationType.ADHKAR_EVENING -> applyAdhkar(builder)
            NotificationType.AL_KAHF -> applyAdhkar(builder)
        }
        mgr.notify(n.id, builder.build())
    }

    private fun applyAdhan(b: NotificationCompat.Builder) {
        b.setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
    }

    private fun applyReminder(b: NotificationCompat.Builder) {
        b.setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_REMINDER)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
    }

    private fun applyIqama(b: NotificationCompat.Builder) {
        b.setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
    }

    private fun applyAdhkar(b: NotificationCompat.Builder) {
        b.setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_REMINDER)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
    }

    /**
     * Tap routes to MainActivity carrying the optional payload — Flutter side
     * picks it up via the platform channel's notification-tap stream.
     */
    private fun buildTapIntent(n: ScheduledNotification): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
            n.payload?.let { putExtra(EXTRA_PAYLOAD, it) }
        }
        val flags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        return PendingIntent.getActivity(context, n.id, intent, flags)
    }

    companion object {
        const val EXTRA_PAYLOAD = "ghasaq.notif.payload"
    }
}
