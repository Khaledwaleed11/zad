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
    final rawSurah = json['surah'];

    final Map<String, dynamic> surah = rawSurah is Map
        ? Map<String, dynamic>.from(rawSurah)
        : {};

    return QuranAyahModel(
      text: json['text']?.toString() ?? '',
      number: int.tryParse(json['number']?.toString() ?? '') ?? 0,
      numberInSurah: int.tryParse(json['numberInSurah']?.toString() ?? '') ?? 0,
      surahName: surah['name']?.toString() ?? '',
      surahNumber: int.tryParse(surah['number']?.toString() ?? '') ?? 0,
      revelationType: surah['revelationType']?.toString() ?? '',
    );
  }
}
