package com.ghasaq.app.notifications.worker

import android.content.Context
import android.util.Log
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.ghasaq.app.notifications.scheduler.RebuildCoordinator
import com.ghasaq.app.notifications.store.NotificationStore

/**
 * WorkManager periodic worker — second line of defence (after AlarmManager).
 *
 * Doze deep-sleep on aggressive OEMs can drop registered alarms after the
 * device sits idle for hours. This worker runs every 6 hours (subject to
 * WorkManager's batching) and rebuilds every alarm from the persisted
 * store. Cheap when nothing has changed (~50ms), bulletproof when something
 * has.
 */
class DailyRefreshWorker(
    context: Context,
    params: WorkerParameters,
) : CoroutineWorker(context, params) {

    override suspend fun doWork(): Result {
        return try {
            val ctx = applicationContext
            val store = NotificationStore(ctx)
            val lastRefresh = store.lastRefreshMillis()
            val rebuilt = RebuildCoordinator.rebuildAll(ctx)
            Log.i(TAG, "rebuilt=$rebuilt lastRefreshAgeMs=${
                System.currentTimeMillis() - lastRefresh
            }")
            Result.success()
        } catch (e: Exception) {
            Log.e(TAG, "worker failed", e)
            Result.retry()
        }
    }

    companion object {
        private const val TAG = "GhasaqDailyRefresh"
    }
}
