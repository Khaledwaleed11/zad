import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/audio_recording_entity.dart';
import '../../domain/usecases/add_audio_recording.dart';
import '../../domain/usecases/delete_audio_recording.dart';
import '../../domain/usecases/get_audio_recordings.dart';
import 'audio_library_state.dart';

class AudioLibraryCubit extends Cubit<AudioLibraryState> {
  final AddAudioRecording addAudioRecording;
  final GetAudioRecordings getAudioRecordings;
  final DeleteAudioRecording deleteAudioRecording;

  AudioLibraryCubit({
    required this.addAudioRecording,
    required this.getAudioRecordings,
    required this.deleteAudioRecording,
  }) : super(const AudioLibraryState());

  Future<void> loadRecordings({
    AudioRecordingType? type,
  }) async {
    emit(state.copyWith(
      status: AudioLibraryStatus.loading,
      clearErrorMessage: true,
    ));

    try {
      final recordings = await getAudioRecordings(type: type);

      emit(state.copyWith(
        status: AudioLibraryStatus.success,
        recordings: recordings,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AudioLibraryStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<bool> addRecording({
    required String name,
    required AudioRecordingType type,
    int? surahNumber,
  }) async {
    emit(state.copyWith(
      isAdding: true,
      clearErrorMessage: true,
    ));

    try {
      final recording = await addAudioRecording(
        name: name,
        type: type,
        surahNumber: surahNumber,
      );

      if (recording == null) {
        emit(state.copyWith(isAdding: false));
        return false;
      }

      final recordings = await getAudioRecordings();

      emit(state.copyWith(
        status: AudioLibraryStatus.success,
        recordings: recordings,
        isAdding: false,
      ));

      return true;
    }catch (e, stackTrace) {
      debugPrint('Audio Library Error: $e');
      debugPrint('Stack Trace: $stackTrace');

      emit(state.copyWith(
        isAdding: false,
        errorMessage: e.toString(),
      ));

      return false;
    }
  }

  Future<void> deleteRecording(String id) async {
    emit(state.copyWith(
      deletingRecordingId: id,
      clearErrorMessage: true,
    ));

    try {
      await deleteAudioRecording(id);

      final recordings = await getAudioRecordings();

      emit(state.copyWith(
        status: AudioLibraryStatus.success,
        recordings: recordings,
        clearDeletingRecordingId: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        clearDeletingRecordingId: true,
        errorMessage: e.toString(),
      ));
    }
  }
}