
import '../repositories/notification_repository.dart';

class CancelPrayerNotifications {
  final NotificationRepository repository;

  CancelPrayerNotifications(this.repository);

  Future<void> call() {
    return repository.cancelPrayerNotifications();
  }
}
