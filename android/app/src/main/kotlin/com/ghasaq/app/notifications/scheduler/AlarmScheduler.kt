package com.ghasaq.app.notifications.scheduler

import android.app.AlarmManager
import android.content.Context
import android.os.Build
import android.util.Log
import com.ghasaq.app.notifications.models.ScheduledNotification
import com.ghasaq.app.notifications.store.NativeDiagnostics
import org.json.JSONObject

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
    private val diagnostics = NativeDiagnostics(context)

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
                diagnostics.record("WARNING", "alarm_scheduled_inexact", JSONObject().apply {
                    put("id", n.id)
                    put("type", n.type.key)
                    put("prayerKey", n.prayerKey)
                    put("triggerAtMillis", triggerAt)
                    put("adhanFinalState", "SCHEDULED")
                    put("stage", "alarm_scheduled_inexact")
                })
            } else {
                // setAlarmClock is the strongest primitive: Android treats it as a
                // user alarm, so it fires at the exact time even in DEEP Doze and is
                // exempt from the 9-minute rate limiting that setExactAndAllowWhileIdle
                // is subject to — and it pulls the app fully out of idle (longer, higher
                // priority wake) so post-fire adhan/notification work isn't deferred.
                // On entry / "Go" devices (e.g. Redmi A3) aggressive idle was delaying
                // adhan ~5 min; setAlarmClock also needs no exact-alarm permission.
                alarmManager.setAlarmClock(
                    AlarmManager.AlarmClockInfo(triggerAt, null),
                    pi,
                )
                diagnostics.record("INFO", "alarm_scheduled_exact", JSONObject().apply {
                    put("id", n.id)
                    put("type", n.type.key)
                    put("prayerKey", n.prayerKey)
                    put("triggerAtMillis", triggerAt)
                    put("adhanFinalState", "SCHEDULED")
                    put("stage", "alarm_scheduled_alarmclock")
                })
            }
        } catch (e: SecurityException) {
            Log.e(TAG, "schedule id=${n.id} denied by system", e)
            diagnostics.record("ERROR", "schedule_failed", JSONObject().apply {
                put("id", n.id)
                put("type", n.type.key)
                put("prayerKey", n.prayerKey)
                put("triggerAtMillis", triggerAt)
                put("adhanFinalState", "FAILED")
                put("stage", "alarm_schedule")
                put("error", e.message)
            })
            diagnostics.record("ERROR", "alarm_schedule_denied", JSONObject().apply {
                put("id", n.id)
                put("type", n.type.key)
                put("prayerKey", n.prayerKey)
                put("triggerAtMillis", triggerAt)
                put("error", e.message)
            })
        } catch (e: Exception) {
            // Last line of defence: AlarmManager throws IllegalStateException
            // ("Maximum limit of concurrent alarms 500 reached") once the app
            // crosses the OS cap. MAX_CONCURRENT_ALARMS in scheduleAll makes this
            // unreachable in practice, but a scheduling failure must NEVER crash
            // the app or the foreground service (§8 crash-prevention).
            Log.e(TAG, "schedule id=${n.id} failed", e)
            diagnostics.record("ERROR", "alarm_schedule_exception", JSONObject().apply {
                put("id", n.id)
                put("type", n.type.key)
                put("prayerKey", n.prayerKey)
                put("triggerAtMillis", triggerAt)
                put("adhanFinalState", "FAILED")
                put("stage", "alarm_schedule")
                put("error", e.message)
            })
        }
    }

    fun scheduleAll(notifications: List<ScheduledNotification>) {
        val now = System.currentTimeMillis()
        // Hard cap, well under Android's 500-concurrent-alarm-per-app limit. Keep
        // the SOONEST alarms and drop far-future ones (re-armed on the next sync /
        // daily worker). Crossing the OS cap throws IllegalStateException, which
        // previously crash-looped the app via the foreground service.
        val future = notifications.asSequence()
            .filter { it.triggerAtMillis > now }
            .sortedBy { it.triggerAtMillis }
            .toList()
        val capped = future.take(MAX_CONCURRENT_ALARMS)
        if (future.size > capped.size) {
            diagnostics.record("WARNING", "alarm_cap_applied", JSONObject().apply {
                put("requested", future.size)
                put("scheduled", capped.size)
                put("cap", MAX_CONCURRENT_ALARMS)
                put("dropped", future.size - capped.size)
            })
        }
        capped.forEach(::schedule)
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

        /**
         * Ceiling on prayer alarms registered at once. Android hard-limits an app
         * to 500 concurrent alarms (throws IllegalStateException beyond it); we
         * stay well under to leave headroom for the ongoing-card tick, widget
         * tick, and test alarms. WeMuslim (benchmarked on-device) sat at ~439.
         */
        const val MAX_CONCURRENT_ALARMS = 400
    }
}
