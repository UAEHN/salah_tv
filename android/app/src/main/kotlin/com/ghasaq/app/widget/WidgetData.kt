package com.ghasaq.app.widget

import android.content.Context
import es.antonborri.home_widget.HomeWidgetPlugin

internal data class PrayerSlot(
    val key: String,
    val label: String,
    val timeLabel: String,
    val timestampMs: Long,
)

internal data class WidgetData(
    val slots: List<PrayerSlot>,
    val city: String,
    val hijri: String,
    val gradient: String,
    val templateHm: String,
    val templateH: String,
    val templateM: String,
    val nowLabel: String,
)

/** Reads the SharedPreferences written by the Flutter side. */
internal fun readWidgetData(context: Context): WidgetData? {
    val prefs = HomeWidgetPlugin.getData(context)
    val count = prefs.getString("slots_count", null)?.toIntOrNull() ?: 0
    if (count == 0) return null
    val slots = (0 until count).mapNotNull { i ->
        val ts = prefs.getLong("slot_${i}_ts", 0L)
        val key = prefs.getString("slot_${i}_key", null)
        val label = prefs.getString("slot_${i}_label", null)
        val time = prefs.getString("slot_${i}_time", null)
        if (ts == 0L || key == null || label == null || time == null) null
        else PrayerSlot(key, label, time, ts)
    }
    if (slots.isEmpty()) return null
    return WidgetData(
        slots = slots,
        city = prefs.getString("city", "") ?: "",
        hijri = prefs.getString("hijri", "") ?: "",
        gradient = prefs.getString("gradient", "fajr") ?: "fajr",
        templateHm = prefs.getString("remaining_hm", "") ?: "",
        templateH = prefs.getString("remaining_h", "") ?: "",
        templateM = prefs.getString("remaining_m", "") ?: "",
        nowLabel = prefs.getString("remaining_now", "—") ?: "—",
    )
}
