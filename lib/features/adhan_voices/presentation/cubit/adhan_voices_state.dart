
import 'package:equatable/equatable.dart';

import '../../domain/entities/adhan_voice_entity.dart';

enum AdhanVoicesStatus {
  initial,
  loading,
  success,
  failure,
}

class AdhanVoicesState extends Equatable {
  final AdhanVoicesStatus status;
  final List<AdhanVoiceEntity> voices;
  final String? errorMessage;
  final String? selectedVoiceId;

  const AdhanVoicesState({
    this.status = AdhanVoicesStatus.initial,
    this.voices = const [],
    this.errorMessage,
    this.selectedVoiceId,
  });

  AdhanVoicesState copyWith({
    AdhanVoicesStatus? status,
    List<AdhanVoiceEntity>? voices,
    String? errorMessage,
    String? selectedVoiceId,
    bool clearErrorMessage = false,
  }) {
    return AdhanVoicesState(
      status: status ?? this.status,
      voices: voices ?? this.voices,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      selectedVoiceId: selectedVoiceId ?? this.selectedVoiceId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    voices,
    errorMessage,
    selectedVoiceId,
  ];
}
