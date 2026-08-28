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
    final surah = json['surah'];

    return QuranAyahModel(
      text: json['text'] ?? '',
      number: json['number'] ?? 0,
      numberInSurah: json['numberInSurah'] ?? 0,
      surahName: surah?['name'] ?? '',
      surahNumber: surah?['number'] ?? 0,
      revelationType: surah?['revelationType'] ?? '',
    );
  }
}
