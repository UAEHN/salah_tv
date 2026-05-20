package com.ghasaq.app.notifications.models

/**
 * Stable identity for every notification kind the engine schedules.
 * The wire name [key] is also what Flutter sends in JSON — keep stable.
 *
 * The id-base offsets are used by [com.ghasaq.app.notifications.scheduler.AlarmScheduler]
 * to build collision-free notification IDs as `base + dayIndex*10 + prayerIndex`.
 */
enum class NotificationType(val key: String, val idBase: Int) {
    ADHAN("adhan", 1_000),
    PRE_ADHAN("pre_adhan", 2_000),
    IQAMA("iqama", 3_000),
    PRE_IQAMA("pre_iqama", 4_000),
    ADHKAR_MORNING("adhkar_morning", 5_000),
    ADHKAR_EVENING("adhkar_evening", 6_000);

    companion object {
        fun fromKey(key: String): NotificationType? =
            values().firstOrNull { it.key == key }
    }
}
