
import '../../domain/entities/quran_ayah_entity.dart';

class QuranAyahModel {
  final String text;
  final int number;
  final int numberInSurah;
  final String surahName;
  final int surahNumber;
  final String revelationType;

  const QuranAyahModel({
    required this.text,
    required this.number,
    required this.numberInSurah,
    required this.surahName,
    required this.surahNumber,
    required this.revelationType,
  });

  factory QuranAyahModel.fromJson(Map<String, dynamic> json) {
    final surah = json['surah'] is Map
        ? Map<String, dynamic>.from(json['surah'] as Map)
        : <String, dynamic>{};

    return QuranAyahModel(
      text: json['text'] as String? ?? '',
      number: json['number'] as int? ?? 0,
      numberInSurah: json['numberInSurah'] as int? ?? 0,
      surahName: surah['name'] as String? ?? '',
      surahNumber: surah['number'] as int? ?? 0,
      revelationType: surah['revelationType'] as String? ?? '',
    );
  }

  QuranAyahEntity toEntity() {
    return QuranAyahEntity(
      text: text,
      number: number,
      numberInSurah: numberInSurah,
      surahName: surahName,
      surahNumber: surahNumber,
      revelationType: revelationType,
    );
  }
}
