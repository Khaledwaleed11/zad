import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/audio_preview_repository.dart';
import '../../domain/usecases/pause_audio_preview.dart';
import '../../domain/usecases/play_audio_preview.dart';
import '../../domain/usecases/resume_audio_preview.dart';
import '../../domain/usecases/stop_audio_preview.dart';
import 'audio_preview_state.dart';

class AudioPreviewCubit extends Cubit<AudioPreviewState> {
  final PlayAudioPreview playAudioPreview;
  final PauseAudioPreview pauseAudioPreview;
  final ResumeAudioPreview resumeAudioPreview;
  final StopAudioPreview stopAudioPreview;
  final AudioPreviewRepository repository;

  StreamSubscription<AudioPreviewStatus>? _statusSubscription;

  AudioPreviewCubit({
    required this.playAudioPreview,
    required this.pauseAudioPreview,
    required this.resumeAudioPreview,
    required this.stopAudioPreview,
    required this.repository,
  }) : super(const AudioPreviewState()) {
    _listenToPlayer();
  }

  void _listenToPlayer() {
    _statusSubscription = repository.statusStream.listen(
          (status) {
        if (isClosed) return;

        emit(state.copyWith(status: status));
      },
      onError: (error) {
        if (isClosed) return;

        emit(state.copyWith(
          errorMessage: error.toString(),
        ));
      },
    );
  }

  Future<void> play(String filePath) async {
    try {
      emit(state.copyWith(
        status: AudioPreviewStatus.loading,
        currentFilePath: filePath,
        clearErrorMessage: true,
      ));

      await playAudioPreview(filePath);
    } catch (e) {
      emit(state.copyWith(
        status: AudioPreviewStatus.idle,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> pause() async {
    try {
      await pauseAudioPreview();
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> resume() async {
    try {
      await resumeAudioPreview();
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> stop() async {
    try {
      await stopAudioPreview();

      emit(state.copyWith(
        status: AudioPreviewStatus.idle,
        clearCurrentFilePath: true,
        clearErrorMessage: true,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _statusSubscription?.cancel();

    return super.close();
  }
}