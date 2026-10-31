
import '../repositories/notification_repository.dart';

class ScheduleAzkarNotifications {
  final NotificationRepository repository;

  ScheduleAzkarNotifications(this.repository);

  Future<void> call() {
    return repository.scheduleAzkarNotifications();
  }
}
