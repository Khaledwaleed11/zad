import '../repositories/notification_repository.dart';

class CancelSalawatNotifications {
  final NotificationRepository repository;

  CancelSalawatNotifications(this.repository);

  Future<void> call() {
    return repository.cancelSalawatNotifications();
  }
}