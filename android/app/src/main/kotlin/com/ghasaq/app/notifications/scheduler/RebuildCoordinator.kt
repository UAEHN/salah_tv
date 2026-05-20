package com.ghasaq.app.notifications.scheduler

import android.content.Context
import android.util.Log
import com.ghasaq.app.notifications.builder.NotificationChannelsManager
import com.ghasaq.app.notifications.store.NotificationStore

/**
 * Single entry-point that re-arms every persisted notification with
 * AlarmManager. Used by:
 *
 *  - [com.ghasaq.app.notifications.receiver.BootReceiver] after device reboot
 *  - [com.ghasaq.app.notifications.worker.DailyRefreshWorker] on the 6h cycle
 *  - The MethodChannel sync flow after writing fresh data to the store
 *
 * Idempotent: cancelling and re-scheduling each id is the cheapest way to
 * keep AlarmManager's view in sync with the store. Past-due notifications
 * are skipped automatically by [AlarmScheduler.scheduleAll].
 */
object RebuildCoordinator {

    fun rebuildAll(context: Context): Int {
        return try {
            NotificationChannelsManager(context).ensureAll()
            val store = NotificationStore(context)
            val notifications = store.readAll()
            if (notifications.isEmpty()) return 0
            val scheduler = AlarmScheduler(context)
            scheduler.cancelAll(notifications.map { it.id })
            scheduler.scheduleAll(notifications)
            val now = System.currentTimeMillis()
            notifications.count { it.triggerAtMillis > now }
        } catch (e: Exception) {
            Log.e(TAG, "rebuild failed", e)
            0
        }
    }

    private const val TAG = "GhasaqRebuild"
}
