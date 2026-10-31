import 'package:equatable/equatable.dart';

import '../../domain/entities/sebha_entity.dart';

enum SebhaStatus {
  initial,
  loading,
  success,
  failure,
}

class SebhaState extends Equatable {
  final SebhaStatus status;
  final int count;
  final int target;
  final String zikr;
  final List<String> customAzkar;
  final String? errorMessage;

  const SebhaState({
    this.status = SebhaStatus.initial,
    this.count = 0,
    this.target = 33,
    this.zikr = 'سبحان الله',
    this.customAzkar = const [],
    this.errorMessage,
  });

  bool get isCompleted => target > 0 && count >= target;

  double get progress {
    if (target <= 0) return 0;
    return (count / target).clamp(0.0, 1.0);
  }

  int get remaining => (target - count).clamp(0, target);

  SebhaState copyWith({
    SebhaStatus? status,
    int? count,
    int? target,
    String? zikr,
    List<String>? customAzkar,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SebhaState(
      status: status ?? this.status,
      count: count ?? this.count,
      target: target ?? this.target,
      zikr: zikr ?? this.zikr,
      customAzkar: customAzkar ?? this.customAzkar,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  factory SebhaState.fromEntity(SebhaEntity entity) {
    return SebhaState(
      status: SebhaStatus.success,
      count: entity.count,
      target: entity.target,
      zikr: entity.zikr,
    );
  }

  @override
  List<Object?> get props => [
    status,
    count,
    target,
    zikr,
    customAzkar,
    errorMessage,
  ];
}