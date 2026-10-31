
import '../repositories/notification_repository.dart';

class SchedulePrayerNotifications {
  final NotificationRepository repository;

  SchedulePrayerNotifications(this.repository);

  Future<void> call() {
    return repository.schedulePrayerNotifications();
  }
}
