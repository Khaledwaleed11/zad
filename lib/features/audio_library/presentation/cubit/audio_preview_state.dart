import 'package:equatable/equatable.dart';

import '../../domain/repositories/audio_preview_repository.dart';

class AudioPreviewState extends Equatable {
  final AudioPreviewStatus status;
  final String? currentFilePath;
  final String? errorMessage;

  const AudioPreviewState({
    this.status = AudioPreviewStatus.idle,
    this.currentFilePath,
    this.errorMessage,
  });

  AudioPreviewState copyWith({
    AudioPreviewStatus? status,
    String? currentFilePath,
    bool clearCurrentFilePath = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AudioPreviewState(
      status: status ?? this.status,
      currentFilePath: clearCurrentFilePath
          ? null
          : currentFilePath ?? this.currentFilePath,
      errorMessage:
      clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentFilePath,
    errorMessage,
  ];
}