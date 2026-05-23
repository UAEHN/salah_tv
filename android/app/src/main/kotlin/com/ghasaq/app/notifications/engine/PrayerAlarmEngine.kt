package com.ghasaq.app.notifications.engine

import android.content.Context
import com.ghasaq.app.notifications.builder.NotificationChannelsManager
import com.ghasaq.app.notifications.models.ScheduledNotification
import com.ghasaq.app.notifications.scheduler.AlarmScheduler
import com.ghasaq.app.notifications.store.NotificationStore
import com.ghasaq.app.notifications.store.ScheduleLog
import com.ghasaq.app.notifications.worker.RefreshScheduler
import org.json.JSONArray
import org.json.JSONObject

/**
 * Facade that the [com.ghasaq.app.notifications.channel.NotificationMethodChannel]
 * delegates to. Owns the *order* of operations during a sync:
 *
 *   1. Validate + parse JSON from Flutter (rejects past-dated alarms outside
 *      a 30-day window, rejects unknown notification types).
 *   2. Cancel everything currently registered with AlarmManager.
 *   3. Persist the new set in the store (source of truth for receivers).
 *   4. Schedule the new set with AlarmScheduler.
 *   5. Refresh channels, start the foreground service, register the worker.
 *
 * Returns the count of notifications actually scheduled (those still in
 * the future after dedup) so Flutter can surface it for diagnostics.
 */
class PrayerAlarmEngine(private val context: Context) {

    private val store = NotificationStore(context)
    private val scheduler = AlarmScheduler(context)

    fun initialize(): Boolean {
        NotificationChannelsManager(context).ensureAll()
        RefreshScheduler.ensurePeriodicWork(context)
        return true
    }

    fun sync(payload: JSONObject): Int {
        val list = parseAndValidate(payload)
        val previous = store.readAll().map { it.id }
        scheduler.cancelAll(previous)
        store.writeAll(list)
        store.saveSyncMetadata(payload.optJSONObject("meta") ?: JSONObject())
        scheduler.scheduleAll(list)
        NotificationChannelsManager(context).ensureAll()
        registerCustomAdhanChannels(payload)
        RefreshScheduler.ensurePeriodicWork(context)
        val now = System.currentTimeMillis()
        return list.count { it.triggerAtMillis > now }
    }

    fun cancelAll() {
        val previous = store.readAll().map { it.id }
        scheduler.cancelAll(previous)
        store.clear()
        RefreshScheduler.cancel(context)
    }

    fun runTest(): Int {
        val triggerAt = System.currentTimeMillis() + TEST_DELAY_MS
        val test = ScheduledNotification(
            id = TEST_ID,
            type = com.ghasaq.app.notifications.models.NotificationType.ADHAN,
            triggerAtMillis = triggerAt,
            title = "اختبار الإشعارات",
            body = "إذا وصلك هذا الإشعار فالمحرك يعمل بشكل صحيح",
            channelId = com.ghasaq.app.notifications.builder.NotificationChannelIds
                .adhanChannelId("adhan"),
            payload = null,
            soundUri = null,
            prayerKey = null,
            dayIndex = 0,
        )
        // Persist alongside real notifications so AlarmReceiver can read it.
        val merged = store.readAll().filter { it.id != TEST_ID } + test
        store.writeAll(merged)
        scheduler.schedule(test)
        return TEST_ID
    }

    /**
     * Debug-only helper for the Al-Kahf reminder button. Fires the same
     * "Blessed Friday" notification 5 seconds from now without disturbing
     * the regular Friday schedule (separate test id).
     */
    fun runAlKahfTest(): Int {
        val triggerAt = System.currentTimeMillis() + AL_KAHF_TEST_DELAY_MS
        val test = ScheduledNotification(
            id = AL_KAHF_TEST_ID,
            type = com.ghasaq.app.notifications.models.NotificationType.AL_KAHF,
            triggerAtMillis = triggerAt,
            title = "جمعة مباركة 🌸",
            body = "لا تنسَ سورة الكهف — نور لك بين الجمعتين",
            channelId = com.ghasaq.app.notifications.builder.NotificationChannelIds
                .AL_KAHF,
            payload = "al_kahf",
            soundUri = null,
            prayerKey = null,
            dayIndex = 0,
        )
        val merged = store.readAll().filter { it.id != AL_KAHF_TEST_ID } + test
        store.writeAll(merged)
        scheduler.schedule(test)
        return AL_KAHF_TEST_ID
    }

    fun readScheduleLog(): JSONArray {
        val arr = JSONArray()
        ScheduleLog(context).readAll().forEach { arr.put(it.toJson()) }
        return arr
    }

    private fun parseAndValidate(payload: JSONObject): List<ScheduledNotification> {
        val now = System.currentTimeMillis()
        val cutoff = now + MAX_HORIZON_MS
        val items = payload.optJSONArray("notifications") ?: return emptyList()
        return (0 until items.length()).mapNotNull { i ->
            try {
                val n = ScheduledNotification.fromJson(items.getJSONObject(i))
                when {
                    n.triggerAtMillis <= now -> null
                    n.triggerAtMillis > cutoff -> null
                    else -> n
                }
            } catch (e: Exception) { null }
        }
    }

    private fun registerCustomAdhanChannels(payload: JSONObject) {
        val arr = payload.optJSONArray("customAdhans") ?: return
        val mgr = NotificationChannelsManager(context)
        for (i in 0 until arr.length()) {
            val o = arr.optJSONObject(i) ?: continue
            val name = o.optString("fileName")
            val uri = o.optString("contentUri")
            if (name.isNotEmpty() && uri.isNotEmpty()) {
                mgr.ensureCustomAdhan(name, uri)
            }
        }
    }

    companion object {
        private const val TEST_ID = 999_999
        private const val TEST_DELAY_MS = 15_000L
        private const val AL_KAHF_TEST_ID = 999_998
        private const val AL_KAHF_TEST_DELAY_MS = 5_000L
        private const val MAX_HORIZON_MS = 30L * 24 * 60 * 60 * 1000
    }
}
