
import '../repositories/notification_repository.dart';

class CancelAzkarNotifications {
  final NotificationRepository repository;

  CancelAzkarNotifications(this.repository);

  Future<void> call() {
    return repository.cancelAzkarNotifications();
  }
}
