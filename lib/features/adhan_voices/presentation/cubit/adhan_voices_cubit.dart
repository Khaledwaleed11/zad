
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../notifications/domain/usecases/schedule_prayer_notifications.dart';
import '../../domain/usecases/cache_adhan_voice.dart';
import '../../domain/usecases/get_adhan_voices.dart';
import '../../domain/usecases/get_selected_adhan_voice.dart';
import '../../domain/usecases/save_selected_adhan_voice.dart';
import 'adhan_voices_state.dart';

class AdhanVoicesCubit extends Cubit<AdhanVoicesState> {
  final GetAdhanVoices getAdhanVoices;
  final GetSelectedAdhanVoice getSelectedAdhanVoice;
  final SaveSelectedAdhanVoice saveSelectedAdhanVoice;
  final CacheAdhanVoice cacheAdhanVoice;
  final SchedulePrayerNotifications schedulePrayerNotifications;

  AdhanVoicesCubit({
    required this.getAdhanVoices,
    required this.getSelectedAdhanVoice,
    required this.saveSelectedAdhanVoice,
    required this.cacheAdhanVoice,
    required this.schedulePrayerNotifications,
  }) : super(const AdhanVoicesState());

  Future<void> loadVoices() async {
    emit(state.copyWith(
      status: AdhanVoicesStatus.loading,
      clearErrorMessage: true,
    ));

    try {
      final voices = await getAdhanVoices();
      if (isClosed) return;

      final savedId = getSelectedAdhanVoice();
      final selectedId = voices.any((voice) => voice.id == savedId)
          ? savedId
          : null;

      emit(state.copyWith(
        status: AdhanVoicesStatus.success,
        voices: voices,
        selectedVoiceId: selectedId,
      ));
    } catch (e) {
      if (isClosed) return;

      emit(state.copyWith(
        status: AdhanVoicesStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> selectVoice(String voiceId) async {
    final selectedVoice = state.voices
        .where((voice) => voice.id == voiceId)
        .firstOrNull;

    if (selectedVoice == null) {
      emit(state.copyWith(
        errorMessage: 'Selected Adhan voice was not found.',
      ));
      return;
    }

    try {
      emit(state.copyWith(clearErrorMessage: true));

      await cacheAdhanVoice(
        voiceId: selectedVoice.id,
        audioUrl: selectedVoice.audioUrl,
      );

      if (isClosed) return;

      await saveSelectedAdhanVoice(voiceId);

      if (isClosed) return;

      emit(state.copyWith(
        selectedVoiceId: voiceId,
        clearErrorMessage: true,
      ));

      await schedulePrayerNotifications();
    } catch (e) {
      if (isClosed) return;

      emit(state.copyWith(
        errorMessage: 'Failed to select Adhan voice: $e',
      ));
    }
  }
}
