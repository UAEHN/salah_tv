package com.ghasaq.app.notifications.ongoing

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

/**
 * Fires one exact alarm at the next minute boundary so the persistent card
 * re-renders its countdown, then re-arms itself from the receiver — the same
 * self-perpetuating chain the home-screen widget uses (WidgetAlarmScheduler).
 *
 * Minute granularity is enough: the countdown is displayed in hours/minutes.
 * One alarm per minute costs far less than a foreground service, and unlike the
 * widget's chain this one runs whenever the card is showing, widget or not.
 */
internal object OngoingAlarmScheduler {
    private const val TAG = "OngoingCard"
    private const val REQ_CODE = 0x0A9C

    fun scheduleNextTick(context: Context) {
        val now = System.currentTimeMillis()
        val nextMinute = ((now / 60_000L) + 1L) * 60_000L
        val am = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
        val pi = pendingIntent(context)
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                am.setExactAndAllowWhileIdle(AlarmManager.RTC, nextMinute, pi)
            } else {
                am.setExact(AlarmManager.RTC, nextMinute, pi)
            }
        } catch (e: SecurityException) {
            // Some OEMs revoke SCHEDULE_EXACT_ALARM — inexact still ticks close
            // enough for a minute-granularity countdown.
            try {
                am.set(AlarmManager.RTC, nextMinute, pi)
            } catch (e2: Exception) {
                Log.w(TAG, "tick alarm dropped", e2)
            }
            Log.w(TAG, "exact alarm denied; using inexact tick")
        } catch (e: Exception) {
            // AlarmManager throws IllegalStateException at the 500-alarm cap. The
            // countdown tick is non-critical — dropping it must NEVER crash the
            // foreground service. THIS is the exact throw that crash-looped the
            // app when the alarm count blew past 500.
            Log.w(TAG, "tick alarm not scheduled: ${e.message}")
        }
    }

    fun cancel(context: Context) {
        val am = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
        am.cancel(pendingIntent(context))
    }

    private fun pendingIntent(context: Context): PendingIntent = PendingIntent.getBroadcast(
        context,
        REQ_CODE,
        Intent(context, OngoingTickReceiver::class.java),
        PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
    )
}
