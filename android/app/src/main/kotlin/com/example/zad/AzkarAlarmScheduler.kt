
package com.example.zad

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import java.util.Calendar

object AzkarAlarmScheduler {

    private const val PREFS_NAME = "zad_azkar_alarms"
    private const val KEY_ENABLED = "enabled"

    private val azkar = listOf(
        AzkarTime(201, 7, 0, "azkar_morning"),
        AzkarTime(202, 17, 0, "azkar_evening"),
        AzkarTime(203, 23, 0, "azkar_sleep")
    )

    fun scheduleAll(context: Context) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putBoolean(KEY_ENABLED, true)
            .apply()

        azkar.forEach { scheduleNext(context, it) }
    }

    fun cancelAll(context: Context) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putBoolean(KEY_ENABLED, false)
            .apply()

        val alarmManager =
            context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        azkar.forEach { item ->
            val intent = Intent(context, AzkarAlarmReceiver::class.java)
                .setAction("com.example.zad.AZKAR_${item.id}")

            val pendingIntent = PendingIntent.getBroadcast(
                context,
                item.id,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            alarmManager.cancel(pendingIntent)
        }
    }

    fun rescheduleAfterRestart(context: Context) {
        val enabled = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getBoolean(KEY_ENABLED, false)

        if (enabled) scheduleAll(context)
    }

    fun scheduleNext(context: Context, item: AzkarTime) {
        val enabled = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getBoolean(KEY_ENABLED, false)

        if (!enabled) return

        val calendar = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, item.hour)
            set(Calendar.MINUTE, item.minute)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)

            if (timeInMillis <= System.currentTimeMillis()) {
                add(Calendar.DAY_OF_YEAR, 1)
            }
        }

        val intent = Intent(context, AzkarAlarmReceiver::class.java).apply {
            action = "com.example.zad.AZKAR_${item.id}"
            putExtra("payload", item.payload)
            putExtra("alarm_id", item.id)
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            item.id,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val alarmManager =
            context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S ||
                alarmManager.canScheduleExactAlarms()
            ) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    calendar.timeInMillis,
                    pendingIntent
                )
            } else {
                alarmManager.setAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    calendar.timeInMillis,
                    pendingIntent
                )
            }
        } else {
            alarmManager.setExact(
                AlarmManager.RTC_WAKEUP,
                calendar.timeInMillis,
                pendingIntent
            )
        }
    }
    fun scheduleNextById(context: Context, id: Int) {
        azkar.find { it.id == id }?.let {
            scheduleNext(context, it)
        }
    }
}

data class AzkarTime(
    val id: Int,
    val hour: Int,
    val minute: Int,
    val payload: String
)
