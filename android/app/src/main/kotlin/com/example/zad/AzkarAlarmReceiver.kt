
package com.example.zad

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class AzkarAlarmReceiver : BroadcastReceiver() {

    companion object {
        private const val CHANNEL_ID = "zad_azkar_custom_v2"
        private const val TAG = "AzkarReceiver"
        private const val NOTIFICATION_COLOR = "#A88746"
        private const val NOTIFICATION_SUMMARY =
            "ZAD | رفيقك إلى الطمأنينة"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val payload = intent.getStringExtra("payload") ?: return
        val alarmId = intent.getIntExtra("alarm_id", -1)

        val title: String
        val body: String

        when (payload) {
            "azkar_morning" -> {
                title = "أذكار الصباح 🌤️"
                body = "حان الآن وقت أذكار الصباح"
            }

            "azkar_evening" -> {
                title = "أذكار المساء 🌙"
                body = "حان الآن وقت أذكار المساء"
            }

            "azkar_sleep" -> {
                title = "أذكار النوم 🌙"
                body = "لا تنسَ أذكار النوم"
            }

            else -> return
        }

        try {
            createNotificationChannel(context)

            val openIntent = Intent(
                context,
                MainActivity::class.java
            ).apply {
                flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP
                putExtra("notification_payload", payload)
            }

            val contentPendingIntent = PendingIntent.getActivity(
                context,
                alarmId,
                openIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or
                        PendingIntent.FLAG_IMMUTABLE
            )

            val notification = NotificationCompat.Builder(
                context,
                CHANNEL_ID
            )
                .setSmallIcon(R.drawable.ic_notification)
                .setColor(Color.parseColor(NOTIFICATION_COLOR))
                .setContentTitle(title)
                .setContentText(body)
                .setStyle(
                    NotificationCompat.BigTextStyle()
                        .setBigContentTitle(title)
                        .bigText(body)
                        .setSummaryText(NOTIFICATION_SUMMARY)
                )
                .setContentIntent(contentPendingIntent)
                .setAutoCancel(true)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setCategory(NotificationCompat.CATEGORY_REMINDER)
                .build()

            val notificationManager =
                NotificationManagerCompat.from(context)

            Log.d(
                TAG,
                "Notifications enabled: ${notificationManager.areNotificationsEnabled()}"
            )

            Log.d(TAG, "Posting notification ID: $alarmId")

            notificationManager.notify(alarmId, notification)

            Log.d(TAG, "Notification posted successfully")

        } catch (exception: Exception) {
            Log.e(TAG, "Failed to show notification", exception)
        }

        AzkarAlarmScheduler.scheduleNextById(context, alarmId)
    }

    private fun createNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val soundUri = Uri.parse(
            "android.resource://${context.packageName}/${R.raw.zad_notification}"
        )

        val audioAttributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_NOTIFICATION)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()

        val channel = NotificationChannel(
            CHANNEL_ID,
            "ZAD Custom Azkar",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Custom daily Azkar reminders"
            enableVibration(true)
            setSound(soundUri, audioAttributes)
        }

        val manager = context.getSystemService(
            Context.NOTIFICATION_SERVICE
        ) as NotificationManager

        manager.createNotificationChannel(channel)

        val actualChannel = manager.getNotificationChannel(CHANNEL_ID)

        Log.d(TAG, "Channel ID: ${actualChannel?.id}")
        Log.d(TAG, "Channel Importance: ${actualChannel?.importance}")
        Log.d(TAG, "Channel Sound: ${actualChannel?.sound}")
        Log.d(
            TAG,
            "Channel Blocked: ${
                actualChannel?.importance == NotificationManager.IMPORTANCE_NONE
            }"
        )
    }
}
