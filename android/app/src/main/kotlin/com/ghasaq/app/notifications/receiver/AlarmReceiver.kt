package com.ghasaq.app.notifications.receiver

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.PowerManager
import android.util.Log
import com.ghasaq.app.notifications.builder.NotificationChannelsManager
import com.ghasaq.app.notifications.builder.NotificationDispatcher
import com.ghasaq.app.notifications.models.NotificationType
import com.ghasaq.app.notifications.scheduler.PendingIntentFactory
import com.ghasaq.app.notifications.store.NativeDiagnostics
import com.ghasaq.app.notifications.store.NotificationStore
import com.ghasaq.app.notifications.store.ScheduleLog
import org.json.JSONObject

/**
 * Fires when AlarmManager triggers a scheduled notification. Critical
 * invariants:
 *
 *  1. Acquires a partial wake lock for at most [WAKE_LOCK_MS] ms with a
 *     try/finally so the device cannot be held awake on a faulty path.
 *  2. Reads the notification spec from [NotificationStore] — never trusts
 *     the intent extras for content (the intent is just a routing signal).
 *  3. Records every firing in [ScheduleLog] (success or failure) so the
 *     health screen surfaces real-world reliability.
 *  4. Re-arms the next occurrence of this notification type via
 *     [com.ghasaq.app.notifications.scheduler.AlarmScheduler] in Commit 3
 *     (currently the daily refresh worker carries the long horizon).
 */
class AlarmReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        val wl = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, WAKE_LOCK_TAG)
        wl.setReferenceCounted(false)
        wl.acquire(WAKE_LOCK_MS)
        try {
            val id = intent.getIntExtra(PendingIntentFactory.EXTRA_ID, -1)
            if (id < 0) return
            val store = NotificationStore(context)
            val log = ScheduleLog(context)
            val diag = NativeDiagnostics(context)
            val n = store.readById(id)
            if (n == null) {
                log.record(
                    id, NotificationType.ADHAN, null, 0L,
                    success = false, error = "store_miss",
                )
                diag.record("ERROR", "alarm_fired_store_miss", JSONObject().apply {
                    put("id", id)
                })
                return
            }
            try {
                diag.record("INFO", "alarm_fired", JSONObject().apply {
                    put("id", n.id)
                    put("type", n.type.key)
                    put("prayerKey", n.prayerKey)
                    put("scheduledFor", n.triggerAtMillis)
                    put("latencyMs", System.currentTimeMillis() - n.triggerAtMillis)
                    put("adhanFinalState", "FIRED")
                    put("stage", "alarm_receiver")
                })
                NotificationChannelsManager(context).ensureAll()
                recordChannelState(context, diag, n)
                NotificationDispatcher(context).post(n)
                diag.record("INFO", "notification_shown", JSONObject().apply {
                    put("id", n.id)
                    put("type", n.type.key)
                    put("prayerKey", n.prayerKey)
                    put("channelId", n.channelId)
                    put("adhanFinalState", "NOTIFICATION_SHOWN")
                    put("stage", "notification_post")
                })
                log.record(
                    n.id, n.type, n.prayerKey, n.triggerAtMillis,
                    success = true,
                )
            } catch (e: SecurityException) {
                log.record(
                    n.id, n.type, n.prayerKey, n.triggerAtMillis,
                    success = false, error = "post_denied:${e.message}",
                )
                diag.record("ERROR", "notification_post_denied", JSONObject().apply {
                    put("id", n.id)
                    put("type", n.type.key)
                    put("prayerKey", n.prayerKey)
                    put("adhanFinalState", "FAILED")
                    put("stage", "notification_post")
                    put("error", e.message)
                })
                Log.e(TAG, "post denied id=$id", e)
            } catch (e: Exception) {
                log.record(
                    n.id, n.type, n.prayerKey, n.triggerAtMillis,
                    success = false, error = "post_failed:${e.message}",
                )
                diag.record("ERROR", "notification_post_failed", JSONObject().apply {
                    put("id", n.id)
                    put("type", n.type.key)
                    put("prayerKey", n.prayerKey)
                    put("adhanFinalState", "FAILED")
                    put("stage", "notification_post")
                    put("error", e.message)
                })
                Log.e(TAG, "post failed id=$id", e)
            }
        } finally {
            if (wl.isHeld) wl.release()
        }
    }

    private fun recordChannelState(
        context: Context,
        diag: NativeDiagnostics,
        n: com.ghasaq.app.notifications.models.ScheduledNotification,
    ) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channel = nm.getNotificationChannel(n.channelId) ?: return
        if (channel.importance == NotificationManager.IMPORTANCE_NONE) {
            diag.record("ERROR", "channel_blocked", JSONObject().apply {
                put("id", n.id)
                put("type", n.type.key)
                put("prayerKey", n.prayerKey)
                put("channelId", n.channelId)
                put("adhanFinalState", "FAILED")
                put("stage", "channel_state")
            })
            if (n.type == NotificationType.ADHAN) {
                diag.record("ERROR", "alarm_fired_without_play", JSONObject().apply {
                    put("id", n.id)
                    put("prayerKey", n.prayerKey)
                    put("channelId", n.channelId)
                    put("adhanFinalState", "FAILED")
                    put("stage", "channel_state")
                    put("reason", "channel_blocked")
                })
            }
        }
        if (n.type == NotificationType.ADHAN && channel.sound == null) {
            diag.record("WARNING", "silent_mode", JSONObject().apply {
                put("id", n.id)
                put("prayerKey", n.prayerKey)
                put("channelId", n.channelId)
                put("adhanFinalState", "SILENT_VISUAL_ONLY")
                put("stage", "channel_state")
                put("reason", "channel_sound_null")
            })
            diag.record("WARNING", "alarm_fired_without_play", JSONObject().apply {
                put("id", n.id)
                put("prayerKey", n.prayerKey)
                put("channelId", n.channelId)
                put("adhanFinalState", "SILENT_VISUAL_ONLY")
                put("stage", "channel_state")
                put("reason", "channel_sound_null")
            })
        }
    }

    companion object {
        private const val TAG = "GhasaqAlarmReceiver"
        private const val WAKE_LOCK_TAG = "ghasaq:alarm-receiver"
        private const val WAKE_LOCK_MS = 10_000L
    }
}
