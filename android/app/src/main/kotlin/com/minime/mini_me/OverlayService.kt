package com.minime.mini_me

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import android.util.Log

/**
 * Short-lived foreground service that hosts the overlay. It starts when MiniMe needs to
 * appear and stops itself as soon as the avatar has left, so nothing runs in between.
 */
class OverlayService : Service() {

    private var manager: OverlayManager? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        instance = this
        manager = OverlayManager(this)
        createChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Must happen immediately after startForegroundService().
        try {
            startAsForeground()
        } catch (e: Exception) {
            Log.e(TAG, "startForeground failed", e)
            stopSelf()
            return START_NOT_STICKY
        }

        if (!Settings.canDrawOverlays(this)) {
            stopSelf()
            return START_NOT_STICKY
        }

        val message = intent?.getStringExtra(EXTRA_MESSAGE) ?: "Hi! I'm MiniMe 👋"
        val settings = NativeStore.settings(this)
        val requested = intent?.getLongExtra(EXTRA_DURATION_MS, -1L) ?: -1L
        val duration = if (requested < 0) settings.durationMs else requested

        val shown = manager?.show(message, duration, settings) { stopSelf() } ?: false
        if (!shown) stopSelf()
        return START_NOT_STICKY
    }

    fun hide() {
        manager?.exit() ?: stopSelf()
    }

    override fun onDestroy() {
        manager?.removeNow()
        manager = null
        if (instance === this) instance = null
        super.onDestroy()
    }

    private fun createChannel() {
        val channel = NotificationChannel(
            CHANNEL_ID, "MiniMe companion", NotificationManager.IMPORTANCE_LOW
        ).apply { description = "Shown briefly while MiniMe is on your screen." }
        getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
    }

    private fun startAsForeground() {
        val notification = Notification.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle("MiniMe")
            .setContentText("Your companion is visiting 👧")
            .setOngoing(true)
            .build()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    companion object {
        private const val TAG = "OverlayService"
        private const val CHANNEL_ID = "minime_companion"
        private const val NOTIFICATION_ID = 1001
        private const val EXTRA_MESSAGE = "message"
        private const val EXTRA_DURATION_MS = "durationMs"

        @Volatile
        var instance: OverlayService? = null
            private set

        val isShowing: Boolean get() = instance?.manager?.isShowing == true

        /** durationMs: -1 = use saved setting, 0 = stay until dismissed. */
        fun start(context: Context, message: String, durationMs: Long): Boolean {
            if (!Settings.canDrawOverlays(context)) return false
            return try {
                val intent = Intent(context, OverlayService::class.java)
                    .putExtra(EXTRA_MESSAGE, message)
                    .putExtra(EXTRA_DURATION_MS, durationMs)
                context.startForegroundService(intent)
                true
            } catch (e: Exception) {
                Log.e(TAG, "Could not start overlay service", e)
                false
            }
        }
    }
}
