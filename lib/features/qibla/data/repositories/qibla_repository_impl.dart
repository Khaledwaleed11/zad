import 'dart:math' as math;

import '../../domain/repositories/qibla_repository.dart';
import '../../domain/entities/qibla_location_entity.dart';
import '../datasources/qibla_location_data_source.dart';

class QiblaRepositoryImpl implements QiblaRepository {
  final QiblaLocationDataSource locationDataSource;

  QiblaRepositoryImpl({
    required this.locationDataSource,
  });

  static const double _kaabaLatitude = 21.4225;
  static const double _kaabaLongitude = 39.8262;

  @override
  Future<QiblaLocationEntity> getCurrentPosition() {
    return locationDataSource.getCurrentPosition();
  }

  @override
  double calculateQiblaDirection(
      double latitude,
      double longitude,
      ) {
    final userLatitude = _degreesToRadians(latitude);
    final userLongitude = _degreesToRadians(longitude);

    final kaabaLat = _degreesToRadians(_kaabaLatitude);
    final kaabaLong = _degreesToRadians(_kaabaLongitude);

    final deltaLongitude = kaabaLong - userLongitude;

    final y = math.sin(deltaLongitude);

    final x =
        math.cos(userLatitude) * math.sin(kaabaLat) -
            math.sin(userLatitude) *
                math.cos(kaabaLat) *
                math.cos(deltaLongitude);

    double bearing = math.atan2(y, x);

    bearing = _radiansToDegrees(bearing);
    bearing = (bearing + 360) % 360;

    return bearing;
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  double _radiansToDegrees(double radians) {
    return radians * 180 / math.pi;
  }
}