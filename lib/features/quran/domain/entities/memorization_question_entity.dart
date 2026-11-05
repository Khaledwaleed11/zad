class MemorizationQuestionEntity {
  final int surahNumber;
  final int ayahNumber;

  // النص الذي سيظهر للمستخدم في السؤال.
  final String questionText;

  // الإجابة الصحيحة بالنص القرآني الأصلي.
  final String correctAnswer;

  // اختيارات المستوى السهل فقط.
  final List<String> options;

  // أماكن الكلمات الناقصة داخل الآية.
  final List<int> missingIndexes;

  const MemorizationQuestionEntity({
    required this.surahNumber,
    required this.ayahNumber,
    required this.questionText,
    required this.correctAnswer,
    this.options = const [],
    this.missingIndexes = const [],
  });
}