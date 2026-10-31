import '../entities/qibla_location_entity.dart';

abstract class QiblaRepository {
  Future<QiblaLocationEntity> getCurrentPosition();

  double calculateQiblaDirection(
      double latitude,
      double longitude,
      );
}