import '../../domain/entities/quran_local_ayah_entity.dart';

class QuranLocalAyahModel {
  final int surahNumber;
  final int ayahNumber;
  final String text;

  const QuranLocalAyahModel({
    required this.surahNumber,
    required this.ayahNumber,
    required this.text,
  });
  QuranLocalAyahEntity toEntity() {
    return QuranLocalAyahEntity(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      text: text,
    );
  }

  factory QuranLocalAyahModel.fromLine(String line) {
    final parts = line.split('|');

    if (parts.length != 3) {
      throw FormatException('Invalid Quran ayah line: $line');
    }

    return QuranLocalAyahModel(
      surahNumber: int.parse(parts[0]),
      ayahNumber: int.parse(parts[1]),
      text: parts[2],
    );
  }
}
