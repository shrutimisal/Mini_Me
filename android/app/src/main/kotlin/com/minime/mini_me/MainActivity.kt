package com.minime.mini_me

import android.Manifest
import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** Bridges Flutter calls to the native overlay + scheduling code. No logic lives here. */
class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                try {
                    handle(call, result)
                } catch (e: ActivityNotFoundException) {
                    result.error("SETTINGS_UNAVAILABLE", "This settings screen is not available on this device.", null)
                } catch (e: Exception) {
                    result.error("NATIVE_ERROR", e.message, null)
                }
            }
    }

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "checkOverlayPermission" -> result.success(Settings.canDrawOverlays(this))

            "openOverlaySettings" -> {
                startActivity(
                    Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName"))
                )
                result.success(null)
            }

            "showOverlay" -> {
                if (!Settings.canDrawOverlays(this)) {
                    result.error("NO_PERMISSION", "Overlay permission is not granted.", null)
                    return
                }
                val message = call.argument<String>("message") ?: "Hi! I'm MiniMe 👋"
                val durationMs = call.argument<Number>("durationMs")?.toLong() ?: -1L
                if (OverlayService.start(this, message, durationMs)) {
                    result.success(true)
                } else {
                    result.error("START_FAILED", "Android refused to start the overlay service.", null)
                }
            }

            "hideOverlay" -> {
                OverlayService.instance?.hide()
                result.success(true)
            }

            "isOverlayShowing" -> result.success(OverlayService.isShowing)

            "syncReminders" -> {
                val json = call.argument<String>("json") ?: "[]"
                result.success(ReminderScheduler.sync(this, json))
            }

            "saveSettings" -> {
                NativeStore.saveSettings(this, call.argument<String>("json") ?: "{}")
                result.success(true)
            }

            "canScheduleExactAlarms" -> result.success(ReminderScheduler.canScheduleExact(this))

            "openExactAlarmSettings" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    startActivity(
                        Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM, Uri.parse("package:$packageName"))
                    )
                }
                result.success(null)
            }

            "checkNotificationPermission" -> result.success(
                Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
                    checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
            )

            "requestNotificationPermission" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 1001)
                }
                result.success(null)
            }

            "openBatterySettings" -> {
                startActivity(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }

    companion object {
        const val CHANNEL = "com.minime.mini_me/native"
    }
}
