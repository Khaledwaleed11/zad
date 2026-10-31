import '../repositories/qibla_repository.dart';

class CalculateQiblaDirection {
  final QiblaRepository repository;

  CalculateQiblaDirection(this.repository);

  double call(double latitude, double longitude) {
    return repository.calculateQiblaDirection(
      latitude,
      longitude,
    );
  }
}