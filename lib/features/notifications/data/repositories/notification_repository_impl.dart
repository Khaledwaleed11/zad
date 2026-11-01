import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_local_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDataSource localDataSource;

  NotificationRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<void> schedulePrayerNotifications() async {
    await localDataSource.schedulePrayerNotifications();
  }

  @override
  Future<void> cancelPrayerNotifications() async {
    await localDataSource.cancelPrayerNotifications();
  }

  @override
  Future<void> scheduleAzkarNotifications() async {
    await localDataSource.scheduleAzkarNotifications();
  }

  @override
  Future<void> cancelAzkarNotifications() async {
    await localDataSource.cancelAzkarNotifications();
  }

  @override
  Future<void> scheduleSalawatNotifications() async {
    await localDataSource.scheduleSalawatNotifications();
  }

  @override
  Future<void> cancelSalawatNotifications() async {
    await localDataSource.cancelSalawatNotifications();
  }
}