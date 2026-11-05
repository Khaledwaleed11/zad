
class MemorizationMissedAyahEntity {
  final int surahNumber;
  final int ayahNumber;
  final String? surahName;

  const MemorizationMissedAyahEntity({
    required this.surahNumber,
    required this.ayahNumber,
    this.surahName,
  });

  Map<String, dynamic> toMap() {
    return {
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'surahName': surahName,
    };
  }

  factory MemorizationMissedAyahEntity.fromMap(
      Map<String, dynamic> map,
      ) {
    return MemorizationMissedAyahEntity(
      surahNumber: (map['surahNumber'] as num?)?.toInt() ?? 0,
      ayahNumber: (map['ayahNumber'] as num?)?.toInt() ?? 0,
      surahName: map['surahName']?.toString(),
    );
  }
}
