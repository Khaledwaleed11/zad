import '../repositories/qibla_repository.dart';
import '../entities/qibla_location_entity.dart';

class GetCurrentPosition {
  final QiblaRepository repository;

  GetCurrentPosition(this.repository);

  Future<QiblaLocationEntity> call() {
    return repository.getCurrentPosition();
  }
}