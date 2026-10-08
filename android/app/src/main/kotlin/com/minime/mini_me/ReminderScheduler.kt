package com.minime.mini_me

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.util.Log
import java.time.Instant
import java.time.ZoneId

/**
 * Schedules one AlarmManager alarm per enabled reminder (the next occurrence only).
 * After an alarm fires, AlarmReceiver schedules the following occurrence.
 */
object ReminderScheduler {
    private const val TAG = "ReminderScheduler"
    const val ACTION_ALARM = "com.minime.mini_me.REMINDER_ALARM"
    const val EXTRA_ID = "reminder_id"

    /** Stores the reminders pushed from Flutter and re-registers all alarms. Returns alarms scheduled. */
    fun sync(ctx: Context, json: String): Int {
        NativeStore.saveReminders(ctx, json)
        return rescheduleAll(ctx)
    }

    fun rescheduleAll(ctx: Context): Int {
        NativeStore.scheduledIds(ctx).forEach { cancel(ctx, it) }
        val scheduled = mutableSetOf<String>()
        NativeStore.reminders(ctx).filter { it.enabled }.forEach {
            if (schedule(ctx, it)) scheduled += it.id
        }
        NativeStore.saveScheduledIds(ctx, scheduled)
        return scheduled.size
    }

    fun schedule(ctx: Context, r: Reminder, fromMillis: Long = System.currentTimeMillis()): Boolean {
        val at = nextTriggerMillis(r, fromMillis) ?: return false
        val am = ctx.getSystemService(AlarmManager::class.java)
        val pi = pendingIntent(ctx, r.id)
        try {
            if (canScheduleExact(ctx)) {
                am.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, pi)
            } else {
                // Exact-alarm access not granted: Android may delay this by several minutes.
                am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, pi)
            }
        } catch (e: SecurityException) {
            Log.w(TAG, "Exact alarm denied, using inexact", e)
            am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, pi)
        }
        return true
    }

    fun cancel(ctx: Context, id: String) {
        ctx.getSystemService(AlarmManager::class.java).cancel(pendingIntent(ctx, id))
    }

    fun canScheduleExact(ctx: Context): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.S ||
            ctx.getSystemService(AlarmManager::class.java).canScheduleExactAlarms()

    private fun pendingIntent(ctx: Context, id: String): PendingIntent {
        val intent = Intent(ctx, AlarmReceiver::class.java)
            .setAction(ACTION_ALARM)
            .setData(Uri.parse("minime://reminder/" + Uri.encode(id)))
            .putExtra(EXTRA_ID, id)
        return PendingIntent.getBroadcast(
            ctx, id.hashCode(), intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    /** First occurrence strictly after [fromMillis], or null if the reminder can never fire. */
    fun nextTriggerMillis(r: Reminder, fromMillis: Long): Long? {
        val zone = ZoneId.systemDefault()
        val now = Instant.ofEpochMilli(fromMillis).atZone(zone)
        val todayAt = now.toLocalDate().atTime(r.hour, r.minute).atZone(zone)
        return when (r.repeat) {
            "weekly" -> {
                if (r.days.isEmpty()) null
                else (0..7).map { todayAt.plusDays(it.toLong()) }
                    .firstOrNull { it.isAfter(now) && it.dayOfWeek.value in r.days }
                    ?.toInstant()?.toEpochMilli()
            }
            "interval" -> {
                val step = r.intervalHours.coerceAtLeast(1) * 3_600_000L
                val base = todayAt.toInstant().toEpochMilli()
                base + (Math.floorDiv(fromMillis - base, step) + 1) * step
            }
            else -> {
                var t = todayAt
                if (!t.isAfter(now)) t = t.plusDays(1)
                t.toInstant().toEpochMilli()
            }
        }
    }
}
