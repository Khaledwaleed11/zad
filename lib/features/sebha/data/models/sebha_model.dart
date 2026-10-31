import '../../domain/entities/sebha_entity.dart';

class SebhaModel extends SebhaEntity {
  const SebhaModel({
    required super.count,
    required super.target,
    required super.zikr,
  });

  factory SebhaModel.fromStorage({
    required int count,
    required int target,
    required String zikr,
  }) {
    return SebhaModel(
      count: count,
      target: target,
      zikr: zikr,
    );
  }

  SebhaEntity toEntity() {
    return SebhaEntity(
      count: count,
      target: target,
      zikr: zikr,
    );
  }
}