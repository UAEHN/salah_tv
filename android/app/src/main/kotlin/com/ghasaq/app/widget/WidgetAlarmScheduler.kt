package com.ghasaq.app.widget

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import com.ghasaq.app.PrayerWidgetProvider

/**
 * Schedules a single exact alarm at the next minute boundary so installed
 * widgets re-render the countdown text. The alarm fans out one broadcast per
 * provider class, each with its own EXTRA_APPWIDGET_IDS, which routes back
 * into the matching onUpdate. Per-provider request codes keep the
 * PendingIntents distinct so cancelling one does not affect the others.
 *
 * The 4x4 large widget uses Chronometer for second-level countdown, so this
 * minute-tick still suffices to refresh the per-prayer strip and the "next
 * prayer" highlight even though the seconds tick on their own.
 */
internal object WidgetAlarmScheduler {
    private const val TAG = "PrayerWidget"

    private data class Target(
        val cls: Class<*>,
        val reqCode: Int,
    )

    private val targets = listOf(
        Target(PrayerWidgetProvider::class.java, 0x57AD0),
    )

    fun scheduleNextTick(context: Context) {
        val mgr = AppWidgetManager.getInstance(context)
        val now = System.currentTimeMillis()
        val nextMinute = ((now / 60_000L) + 1L) * 60_000L
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        for (t in targets) {
            val ids = mgr.getAppWidgetIds(ComponentName(context, t.cls))
            if (ids.isEmpty()) continue
            val pi = pendingIntent(context, t, ids)
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    am.setExactAndAllowWhileIdle(AlarmManager.RTC, nextMinute, pi)
                } else {
                    am.setExact(AlarmManager.RTC, nextMinute, pi)
                }
                Log.i(TAG, "scheduled tick at $nextMinute for ${t.cls.simpleName}")
            } catch (e: SecurityException) {
                // Some OEMs revoke SCHEDULE_EXACT_ALARM on app updates — fall
                // back to inexact so the widget still ticks at minute granularity.
                am.set(AlarmManager.RTC, nextMinute, pi)
                Log.w(TAG, "exact denied; using inexact for ${t.cls.simpleName}")
            }
        }
    }

    fun cancel(context: Context) {
        val mgr = AppWidgetManager.getInstance(context)
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        for (t in targets) {
            val ids = mgr.getAppWidgetIds(ComponentName(context, t.cls))
            am.cancel(pendingIntent(context, t, ids))
        }
    }

    private fun pendingIntent(context: Context, t: Target, ids: IntArray): PendingIntent {
        val intent = Intent(context, t.cls).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
        }
        return PendingIntent.getBroadcast(
            context,
            t.reqCode,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
    }
}
