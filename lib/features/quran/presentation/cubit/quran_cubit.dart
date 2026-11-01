import '../../../../core/constants/storage_constants.dart';
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';

import '../../data/datasources/quran_audio_data_source.dart';
import '../../domain/entities/quran_ayah_entity.dart';
import '../../domain/entities/reciter_entity.dart';
import '../../domain/usecases/get_all_reciters.dart';
import '../../domain/usecases/get_all_surahs.dart';
import '../../domain/usecases/get_random_ayah.dart';
import '../../domain/usecases/get_surah_ayahs.dart';
import 'quran_state.dart';

class QuranCubit extends Cubit<QuranState> {
  final GetRandomAyah getRandomAyah;
  final GetAllSurahs getAllSurahs;
  final GetSurahAyahs getSurahAyahs;
  final GetAllReciters getAllReciters;
  final QuranAudioDataSource audioDataSource;

  static const String _reciterKey = 'quranReciterIdentifier';

  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<int?>? _currentAyahSubscription;
  bool _ownsAudio = false;

  QuranCubit({
    required this.getRandomAyah,
    required this.getAllSurahs,
    required this.getSurahAyahs,
    required this.getAllReciters,
    required this.audioDataSource,
  }) : super(const QuranState());
  void startAudioListening({bool ownsAudio = false}) {
    if (isClosed || _playerStateSubscription != null) return;

    _ownsAudio = ownsAudio;
    _listenToAudio();
  }
  void _listenToAudio() {
    _playerStateSubscription =
        audioDataSource.playerStateStream.listen((playerState) {
          if (isClosed) return;

          final status = switch (playerState.processingState) {
            ProcessingState.idle => QuranAudioStatus.initial,
            ProcessingState.loading => QuranAudioStatus.loading,
            ProcessingState.buffering => playerState.playing
                ? QuranAudioStatus.playing
                : QuranAudioStatus.loading,
            ProcessingState.completed => QuranAudioStatus.completed,
            ProcessingState.ready => playerState.playing
                ? QuranAudioStatus.playing
                : QuranAudioStatus.paused,
          };

          emit(state.copyWith(audioStatus: status));
        });

    _currentAyahSubscription =
        audioDataSource.currentAyahNumberStream.listen((ayahNumber) {
          if (isClosed) return;
          print('CUBIT RECEIVED AYAH: $ayahNumber');
          emit(
            state.copyWith(
              currentAyahNumber: ayahNumber,
              clearCurrentAyahNumber: ayahNumber == null,
            ),
          );
        });
  }

  // Random Ayah

  Future<void> loadRandomAyah() async {
    emit(
      state.copyWith(
        randomAyahStatus: QuranRequestStatus.loading,
        randomAyahError: '',
      ),
    );

    try {
      final ayah = await getRandomAyah();

      emit(
        state.copyWith(
          randomAyah: ayah,
          randomAyahStatus: QuranRequestStatus.success,
          randomAyahError: '',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          randomAyahStatus: QuranRequestStatus.failure,
          randomAyahError: e.toString(),
        ),
      );
    }
  }

  // Surahs

  Future<void> loadSurahs() async {
    emit(
      state.copyWith(
        surahsStatus: QuranRequestStatus.loading,
        surahsError: '',
      ),
    );

    try {
      final surahs = await getAllSurahs();

      emit(
        state.copyWith(
          surahs: surahs,
          surahsStatus: QuranRequestStatus.success,
          surahsError: '',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          surahsStatus: QuranRequestStatus.failure,
          surahsError: e.toString(),
        ),
      );
    }
  }

  Future<void> loadSurahAyahs(int surahNumber) async {
    emit(
      state.copyWith(
        surahAyahsStatus: QuranRequestStatus.loading,
        surahAyahsError: '',
      ),
    );

    try {
      final ayahs = await getSurahAyahs(surahNumber);

      emit(
        state.copyWith(
          surahAyahs: ayahs,
          surahAyahsStatus: QuranRequestStatus.success,
          surahAyahsError: '',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          surahAyahsStatus: QuranRequestStatus.failure,
          surahAyahsError: e.toString(),
        ),
      );
    }
  }

  // Reciters

