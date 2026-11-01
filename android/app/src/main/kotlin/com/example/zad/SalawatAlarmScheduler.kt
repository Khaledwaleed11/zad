
package com.example.zad

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build

object SalawatAlarmScheduler {

    private const val PREFS_NAME = "zad_salawat_alarms"
    private const val KEY_ENABLED = "enabled"
    private const val KEY_NEXT_TIME = "next_time"

    private const val ALARM_ID = 301
    private const val INTERVAL_MINUTES = 60L

    private const val ACTION_SALAWAT =
        "com.example.zad.ACTION_SALAWAT_ALARM"

    private fun preferences(context: Context) =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    private fun pendingIntent(context: Context): PendingIntent {
        val intent = Intent(context, SalawatAlarmReceiver::class.java).apply {
            action = ACTION_SALAWAT
        }

        return PendingIntent.getBroadcast(
            context,
            ALARM_ID,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    fun schedule(context: Context): Long {
        val prefs = preferences(context)
        val now = System.currentTimeMillis()

        val existingTime = prefs.getLong(KEY_NEXT_TIME, 0L)

        val existingAlarm = PendingIntent.getBroadcast(
            context,
            ALARM_ID,
            Intent(context, SalawatAlarmReceiver::class.java).apply {
                action = ACTION_SALAWAT
            },
            PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
        )

        if (
            existingTime > now &&
            existingAlarm != null &&
            prefs.getBoolean(KEY_ENABLED, false)
        ) {
            return existingTime
        }

        prefs.edit()
            .putBoolean(KEY_ENABLED, true)
            .apply()

        val nextTime = now + INTERVAL_MINUTES * 60_000L

        scheduleAt(context, nextTime)

        return nextTime
    }

    fun scheduleNext(context: Context) {
        val prefs = preferences(context)

        if (!prefs.getBoolean(KEY_ENABLED, false)) return

        val nextTime = System.currentTimeMillis() +
                INTERVAL_MINUTES * 60_000L

        scheduleAt(context, nextTime)
    }

    private fun scheduleAt(context: Context, time: Long) {
        val alarmManager =
            context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val operation = pendingIntent(context)

        if (
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
            !alarmManager.canScheduleExactAlarms()
        ) {
            alarmManager.setAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                time,
                operation
            )
        } else {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                time,
                operation
            )
        }

        preferences(context).edit()
            .putLong(KEY_NEXT_TIME, time)
            .apply()
    }

    fun getNextTime(context: Context): Long {
        return preferences(context).getLong(KEY_NEXT_TIME, 0L)
    }

    fun cancel(context: Context) {
        preferences(context).edit()
            .putBoolean(KEY_ENABLED, false)
            .remove(KEY_NEXT_TIME)
            .apply()

        val alarmManager =
            context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        alarmManager.cancel(pendingIntent(context))

        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE)
                    as android.app.NotificationManager

        notificationManager.cancel(ALARM_ID)
    }

    fun isEnabled(context: Context): Boolean {
        return preferences(context).getBoolean(KEY_ENABLED, false)
    }

    fun restoreAfterRestart(context: Context) {
        val prefs = preferences(context)

        if (!prefs.getBoolean(KEY_ENABLED, false)) return

        val savedTime = prefs.getLong(KEY_NEXT_TIME, 0L)

        val nextTime = if (savedTime > System.currentTimeMillis()) {
            savedTime
        } else {
            System.currentTimeMillis() + INTERVAL_MINUTES * 60_000L
        }

        scheduleAt(context, nextTime)
    }
}
