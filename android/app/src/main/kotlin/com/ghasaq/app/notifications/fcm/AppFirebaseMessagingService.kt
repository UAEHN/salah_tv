package com.ghasaq.app.notifications.fcm

import android.app.PendingIntent
import android.content.Intent
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.ghasaq.app.MainActivity
import com.ghasaq.app.R
import com.ghasaq.app.notifications.builder.NotificationChannelIds
import com.ghasaq.app.notifications.builder.NotificationChannelsManager
import com.ghasaq.app.notifications.builder.NotificationDispatcher
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import kotlin.random.Random

/**
 * Receives server-pushed messages. Expects a **data-only** payload so the
 * service has full control over channel, icon, body, and tap routing in all
 * app states (foreground, background, terminated).
 *
 * Recognised data keys:
 *   - title           required
 *   - body            optional (rendered with BigTextStyle when present)
 *   - channel         optional, one of NotificationChannelIds.* — defaults to GENERAL_PUSH
 *   - payload         optional deep-link payload forwarded to MainActivity
 *                     via the same EXTRA_PAYLOAD contract used by local alarms
 *   - id              optional integer; random id is used when absent
 *
 * Token refresh is logged here; the Flutter side picks the fresh token up via
 * [FirebaseMessaging.getToken] / [FirebaseMessaging.onTokenRefresh] on next
 * boot or stream emission — no native→Flutter bridge is needed in this phase.
 */
class AppFirebaseMessagingService : FirebaseMessagingService() {

    override fun onMessageReceived(message: RemoteMessage) {
        val data = message.data
        val title = data["title"] ?: message.notification?.title ?: return
        val body = data["body"] ?: message.notification?.body.orEmpty()
        val channel = data["channel"]?.takeIf { it.isNotBlank() }
            ?: NotificationChannelIds.GENERAL_PUSH
        val payload = data["payload"]
        val id = data["id"]?.toIntOrNull() ?: Random.nextInt()

        // Defensive: in the rare case the engine never initialised on this
        // device (fresh install, user never opened the app), make sure the
        // channel exists before we post into it.
        NotificationChannelsManager(applicationContext).ensureAll()

        val builder = NotificationCompat.Builder(applicationContext, channel)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setShowWhen(false)
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setContentIntent(buildTapIntent(id, payload))
        if (body.isNotEmpty()) {
            builder
                .setContentText(body)
                .setStyle(NotificationCompat.BigTextStyle().bigText(body))
        }
        NotificationManagerCompat.from(applicationContext).notify(id, builder.build())
    }

    override fun onNewToken(token: String) {
        Log.d(TAG, "FCM token refreshed: ${token.take(12)}…")
        // Phase 3 will write the fresh token to Firestore here. For now the
        // Flutter side observes it via FirebaseMessaging.onTokenRefresh.
    }

    /**
     * Mirrors [NotificationDispatcher.buildTapIntent]: uses the same
     * EXTRA_PAYLOAD key so [MainActivity.stashTapPayload] routes FCM taps
     * through the identical Flutter pipeline as local alarm taps.
     */
    private fun buildTapIntent(id: Int, payload: String?): PendingIntent {
        val intent = Intent(applicationContext, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
            if (!payload.isNullOrEmpty()) {
                putExtra(NotificationDispatcher.EXTRA_PAYLOAD, payload)
            }
        }
        val flags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        return PendingIntent.getActivity(applicationContext, id, intent, flags)
    }

    private companion object {
        const val TAG = "AppFcm"
    }
}
