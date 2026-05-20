package com.ghasaq.app.notifications.scheduler

import android.app.AlarmManager
import android.content.Context
import android.os.Build
import android.util.Log
import com.ghasaq.app.notifications.models.ScheduledNotification

/**
 * Thin wrapper around AlarmManager. Picks the strongest API the platform +
 * permissions allow:
 *
 *  - API 31+ with USE_EXACT_ALARM granted: setExactAndAllowWhileIdle
 *  - API 31+ without permission: setAndAllowWhileIdle (inexact, ~9 min slop)
 *  - API < 31: setExactAndAllowWhileIdle (no permission gate)
 *
 * Doze behaviour: even with exact + allow-while-idle, the OEM may delay
 * alarms when the app is not battery-optimization-exempt. This scheduler
 * does what it can; the foreground service + WorkManager safety net carry
 * the rest.
 */
class AlarmScheduler(private val context: Context) {

    private val alarmManager: AlarmManager =
        context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

    fun schedule(n: ScheduledNotification) {
        val pi = PendingIntentFactory.forAlarm(context, n.id)
        val triggerAt = n.triggerAtMillis
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && !canScheduleExact()) {
                // Fall back to inexact alarm; logs so the health screen surfaces it.
                alarmManager.setAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP, triggerAt, pi,
                )
                Log.w(TAG, "Inexact alarm for id=${n.id} (no exact-alarm permission)")
            } else {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP, triggerAt, pi,
                )
            }
        } catch (e: SecurityException) {
            Log.e(TAG, "schedule id=${n.id} denied by system", e)
        }
    }

    fun scheduleAll(notifications: List<ScheduledNotification>) {
        val now = System.currentTimeMillis()
        notifications.asSequence()
            .filter { it.triggerAtMillis > now }
            .forEach(::schedule)
    }

    fun cancel(id: Int) {
        val pi = PendingIntentFactory.cancellationIntent(context, id)
        alarmManager.cancel(pi)
        pi.cancel()
    }

    fun cancelAll(ids: List<Int>) = ids.forEach(::cancel)

    fun canScheduleExact(): Boolean = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        alarmManager.canScheduleExactAlarms()
    } else {
        true
    }

    companion object {
        private const val TAG = "GhasaqAlarmScheduler"
    }
}
