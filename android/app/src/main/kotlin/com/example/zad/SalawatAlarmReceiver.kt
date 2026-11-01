
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
import androidx.core.app.NotificationCompat

class SalawatAlarmReceiver : BroadcastReceiver() {

    companion object {
        private const val CHANNEL_ID = "zad_salawat_channel_v1"
        private const val NOTIFICATION_ID = 301

        private const val NOTIFICATION_COLOR = "#A88746"
        private const val NOTIFICATION_SUMMARY =
            "ZAD | رفيقك إلى الطمأنينة"

        private const val NOTIFICATION_BODY =
            "اللهم صلِّ وسلم على نبينا محمد ﷺ ❤️"
    }

    override fun onReceive(context: Context, intent: Intent?) {
        if (!SalawatAlarmScheduler.isEnabled(context)) return

        createNotificationChannel(context)

        val openAppIntent = Intent(
            context,
            MainActivity::class.java
        ).apply {
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP

            putExtra("notification_payload", "salawat")
        }

        val contentPendingIntent = PendingIntent.getActivity(
            context,
            NOTIFICATION_ID,
            openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or
                    PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification)
            .setColor(Color.parseColor(NOTIFICATION_COLOR))
            .setContentTitle("صلِّ على النبي ﷺ")
            .setContentText(NOTIFICATION_BODY)
            .setStyle(
                NotificationCompat.BigTextStyle()
                    .setBigContentTitle("صلِّ على النبي ﷺ")
                    .bigText(NOTIFICATION_BODY)
                    .setSummaryText(NOTIFICATION_SUMMARY)
            )
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_REMINDER)
            .setAutoCancel(true)
            .setContentIntent(contentPendingIntent)
            .setSound(
                Uri.parse(
                    "android.resource://${context.packageName}/raw/zad_salat_alanabi"
                )
            )
            .build()

        val manager = context.getSystemService(
            Context.NOTIFICATION_SERVICE
        ) as NotificationManager

        manager.notify(NOTIFICATION_ID, notification)

        SalawatAlarmScheduler.scheduleNext(context)
    }

    private fun createNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val manager = context.getSystemService(
            Context.NOTIFICATION_SERVICE
        ) as NotificationManager

        if (manager.getNotificationChannel(CHANNEL_ID) != null) return

        val soundUri = Uri.parse(
            "android.resource://${context.packageName}/raw/zad_salat_alanabi"
        )

        val audioAttributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_NOTIFICATION)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()

        val channel = NotificationChannel(
            CHANNEL_ID,
            "Salawat Notifications",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Daily salawat reminders"
            enableVibration(true)
            setSound(soundUri, audioAttributes)
        }

        manager.createNotificationChannel(channel)
    }
}
