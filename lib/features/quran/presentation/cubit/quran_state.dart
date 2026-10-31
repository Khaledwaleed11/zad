import 'package:equatable/equatable.dart';

import '../../domain/entities/quran_ayah_entity.dart';
import '../../domain/entities/reciter_entity.dart';
import '../../domain/entities/surah_entity.dart';

enum QuranRequestStatus { initial, loading, success, failure }

enum QuranAudioStatus { initial, loading, playing, paused, completed, failure }

class QuranState extends Equatable {
  final QuranRequestStatus randomAyahStatus;
  final QuranRequestStatus surahsStatus;
  final QuranRequestStatus surahAyahsStatus;
  final QuranRequestStatus recitersStatus;

  final QuranAudioStatus audioStatus;

  final QuranAyahEntity? randomAyah;
  final List<SurahEntity> surahs;
  final List<QuranAyahEntity> surahAyahs;
  final List<ReciterEntity> reciters;

  final int? currentAyahNumber;
  final ReciterEntity? selectedReciter;

  final String randomAyahError;
  final String surahsError;
  final String surahAyahsError;
  final String recitersError;
  final String audioError;

  const QuranState({
    this.randomAyahStatus = QuranRequestStatus.initial,
    this.surahsStatus = QuranRequestStatus.initial,
    this.surahAyahsStatus = QuranRequestStatus.initial,
    this.recitersStatus = QuranRequestStatus.initial,
    this.audioStatus = QuranAudioStatus.initial,
    this.randomAyah,
    this.surahs = const [],
    this.surahAyahs = const [],
    this.reciters = const [],
    this.currentAyahNumber,
    this.selectedReciter,
    this.randomAyahError = '',
    this.surahsError = '',
    this.surahAyahsError = '',
    this.recitersError = '',
    this.audioError = '',
  });

  QuranState copyWith({
    QuranRequestStatus? randomAyahStatus,
    QuranRequestStatus? surahsStatus,
    QuranRequestStatus? surahAyahsStatus,
    QuranRequestStatus? recitersStatus,
    QuranAudioStatus? audioStatus,
    QuranAyahEntity? randomAyah,
    List<SurahEntity>? surahs,
    List<QuranAyahEntity>? surahAyahs,
    List<ReciterEntity>? reciters,
    int? currentAyahNumber,
    bool clearCurrentAyahNumber = false,
    ReciterEntity? selectedReciter,
    bool clearSelectedReciter = false,
    String? randomAyahError,
    String? surahsError,
    String? surahAyahsError,
    String? recitersError,
    String? audioError,
  }) {
    return QuranState(
      randomAyahStatus: randomAyahStatus ?? this.randomAyahStatus,
      surahsStatus: surahsStatus ?? this.surahsStatus,
      surahAyahsStatus: surahAyahsStatus ?? this.surahAyahsStatus,
      recitersStatus: recitersStatus ?? this.recitersStatus,
      audioStatus: audioStatus ?? this.audioStatus,
      randomAyah: randomAyah ?? this.randomAyah,
      surahs: surahs ?? this.surahs,
      surahAyahs: surahAyahs ?? this.surahAyahs,
      reciters: reciters ?? this.reciters,
      currentAyahNumber: clearCurrentAyahNumber
          ? null
          : currentAyahNumber ?? this.currentAyahNumber,
      selectedReciter: clearSelectedReciter
          ? null
          : selectedReciter ?? this.selectedReciter,
      randomAyahError: randomAyahError ?? this.randomAyahError,
      surahsError: surahsError ?? this.surahsError,
      surahAyahsError: surahAyahsError ?? this.surahAyahsError,
      recitersError: recitersError ?? this.recitersError,
      audioError: audioError ?? this.audioError,
    );
  }

  @override
  List<Object?> get props => [
    randomAyahStatus,
    surahsStatus,
    surahAyahsStatus,
    recitersStatus,
    audioStatus,
    randomAyah,
    surahs,
    surahAyahs,
    reciters,
    currentAyahNumber,
    selectedReciter,
    randomAyahError,
    surahsError,
    surahAyahsError,
    recitersError,
    audioError,
  ];
}
