import 'package:equatable/equatable.dart';

import '../../domain/entities/azkar_entity.dart';

enum AzkarStatus {
  initial,
  loading,
  success,
  failure,
}

class AzkarState extends Equatable {
  final AzkarStatus status;
  final List<AzkarEntity> azkar;
  final String? errorMessage;

  const AzkarState({
    this.status = AzkarStatus.initial,
    this.azkar = const [],
    this.errorMessage,
  });

  AzkarState copyWith({
    AzkarStatus? status,
    List<AzkarEntity>? azkar,
    String? errorMessage,
  }) {
    return AzkarState(
      status: status ?? this.status,
      azkar: azkar ?? this.azkar,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    azkar,
    errorMessage,
  ];
}