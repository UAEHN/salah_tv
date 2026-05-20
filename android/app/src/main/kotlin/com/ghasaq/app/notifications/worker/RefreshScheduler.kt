package com.ghasaq.app.notifications.worker

import android.content.Context
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
 */
object RefreshScheduler {

    private const val WORK_NAME = "ghasaq_daily_refresh_v1"
    private const val INTERVAL_HOURS = 6L

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

        WorkManager.getInstance(context).enqueueUniquePeriodicWork(
            WORK_NAME,
            ExistingPeriodicWorkPolicy.KEEP,
            request,
        )
    }

    fun cancel(context: Context) {
        WorkManager.getInstance(context).cancelUniqueWork(WORK_NAME)
    }
}
