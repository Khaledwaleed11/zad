import '../entities/sebha_entity.dart';

abstract class SebhaRepository {
  SebhaEntity getSebhaData();

  Future<void> saveSebhaData(SebhaEntity sebha);

  Future<void> resetCounter();
}