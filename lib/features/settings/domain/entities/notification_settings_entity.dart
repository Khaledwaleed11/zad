class NotificationSettingsEntity {
  final bool prayerNotificationsEnabled;
  final bool azkarNotificationsEnabled;
  final bool adhanEnabled;
  final bool salawatNotificationsEnabled;

  const NotificationSettingsEntity({
    required this.prayerNotificationsEnabled,
    required this.azkarNotificationsEnabled,
    required this.adhanEnabled,
    required this.salawatNotificationsEnabled,
  });
}