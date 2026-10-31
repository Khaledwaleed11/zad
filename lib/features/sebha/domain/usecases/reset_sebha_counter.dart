import '../repositories/sebha_repository.dart';

class ResetSebhaCounter {
  final SebhaRepository repository;

  ResetSebhaCounter(this.repository);

  Future<void> call() {
    return repository.resetCounter();
  }
}