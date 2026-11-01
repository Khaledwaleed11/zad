
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
    private val salawatChannelName = "com.example.zad/salawat"

    private var azkarMethodChannel: MethodChannel? = null
    private var salawatMethodChannel: MethodChannel? = null

    private var pendingAzkarPayload: String? = null
    private var pendingSalawatPayload: String? = null

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

                        val adhanAlarms = alarms.map { alarm ->
                            val alarmId = (alarm["id"] as? Number)?.toInt()
                                ?: throw IllegalArgumentException("Invalid alarm ID")

                            val triggerAtMillis =
                                (alarm["time"] as? Number)?.toLong()
                                    ?: throw IllegalArgumentException("Invalid alarm time")

                            val audioPath = alarm["audioPath"] as? String
                                ?: throw IllegalArgumentException("Audio path is missing")

                            val prayerName =
                                alarm["prayerName"] as? String ?: "الصلاة"

                            AdhanAlarm(
                                id = alarmId,
                                triggerAtMillis = triggerAtMillis,
                                audioPath = audioPath,
                                prayerName = prayerName
                            )
                        }

                        AdhanAlarmScheduler.scheduleWindow(
                            context = applicationContext,
                            alarms = adhanAlarms
                        )

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
                    val pendingPayload = pendingAzkarPayload
                    val intentPayload =
                        intent?.getStringExtra("notification_payload")

                    val payload = pendingPayload
                        ?: intentPayload?.takeIf { it != "salawat" }

                    pendingAzkarPayload = null

                    if (payload != null) {
                        intent?.removeExtra("notification_payload")
                    }

                    result.success(payload)
                }

                else -> result.notImplemented()
            }
        }

        salawatMethodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            salawatChannelName
        )

        salawatMethodChannel?.setMethodCallHandler { call, result ->

            when (call.method) {

                "scheduleSalawatAlarm" -> {
                    try {
                        val nextTime =
                            SalawatAlarmScheduler.schedule(applicationContext)

                        result.success(nextTime)
                    } catch (exception: Exception) {
                        result.error(
                            "SALAWAT_SCHEDULE_ERROR",
                            exception.message,
                            null
                        )
                    }
                }

                "cancelSalawatAlarm" -> {
                    try {
                        SalawatAlarmScheduler.cancel(applicationContext)
                        result.success(true)
                    } catch (exception: Exception) {
                        result.error(
                            "SALAWAT_CANCEL_ERROR",
                            exception.message,
                            null
                        )
                    }
                }

                "getNextSalawatTime" -> {
                    result.success(
                        SalawatAlarmScheduler.getNextTime(applicationContext)
                    )
                }

                "getInitialSalawatPayload" -> {
                    val payload = pendingSalawatPayload
                        ?: intent?.getStringExtra("notification_payload")
                            ?.takeIf { it == "salawat" }

                    pendingSalawatPayload = null

                    if (payload == "salawat") {
                        intent?.removeExtra("notification_payload")
                    }

                    result.success(payload)
                }

                else -> result.notImplemented()
            }
        }

        pendingAzkarPayload?.let { payload ->
            azkarMethodChannel?.invokeMethod(
                "onAzkarNotificationTapped",
                payload
            )
            pendingAzkarPayload = null
        }

        pendingSalawatPayload?.let { payload ->
            salawatMethodChannel?.invokeMethod(
                "onSalawatNotificationTapped",
                payload
            )
            pendingSalawatPayload = null
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)

        val payload = intent.getStringExtra("notification_payload")
            ?: return

        when (payload) {

            "salawat" -> {
                val channel = salawatMethodChannel

                if (channel == null) {
                    pendingSalawatPayload = payload
                } else {
                    channel.invokeMethod(
                        "onSalawatNotificationTapped",
                        payload
                    )
                }
            }

            else -> {
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
    }
}
