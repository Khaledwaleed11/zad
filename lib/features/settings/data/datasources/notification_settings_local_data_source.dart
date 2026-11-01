import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/storage_constants.dart';
import '../models/notification_settings_model.dart';

abstract class NotificationSettingsLocalDataSource {
  Future<NotificationSettingsModel> getNotificationSettings();
  Future<void> savePrayerNotifications(bool enabled);
  Future<void> saveAzkarNotifications(bool enabled);
  Future<void> saveAdhanEnabled(bool enabled);
  Future<void> saveSalawatNotifications(bool enabled);
}

class NotificationSettingsLocalDataSourceImpl
    implements NotificationSettingsLocalDataSource {
  static const String _boxName = StorageConstants.settingsBox;
  static const String _prayerKey = 'prayerNotificationsEnabled';
  static const String _azkarKey = 'azkarNotificationsEnabled';
  static const String _adhanKey = 'adhanEnabled';
  static const String _salawatKey = 'salawatNotificationsEnabled';

  @override
  Future<NotificationSettingsModel> getNotificationSettings() async {
    final box = await Hive.openBox(_boxName);

    return NotificationSettingsModel.fromHive(
      prayerNotificationsEnabled: box.get(
        _prayerKey,
        defaultValue: true,
      ) as bool,
      azkarNotificationsEnabled: box.get(
        _azkarKey,
        defaultValue: true,
      ) as bool,
      adhanEnabled: box.get(
        _adhanKey,
        defaultValue: false,
      ) as bool,
      salawatNotificationsEnabled: box.get(
        _salawatKey,
        defaultValue: false,
      ) as bool,
    );
  }

  @override
  Future<void> savePrayerNotifications(bool enabled) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_prayerKey, enabled);
  }

  @override
  Future<void> saveAzkarNotifications(bool enabled) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_azkarKey, enabled);
  }

  @override
  Future<void> saveAdhanEnabled(bool enabled) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_adhanKey, enabled);
  }

  @override
  Future<void> saveSalawatNotifications(bool enabled) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_salawatKey, enabled);
  }
}