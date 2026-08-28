import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';

class QiblaService {


  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;


  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        throw Exception('Location permission was denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission is permanently denied.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }


  double calculateQiblaDirection(double latitude, double longitude) {
    final userLatitude = _degreesToRadians(latitude);

    final userLongitude = _degreesToRadians(longitude);

    final kaabaLat = _degreesToRadians(kaabaLatitude);

    final kaabaLong = _degreesToRadians(kaabaLongitude);

    final deltaLongitude = kaabaLong - userLongitude;

    final y = math.sin(deltaLongitude);

    final x =
        math.cos(userLatitude) * math.sin(kaabaLat) -
        math.sin(userLatitude) * math.cos(kaabaLat) * math.cos(deltaLongitude);

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
