import 'package:equatable/equatable.dart';

import '../../domain/entities/audio_recording_entity.dart';

enum AudioLibraryStatus {
  initial,
  loading,
  success,
  failure,
}

class AudioLibraryState extends Equatable {
  final AudioLibraryStatus status;
  final List<AudioRecordingEntity> recordings;
  final bool isAdding;
  final String? deletingRecordingId;
  final String? errorMessage;

  const AudioLibraryState({
    this.status = AudioLibraryStatus.initial,
    this.recordings = const [],
    this.isAdding = false,
    this.deletingRecordingId,
    this.errorMessage,
  });

  AudioLibraryState copyWith({
    AudioLibraryStatus? status,
    List<AudioRecordingEntity>? recordings,
    bool? isAdding,
    String? deletingRecordingId,
    bool clearDeletingRecordingId = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AudioLibraryState(
      status: status ?? this.status,
      recordings: recordings ?? this.recordings,
      isAdding: isAdding ?? this.isAdding,
      deletingRecordingId: clearDeletingRecordingId
          ? null
          : deletingRecordingId ?? this.deletingRecordingId,
      errorMessage:
      clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    recordings,
    isAdding,
    deletingRecordingId,
    errorMessage,
  ];
}