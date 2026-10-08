package com.minime.mini_me

import org.json.JSONException
import org.json.JSONObject
import java.time.LocalTime

/** Native view of the settings JSON pushed from Flutter. Keys must match AppSettings.toJson(). */
data class OverlaySettings(
    val scale: Float = 1f,
    val durationMs: Long = 5000,
    val animationMs: Long = 700,
    val sound: Boolean = false,
    val quietEnabled: Boolean = false,
    val quietStartMin: Int = 22 * 60,
    val quietEndMin: Int = 7 * 60,
    val position: String = "center",
) {
    fun isQuietNow(nowMin: Int = LocalTime.now().let { it.hour * 60 + it.minute }): Boolean {
        if (!quietEnabled || quietStartMin == quietEndMin) return false
        return if (quietStartMin < quietEndMin) {
            nowMin in quietStartMin until quietEndMin
        } else { // range wraps past midnight
            nowMin >= quietStartMin || nowMin < quietEndMin
        }
    }

    companion object {
        fun fromJson(json: String?): OverlaySettings {
            if (json.isNullOrBlank()) return OverlaySettings()
            return try {
                val o = JSONObject(json)
                OverlaySettings(
                    scale = o.optDouble("avatarScale", 1.0).toFloat().coerceIn(0.6f, 2f),
                    durationMs = o.optLong("durationMs", 5000).coerceIn(1000, 60000),
                    animationMs = o.optLong("animationMs", 700).coerceIn(100, 3000),
                    sound = o.optBoolean("sound", false),
                    quietEnabled = o.optBoolean("quietEnabled", false),
                    quietStartMin = o.optInt("quietStartMin", 22 * 60).coerceIn(0, 1439),
                    quietEndMin = o.optInt("quietEndMin", 7 * 60).coerceIn(0, 1439),
                    position = o.optString("position", "center"),
                )
            } catch (e: JSONException) {
                OverlaySettings()
            }
        }
    }
}
