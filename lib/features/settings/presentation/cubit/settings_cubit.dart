
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../notifications/domain/usecases/schedule_prayer_notifications.dart';
import '../../../notifications/domain/usecases/cancel_prayer_notifications.dart';
import '../../../notifications/domain/usecases/schedule_azkar_notifications.dart';
import '../../../notifications/domain/usecases/cancel_azkar_notifications.dart';

import '../../domain/usecases/get_notification_settings.dart';
import '../../domain/usecases/save_azkar_notifications.dart';
import '../../domain/usecases/save_prayer_notifications.dart';
import '../../domain/usecases/save_adhan_enabled.dart';

import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final GetNotificationSettings getNotificationSettings;
  final SavePrayerNotifications savePrayerNotifications;
  final SaveAzkarNotifications saveAzkarNotifications;
  final SaveAdhanEnabled saveAdhanEnabled;

  final SchedulePrayerNotifications schedulePrayerNotifications;
  final CancelPrayerNotifications cancelPrayerNotifications;
  final ScheduleAzkarNotifications scheduleAzkarNotifications;
  final CancelAzkarNotifications cancelAzkarNotifications;

  SettingsCubit({
    required this.getNotificationSettings,
    required this.savePrayerNotifications,
    required this.saveAzkarNotifications,
    required this.saveAdhanEnabled,
    required this.schedulePrayerNotifications,
    required this.cancelPrayerNotifications,
    required this.scheduleAzkarNotifications,
    required this.cancelAzkarNotifications,
  }) : super(const SettingsState());

  Future<void> loadSettings() async {
    emit(state.copyWith(
      status: SettingsStatus.loading,
      clearError: true,
    ));

    try {
      final settings = await getNotificationSettings();

      emit(SettingsState(
        status: SettingsStatus.success,
        prayerNotificationsEnabled: settings.prayerNotificationsEnabled,
        azkarNotificationsEnabled: settings.azkarNotificationsEnabled,
        adhanEnabled: settings.adhanEnabled,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> togglePrayerNotifications(bool enabled) async {
    try {
      await savePrayerNotifications(enabled);

      emit(state.copyWith(
        prayerNotificationsEnabled: enabled,
        clearError: true,
      ));

      await schedulePrayerNotifications();
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> toggleAzkarNotifications(bool enabled) async {
    try {
      await saveAzkarNotifications(enabled);

      emit(state.copyWith(
        azkarNotificationsEnabled: enabled,
        clearError: true,
      ));

      if (enabled) {
        await scheduleAzkarNotifications();
      } else {
        await cancelAzkarNotifications();
      }
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> toggleAdhan(bool enabled) async {
    try {
      await saveAdhanEnabled(enabled);

      emit(state.copyWith(
        adhanEnabled: enabled,
        clearError: true,
      ));

      // Refresh prayer notifications and Adhan alarms independently.
      await schedulePrayerNotifications();
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
