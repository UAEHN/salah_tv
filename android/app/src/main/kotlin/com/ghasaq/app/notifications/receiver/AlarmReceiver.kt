package com.ghasaq.app.notifications.receiver

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.PowerManager
import android.util.Log
import com.ghasaq.app.notifications.builder.NotificationChannelsManager
import com.ghasaq.app.notifications.builder.NotificationDispatcher
import com.ghasaq.app.notifications.models.NotificationType
import com.ghasaq.app.notifications.scheduler.PendingIntentFactory
import com.ghasaq.app.notifications.store.NotificationStore
import com.ghasaq.app.notifications.store.ScheduleLog

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
            val n = store.readById(id)
            if (n == null) {
                log.record(
                    id, NotificationType.ADHAN, null, 0L,
                    success = false, error = "store_miss",
                )
                return
            }
            try {
                NotificationChannelsManager(context).ensureAll()
                NotificationDispatcher(context).post(n)
                log.record(
                    n.id, n.type, n.prayerKey, n.triggerAtMillis,
                    success = true,
                )
            } catch (e: SecurityException) {
                log.record(
                    n.id, n.type, n.prayerKey, n.triggerAtMillis,
                    success = false, error = "post_denied:${e.message}",
                )
                Log.e(TAG, "post denied id=$id", e)
            }
        } finally {
            if (wl.isHeld) wl.release()
        }
    }

    companion object {
        private const val TAG = "GhasaqAlarmReceiver"
        private const val WAKE_LOCK_TAG = "ghasaq:alarm-receiver"
        private const val WAKE_LOCK_MS = 10_000L
    }
}
