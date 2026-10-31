
package com.example.zad

import android.app.AlarmManager
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channelName = "com.example.zad/adhan"
    private val azkarChannelName = "com.example.zad/azkar"

    private var azkarMethodChannel: MethodChannel? = null
    private var pendingAzkarPayload: String? = null

    private fun hasExactAlarmPermission(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            return true
        }

        val alarmManager = getSystemService(
            ALARM_SERVICE
        ) as AlarmManager

        return alarmManager.canScheduleExactAlarms()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Existing Adhan channel
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "canScheduleExactAlarms" -> {
                    result.success(hasExactAlarmPermission())
                }

                "requestExactAlarmPermission" -> {
                    try {
                        if (hasExactAlarmPermission()) {
                            result.success(true)
                        } else if (
                            Build.VERSION.SDK_INT >= Build.VERSION_CODES.S
                        ) {
                            val intent = Intent(
                                Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM,
                                Uri.parse("package:$packageName")
                            )

                            startActivity(intent)
                            result.success(true)
                        } else {
                            result.success(true)
                        }
                    } catch (exception: Exception) {
                        result.error(
                            "EXACT_ALARM_PERMISSION_ERROR",
                            exception.message,
                            null
                        )
                    }
                }

                "scheduleAdhanAlarms" -> {
                    try {
                        val alarms =
                            call.argument<List<Map<String, Any>>>("alarms")
                                ?: throw IllegalArgumentException(
                                    "Alarms list is missing"
                                )

                        AdhanAlarmScheduler.cancelAll(applicationContext)

                        for (alarm in alarms) {
                            val alarmId = (alarm["id"] as? Number)?.toInt()
                                ?: throw IllegalArgumentException("Invalid alarm ID")

                            val triggerAtMillis =
                                (alarm["time"] as? Number)?.toLong()
                                    ?: throw IllegalArgumentException("Invalid alarm time")

                            val audioPath = alarm["audioPath"] as? String
                                ?: throw IllegalArgumentException("Audio path is missing")

                            val prayerName =
                                alarm["prayerName"] as? String ?: "الصلاة"

                            AdhanAlarmScheduler.schedule(
                                context = applicationContext,
                                alarmId = alarmId,
                                triggerAtMillis = triggerAtMillis,
                                audioPath = audioPath,
                                prayerName = prayerName
                            )
                        }

                        result.success(true)
                    } catch (exception: Exception) {
                        result.error(
                            "ADHAN_SCHEDULE_ERROR",
                            exception.message,
                            null
                        )
                    }
                }

                "cancelAdhanAlarms" -> {
                    try {
                        AdhanAlarmScheduler.cancelAll(applicationContext)
                        result.success(true)
                    } catch (exception: Exception) {
                        result.error(
                            "ADHAN_CANCEL_ERROR",
                            exception.message,
                            null
                        )
                    }
                }

                "stopAdhan" -> {
                    try {
                        val serviceIntent = Intent(
                            applicationContext,
                            AdhanPlaybackService::class.java
                        )

                        applicationContext.stopService(serviceIntent)
                        result.success(true)
                    } catch (exception: Exception) {
                        result.error(
                            "ADHAN_STOP_ERROR",
                            exception.message,
                            null
                        )
                    }
                }

                else -> result.notImplemented()
            }
        }

        // New Azkar channel
        azkarMethodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            azkarChannelName
        )

        azkarMethodChannel?.setMethodCallHandler { call, result ->

            when (call.method) {

                "scheduleAzkarAlarms" -> {
                    try {
                        AzkarAlarmScheduler.scheduleAll(applicationContext)
                        result.success(true)
                    } catch (exception: Exception) {
                        result.error(
                            "AZKAR_SCHEDULE_ERROR",
                            exception.message,
                            null
                        )
                    }
                }

                "cancelAzkarAlarms" -> {
                    try {
                        AzkarAlarmScheduler.cancelAll(applicationContext)
                        result.success(true)
                    } catch (exception: Exception) {
                        result.error(
                            "AZKAR_CANCEL_ERROR",
                            exception.message,
                            null
                        )
                    }
                }

                "showTestAzkarNotification" -> {
                    try {
                        val testIntent = Intent(
                            applicationContext,
                            AzkarAlarmReceiver::class.java
                        ).apply {
                            action = "com.example.zad.AZKAR_TEST"
                            putExtra("payload", "azkar_morning")
                            putExtra("alarm_id", 900201)
                        }

                        applicationContext.sendBroadcast(testIntent)
                        result.success(true)
                    } catch (exception: Exception) {
                        result.error(
                            "AZKAR_TEST_ERROR",
                            exception.message,
                            null
                        )
                    }
                }

                "getInitialAzkarPayload" -> {
                    val payload = pendingAzkarPayload
                        ?: intent?.getStringExtra("notification_payload")

                    pendingAzkarPayload = null
                    intent?.removeExtra("notification_payload")

                    result.success(payload)
                }

                else -> result.notImplemented()
            }
        }

        // Deliver a notification tap that arrived before the channel was ready.
        pendingAzkarPayload?.let { payload ->
            azkarMethodChannel?.invokeMethod(
                "onAzkarNotificationTapped",
                payload
            )
            pendingAzkarPayload = null
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)

        val payload = intent.getStringExtra("notification_payload")
            ?: return

        val channel = azkarMethodChannel

        if (channel == null) {
            pendingAzkarPayload = payload
        } else {
            channel.invokeMethod(
                "onAzkarNotificationTapped",
                payload
            )
        }
    }
}
