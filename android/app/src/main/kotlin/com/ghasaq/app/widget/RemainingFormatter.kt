package com.ghasaq.app.widget

/** Pure function: picks the right template and substitutes {h}/{m}. */
internal fun formatRemaining(remainingMs: Long, data: WidgetData): String {
    if (remainingMs <= 0L) return data.nowLabel
    val totalMinutes = (remainingMs + 30_000L) / 60_000L  // round to nearest min
    val h = (totalMinutes / 60L).toInt()
    val m = (totalMinutes % 60L).toInt()
    return when {
        h > 0 && m > 0 -> data.templateHm
            .replace("{h}", h.toString())
            .replace("{m}", m.toString())
        h > 0 -> data.templateH.replace("{h}", h.toString())
        else -> data.templateM.replace("{m}", m.toString().ifEmpty { "0" })
    }
}

/** Returns the next slot whose timestamp is in the future, or null. */
internal fun pickNext(data: WidgetData, nowMs: Long): PrayerSlot? =
    data.slots.firstOrNull { it.timestampMs > nowMs }