  Future<void> loadReciters() async {
    emit(
      state.copyWith(
        recitersStatus: QuranRequestStatus.loading,
        recitersError: '',
      ),
    );

    try {
      // جلب جميع القراء من MP3Quran بدون فلترة.
      final reciters = await getAllReciters();

      if (reciters.isEmpty) {
        throw Exception('No reciters are available.');
      }

      final settingsBox = Hive.box(StorageConstants.settingsBox);
      final savedIdentifier = settingsBox.get(
        _reciterKey,
        defaultValue: '',
      ) as String;

      ReciterEntity? selectedReciter;

      // الحفاظ على الاختيار الحالي.
      if (state.selectedReciter != null) {
        selectedReciter = _findReciter(
          reciters,
          state.selectedReciter!.identifier,
        );
      }

      // استعادة القارئ المحفوظ.
      selectedReciter ??= _findReciter(
        reciters,
        savedIdentifier,
      );

      // اختيار أول قارئ عند عدم وجود اختيار صالح.
      selectedReciter ??= reciters.first;

      // تمرير بيانات القارئ كاملة إلى مصدر الصوت.
      await audioDataSource.selectReciter(selectedReciter);

      // تحديث الاختيار المحفوظ.
      if (savedIdentifier != selectedReciter.identifier) {
        await settingsBox.put(
          _reciterKey,
          selectedReciter.identifier,
        );
      }

      emit(
        state.copyWith(
          reciters: reciters,
          selectedReciter: selectedReciter,
          recitersStatus: QuranRequestStatus.success,
          recitersError: '',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          recitersStatus: QuranRequestStatus.failure,
          recitersError: e.toString(),
        ),
      );
    }
  }

  ReciterEntity? _findReciter(
      List<ReciterEntity> reciters,
      String identifier,
      ) {
    for (final reciter in reciters) {
      if (reciter.identifier == identifier) {
        return reciter;
      }
    }

    return null;
  }

  Future<void> selectReciter(ReciterEntity reciter) async {
    if (state.selectedReciter?.identifier == reciter.identifier) {
      return;
    }

    try {
      await audioDataSource.selectReciter(reciter);

      emit(
        state.copyWith(
          selectedReciter: reciter,
          audioStatus: QuranAudioStatus.initial,
          audioError: '',
          clearCurrentAyahNumber: true,
        ),
      );

      await Hive.box(StorageConstants.settingsBox).put(
        _reciterKey,
        reciter.identifier,
      );
    } catch (e) {
      emit(
        state.copyWith(
          audioStatus: QuranAudioStatus.failure,
          audioError: e.toString(),
        ),
      );
    }
  }

  // Audio

  Future<void> toggleAyahAudio(int ayahNumber) async {
    try {
      final ayah = state.surahAyahs.firstWhere(
            (item) => item.number == ayahNumber,
      );

      emit(
        state.copyWith(
          audioStatus: QuranAudioStatus.loading,
          audioError: '',
        ),
      );

      await audioDataSource.toggleAyah(ayah);
    } catch (e) {
      emit(
        state.copyWith(
          audioStatus: QuranAudioStatus.failure,
          audioError: e.toString(),
        ),
      );
    }
  }

  Future<void> playSurahAudio(
      List<QuranAyahEntity> ayahs,
      ) async {
    if (ayahs.isEmpty) return;

    try {
      emit(
        state.copyWith(
          audioStatus: QuranAudioStatus.loading,
          audioError: '',
        ),
      );

      await audioDataSource.playSurah(ayahs);
    } catch (e) {
      emit(
        state.copyWith(
          audioStatus: QuranAudioStatus.failure,
          audioError: e.toString(),
        ),
      );
    }
  }

  Future<void> pauseAudio() async {
    try {
      await audioDataSource.pause();
    } catch (e) {
      emit(
        state.copyWith(
          audioStatus: QuranAudioStatus.failure,
          audioError: e.toString(),
        ),
      );
    }
  }

  Future<void> resumeAudio() async {
    try {
      await audioDataSource.resume();
    } catch (e) {
      emit(
        state.copyWith(
          audioStatus: QuranAudioStatus.failure,
          audioError: e.toString(),
        ),
      );
    }
  }

  Future<void> stopAudio() async {
    try {
      await audioDataSource.stop();

      emit(
        state.copyWith(
          audioStatus: QuranAudioStatus.initial,
          clearCurrentAyahNumber: true,
          audioError: '',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          audioStatus: QuranAudioStatus.failure,
          audioError: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _playerStateSubscription?.cancel();
    await _currentAyahSubscription?.cancel();

    if (_ownsAudio) {
      await audioDataSource.stop();
    }

    return super.close();
  }
}
