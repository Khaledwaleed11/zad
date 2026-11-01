import '../repositories/notification_repository.dart';

class ScheduleSalawatNotifications {
  final NotificationRepository repository;

  ScheduleSalawatNotifications(this.repository);

  Future<void> call() {
    return repository.scheduleSalawatNotifications();
  }
}