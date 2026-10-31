import '../entities/sebha_entity.dart';
import '../repositories/sebha_repository.dart';

class GetSebhaData {
  final SebhaRepository repository;

  GetSebhaData(this.repository);

  SebhaEntity call() {
    return repository.getSebhaData();
  }
}