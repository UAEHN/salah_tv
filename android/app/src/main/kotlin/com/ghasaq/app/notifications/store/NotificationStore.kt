package com.ghasaq.app.notifications.store

import android.content.Context
import android.content.SharedPreferences
import com.ghasaq.app.notifications.models.ScheduledNotification
import org.json.JSONArray
import org.json.JSONObject

/**
 * Source-of-truth for the native notification engine. Stores the full set of
 * scheduled notifications + last refresh timestamp so any process (boot
 * receiver, alarm receiver, worker) can rebuild scheduling without Flutter.
 *
 * Backed by plain SharedPreferences — no PII stored (only prayer times for
 * the user's selected city + UI flags + notification copy strings).
 */
class NotificationStore(context: Context) {

    private val prefs: SharedPreferences =
        context.applicationContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    fun writeAll(notifications: List<ScheduledNotification>) {
        val arr = JSONArray()
        notifications.forEach { arr.put(it.toJson()) }
        prefs.edit()
            .putString(KEY_NOTIFICATIONS, arr.toString())
            .putLong(KEY_LAST_REFRESH, System.currentTimeMillis())
            .apply()
    }

    fun readAll(): List<ScheduledNotification> {
        val raw = prefs.getString(KEY_NOTIFICATIONS, null) ?: return emptyList()
        return try {
            val arr = JSONArray(raw)
            (0 until arr.length()).map {
                ScheduledNotification.fromJson(arr.getJSONObject(it))
            }
        } catch (e: Exception) {
            emptyList()
        }
    }

    fun readById(id: Int): ScheduledNotification? =
        readAll().firstOrNull { it.id == id }

    fun lastRefreshMillis(): Long = prefs.getLong(KEY_LAST_REFRESH, 0L)

    fun clear() {
        prefs.edit()
            .remove(KEY_NOTIFICATIONS)
            .remove(KEY_LAST_REFRESH)
            .apply()
    }

    /** Used by the foreground-service builder to render the persistent card. */
    fun nextUpcoming(now: Long): ScheduledNotification? =
        readAll().filter { it.triggerAtMillis > now }
            .minByOrNull { it.triggerAtMillis }

    fun saveSyncMetadata(json: JSONObject) {
        prefs.edit().putString(KEY_SYNC_META, json.toString()).apply()
    }

    fun loadSyncMetadata(): JSONObject? {
        val raw = prefs.getString(KEY_SYNC_META, null) ?: return null
        return try { JSONObject(raw) } catch (e: Exception) { null }
    }

    companion object {
        private const val PREFS = "ghasaq_notifications_v1"
        private const val KEY_NOTIFICATIONS = "notifications_json"
        private const val KEY_LAST_REFRESH = "last_refresh_ms"
        private const val KEY_SYNC_META = "sync_meta_json"
    }
}
