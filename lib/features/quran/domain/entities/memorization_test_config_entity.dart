enum MemorizationTestScope { fullQuran, singleSurah, multipleSurahs, ayahRange }

enum MemorizationTestDifficulty { easy, medium, hard }

class MemorizationTestConfigEntity {
  final MemorizationTestScope scope;
  final MemorizationTestDifficulty difficulty;
  final int questionCount;

  // السور المختارة، سواء سورة واحدة أو مجموعة سور.
  final List<int> surahNumbers;

  // تُستخدم فقط عند اختيار نطاق آيات.
  final int? startAyahNumber;
  final int? endAyahNumber;

  const MemorizationTestConfigEntity({
    required this.scope,
    required this.difficulty,
    required this.questionCount,
    this.surahNumbers = const [],
    this.startAyahNumber,
    this.endAyahNumber,
  });
}
