package com.ghasaq.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.util.Log
import android.widget.RemoteViews
import com.ghasaq.app.widget.PrayerSlot
import com.ghasaq.app.widget.WidgetAlarmScheduler
import com.ghasaq.app.widget.WidgetData
import com.ghasaq.app.widget.WidgetSlotIds
import com.ghasaq.app.widget.backgroundForGradient
import com.ghasaq.app.widget.formatRemaining
import com.ghasaq.app.widget.pickNext
import com.ghasaq.app.widget.readWidgetData

/**
 * Renders the 4x2 prayer-times home-screen widget. All "next prayer" and
 * "remaining time" computation lives here so the widget keeps ticking even
 * when the Flutter side is not running. Flutter writes raw timestamps and
 * pre-localized strings; the bridge fires only when the schedule changes.
 */
class PrayerWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        Log.i(TAG, "onUpdate ids=${appWidgetIds.toList()}")
        val data = readWidgetData(context)
        val views = RemoteViews(context.packageName, R.layout.prayer_widget_4x2)
        if (data == null) {
            renderEmpty(views)
        } else {
            renderHero(views, data)
            renderStrip(views, data)
            views.setTextViewText(R.id.widget_city, data.city)
            views.setTextViewText(R.id.widget_hijri, data.hijri)
            views.setInt(
                R.id.widget_root,
                "setBackgroundResource",
                backgroundForGradient(data.gradient),
            )
        }
        views.setOnClickPendingIntent(R.id.widget_root, launchAppPendingIntent(context))
        for (id in appWidgetIds) appWidgetManager.updateAppWidget(id, views)
        WidgetAlarmScheduler.scheduleNextTick(context)
    }

    private fun renderEmpty(views: RemoteViews) {
        views.setTextViewText(R.id.widget_next_label, "—")
        views.setTextViewText(R.id.widget_remaining, "")
        for (i in 0 until 5) {
            views.setTextViewText(WidgetSlotIds.names[i], "")
            views.setTextViewText(WidgetSlotIds.times[i], "")
            views.setInt(
                WidgetSlotIds.containers[i],
                "setBackgroundResource",
                R.drawable.widget_pill_inactive,
            )
        }
    }

    private fun renderHero(views: RemoteViews, data: WidgetData) {
        val now = System.currentTimeMillis()
        val next = pickNext(data, now)
        if (next == null) {
            views.setTextViewText(R.id.widget_next_label, "—")
            views.setTextViewText(R.id.widget_remaining, data.nowLabel)
        } else {
            views.setTextViewText(R.id.widget_next_label, next.label)
            views.setTextViewText(
                R.id.widget_remaining,
                formatRemaining(next.timestampMs - now, data),
            )
        }
    }

    private fun renderStrip(views: RemoteViews, data: WidgetData) {
        val today = todaySlots(data.slots)
        val nextKey = pickNext(data, System.currentTimeMillis())?.key
        for (i in 0 until 5) {
            val slot = today.getOrNull(i)
            views.setTextViewText(WidgetSlotIds.names[i], slot?.label ?: "")
            views.setTextViewText(WidgetSlotIds.times[i], slot?.timeLabel ?: "")
            val isActive = slot != null && slot.key == nextKey
            views.setInt(
                WidgetSlotIds.containers[i],
                "setBackgroundResource",
                if (isActive) R.drawable.widget_pill_active
                else R.drawable.widget_pill_inactive,
            )
        }
    }

    /** Take the first 5 prayer slots — Flutter sends them grouped by day in
     *  order (fajr, dhuhr, asr, maghrib, isha) starting today. */
    private fun todaySlots(all: List<PrayerSlot>): List<PrayerSlot> =
        if (all.size <= 5) all else all.subList(0, 5)

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        WidgetAlarmScheduler.scheduleNextTick(context)
    }

    override fun onDisabled(context: Context) {
        WidgetAlarmScheduler.cancel(context)
        super.onDisabled(context)
    }

    private fun launchAppPendingIntent(context: Context): PendingIntent {
        val launch = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        return PendingIntent.getActivity(
            context,
            0,
            launch,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
    }

    companion object {
        private const val TAG = "PrayerWidget"
    }
}
