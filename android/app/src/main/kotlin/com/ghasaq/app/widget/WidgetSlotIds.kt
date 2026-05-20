package com.ghasaq.app.widget

import com.ghasaq.app.R

/** Resource IDs for the 5-prayer strip; index = position in today's slots. */
internal object WidgetSlotIds {
    val containers = intArrayOf(
        R.id.slot_0,
        R.id.slot_1,
        R.id.slot_2,
        R.id.slot_3,
        R.id.slot_4,
    )
    val names = intArrayOf(
        R.id.slot_0_name,
        R.id.slot_1_name,
        R.id.slot_2_name,
        R.id.slot_3_name,
        R.id.slot_4_name,
    )
    val times = intArrayOf(
        R.id.slot_0_time,
        R.id.slot_1_time,
        R.id.slot_2_time,
        R.id.slot_3_time,
        R.id.slot_4_time,
    )
}

/** Maps a prayer/gradient key to its themed widget background drawable. */
internal fun backgroundForGradient(key: String): Int = when (key) {
    "fajr" -> R.drawable.widget_bg_fajr
    "sunrise" -> R.drawable.widget_bg_sunrise
    "dhuhr" -> R.drawable.widget_bg_dhuhr
    "asr" -> R.drawable.widget_bg_asr
    "maghrib" -> R.drawable.widget_bg_maghrib
    "isha" -> R.drawable.widget_bg_isha
    else -> R.drawable.widget_bg_isha
}
