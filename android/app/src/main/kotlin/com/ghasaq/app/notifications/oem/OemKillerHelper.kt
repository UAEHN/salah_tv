package com.ghasaq.app.notifications.oem

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import org.json.JSONObject

/**
 * Detects ROMs that aggressively kill background apps and surfaces the
 * vendor-specific "Autostart" / "Protected apps" settings page so the
 * notification health screen can guide users straight to the fix.
 *
 * This is the part the OS does NOT solve for us: even with battery-opt
 * exemption, MIUI/EMUI/ColorOS/FunTouch maintain a separate kill-list
 * controlled by their own settings page.
 */
object OemKillerHelper {

    fun snapshot(context: Context): JSONObject {
        val mfr = Build.MANUFACTURER.lowercase()
        val brand = Build.BRAND.lowercase()
        val vendor = detect(mfr, brand)
        return JSONObject().apply {
            put("manufacturer", Build.MANUFACTURER)
            put("brand", Build.BRAND)
            put("vendor", vendor.key)
            put("isAggressive", vendor.isAggressive)
            put("autostartAvailable", vendor.intent != null && resolves(context, vendor.intent))
        }
    }

    fun openAutostart(context: Context): Boolean {
        val mfr = Build.MANUFACTURER.lowercase()
        val brand = Build.BRAND.lowercase()
        val vendor = detect(mfr, brand)
        val intent = vendor.intent ?: return false
        if (!resolves(context, intent)) return false
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        return try { context.startActivity(intent); true } catch (_: Exception) { false }
    }

    private fun resolves(context: Context, intent: Intent): Boolean =
        intent.resolveActivity(context.packageManager) != null

    private fun detect(mfr: String, brand: String): Vendor = when {
        mfr.contains("xiaomi") || brand.contains("redmi") || brand.contains("poco") ->
            Vendor("xiaomi", true, miuiAutostart())
        mfr.contains("huawei") || mfr.contains("honor") ->
            Vendor("huawei", true, huaweiAutostart())
        mfr.contains("oppo") || mfr.contains("realme") ->
            Vendor("oppo", true, oppoAutostart())
        mfr.contains("vivo") -> Vendor("vivo", true, vivoAutostart())
        mfr.contains("samsung") -> Vendor("samsung", false, null)
        else -> Vendor("generic", false, null)
    }

    private fun miuiAutostart() = Intent().setComponent(
        ComponentName(
            "com.miui.securitycenter",
            "com.miui.permcenter.autostart.AutoStartManagementActivity",
        ),
    )

    private fun huaweiAutostart() = Intent().setComponent(
        ComponentName(
            "com.huawei.systemmanager",
            "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity",
        ),
    )

    private fun oppoAutostart() = Intent().setComponent(
        ComponentName(
            "com.coloros.safecenter",
            "com.coloros.safecenter.permission.startup.StartupAppListActivity",
        ),
    )

    private fun vivoAutostart() = Intent().setComponent(
        ComponentName(
            "com.vivo.permissionmanager",
            "com.vivo.permissionmanager.activity.BgStartUpManagerActivity",
        ),
    )

    private data class Vendor(
        val key: String,
        val isAggressive: Boolean,
        val intent: Intent?,
    )
}
