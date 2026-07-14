package com.ghasaq.app.notifications.worker

import android.content.Context
import android.util.Log
import androidx.work.Constraints
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.NetworkType
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import java.util.concurrent.TimeUnit

/**
 * Registers/refreshes the [DailyRefreshWorker]. Idempotent — safe to call
 * from initialize, sync, boot, or alarm-fire paths. KEEP policy means
 * subsequent calls reuse the existing schedule, so we never accidentally
 * create duplicates.
 *
 * Every WorkManager access is guarded: on some OEM builds its startup
 * ContentProvider is stripped, so getInstance() throws IllegalStateException
 * ("WorkManager is not initialized properly") on first access — 87% of the
 * time in the first second of a session. The daily refresh is only a safety
 * net (AlarmManager is the primary scheduler), so a WorkManager failure must
 * degrade to alarm-only, never crash at launch.
 */
object RefreshScheduler {

    private const val WORK_NAME = "ghasaq_daily_refresh_v1"
    private const val INTERVAL_HOURS = 6L
    private const val TAG = "RefreshScheduler"

    fun ensurePeriodicWork(context: Context) {
        val constraints = Constraints.Builder()
            .setRequiredNetworkType(NetworkType.NOT_REQUIRED)
            .setRequiresBatteryNotLow(false)
            .setRequiresCharging(false)
            .setRequiresDeviceIdle(false)
            .build()

        val request = PeriodicWorkRequestBuilder<DailyRefreshWorker>(
            INTERVAL_HOURS, TimeUnit.HOURS,
        ).setConstraints(constraints).build()

        try {
            WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                WORK_NAME,
                ExistingPeriodicWorkPolicy.KEEP,
                request,
            )
        } catch (e: Exception) {
            Log.w(TAG, "WorkManager unavailable; skipping daily refresh", e)
        }
    }

    fun cancel(context: Context) {
        try {
            WorkManager.getInstance(context).cancelUniqueWork(WORK_NAME)
        } catch (e: Exception) {
            Log.w(TAG, "WorkManager unavailable; cancel skipped", e)
        }
    }
}
