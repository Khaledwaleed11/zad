import 'dart:math';

import '../../../../core/utils/arabic_text_normalizer.dart';
import '../../domain/entities/memorization_question_entity.dart';
import '../../domain/entities/memorization_test_config_entity.dart';
import '../../domain/entities/quran_local_ayah_entity.dart';
import '../../domain/repositories/memorization_question_generator_repository.dart';
import '../../domain/usecases/get_all_local_ayahs.dart';

class MemorizationQuestionGeneratorRepositoryImpl
    implements MemorizationQuestionGeneratorRepository {
  final GetAllLocalAyahs getAllLocalAyahs;
  final Random _random = Random();

  MemorizationQuestionGeneratorRepositoryImpl({required this.getAllLocalAyahs});

  @override
  Future<List<MemorizationQuestionEntity>> generateQuestions({
    required MemorizationTestConfigEntity config,
  }) async {
    final ayahs = await getAllLocalAyahs();

    _validateConfig(config, ayahs);

    final candidates = _filterAyahs(config, ayahs)..shuffle(_random);

    final questions = <MemorizationQuestionEntity>[];

    for (final ayah in candidates) {
      if (questions.length >= config.questionCount) {
        break;
      }

      try {
        final question = _buildQuestion(
          ayah: ayah,
          config: config,
          // نستخدم كل آيات القرآن لتكوين اختيارات متنوعة،
          // حتى لو كان الاختبار في سورة واحدة أو نطاق صغير.
          ayahs: ayahs,
        );

        if (question != null) {
          questions.add(question);
        }
      } on StateError {
        continue;
      }
    }

    if (questions.length < config.questionCount) {
      throw StateError('Could not generate enough valid questions.');
    }

    return questions;
  }

  List<String> _splitAyahIntoWords(String ayahText) {
    return ayahText
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
  }

  List<int> _selectMissingWordIndexes(int wordCount) {
    final missingCount = wordCount < 5
        ? 1
        : wordCount < 10
        ? 2
        : 3;

    final indexes = List<int>.generate(wordCount, (index) => index)
      ..shuffle(_random);

    return indexes.take(missingCount).toList()..sort();
  }

  String _buildQuestionText(List<String> words, List<int> missingIndexes) {
    final questionWords = List<String>.from(words);

    for (final index in missingIndexes) {
      questionWords[index] = 'ــــــــــــ';
    }

    return questionWords.join(' ');
  }

  List<String> _buildOptions({
    required String correctAnswer,
    required int answerWordCount,
    required List<QuranLocalAyahEntity> ayahs,
  }) {
    final normalizedCorrect = ArabicTextNormalizer.normalize(correctAnswer);

    // المفتاح هو النص بعد توحيد التشكيل والرسم،
    // والقيمة هي النص الأصلي الذي سيظهر للمستخدم.
    final uniqueOptions = <String, String>{normalizedCorrect: correctAnswer};

    for (final ayah in ayahs) {
      final words = _splitAyahIntoWords(ayah.text);

      if (words.length < answerWordCount) {
        continue;
      }

      for (int i = 0; i <= words.length - answerWordCount; i++) {
        final candidate = words.skip(i).take(answerWordCount).join(' ');

        final normalizedCandidate = ArabicTextNormalizer.normalize(candidate);

        if (normalizedCandidate.isEmpty ||
            normalizedCandidate == normalizedCorrect) {
          continue;
        }

        uniqueOptions.putIfAbsent(normalizedCandidate, () => candidate);
      }
    }

    final distractors =
        uniqueOptions.entries
            .where((entry) => entry.key != normalizedCorrect)
            .map((entry) => entry.value)
            .toList()
          ..shuffle(_random);

    // لازم يكون عندنا إجابة صحيحة و3 اختيارات خاطئة مختلفة عنها.
    if (distractors.length < 3) {
      throw StateError('Not enough unique answer options.');
    }

    final options = <String>[correctAnswer, ...distractors.take(3)]
      ..shuffle(_random);

    // ضمان وجود إجابة صحيحة واحدة فقط بعد التطبيع.
    final correctOptionsCount = options
        .where(
          (option) =>
              ArabicTextNormalizer.normalize(option) == normalizedCorrect,
        )
        .length;

    if (correctOptionsCount != 1) {
      throw StateError('Invalid answer options.');
    }

    return options;
  }

  MemorizationQuestionEntity? _buildQuestion({
    required QuranLocalAyahEntity ayah,
    required MemorizationTestConfigEntity config,
    required List<QuranLocalAyahEntity> ayahs,
  }) {
    final words = _splitAyahIntoWords(ayah.text);

    if (words.length < 2) {
      return null;
    }

    switch (config.difficulty) {
      case MemorizationTestDifficulty.easy:
      case MemorizationTestDifficulty.medium:
        final missingIndexes = _selectMissingWordIndexes(words.length);

        final correctAnswer = missingIndexes
            .map((index) => words[index])
            .join(' ');

        final options = config.difficulty == MemorizationTestDifficulty.easy
            ? _buildOptions(
                correctAnswer: correctAnswer,
                answerWordCount: missingIndexes.length,
                ayahs: ayahs,
              )
            : <String>[];

        return MemorizationQuestionEntity(
          surahNumber: ayah.surahNumber,
          ayahNumber: ayah.ayahNumber,
          questionText: _buildQuestionText(words, missingIndexes),
          correctAnswer: correctAnswer,
          options: options,
          missingIndexes: missingIndexes,
        );

      case MemorizationTestDifficulty.hard:
        final startIndex = _selectContinuationStartIndex(words.length);

        return MemorizationQuestionEntity(
          surahNumber: ayah.surahNumber,
          ayahNumber: ayah.ayahNumber,
          questionText: words.take(startIndex).join(' '),
          correctAnswer: words.skip(startIndex).join(' '),
        );
    }
  }

  int _selectContinuationStartIndex(int wordCount) {
    if (wordCount < 2) {
      throw ArgumentError('Ayah is too short for continuation questions.');
    }

    final minIndex = (wordCount * 0.4).ceil();
    final maxIndex = (wordCount * 0.7).floor();

    final startIndex = minIndex <= maxIndex
        ? minIndex + _random.nextInt(maxIndex - minIndex + 1)
        : _random.nextInt(wordCount - 1) + 1;

    return startIndex.clamp(1, wordCount - 1);
  }

  void _validateConfig(
    MemorizationTestConfigEntity config,
    List<QuranLocalAyahEntity> ayahs,
  ) {
    if (![5, 10, 20].contains(config.questionCount)) {
      throw ArgumentError('Invalid question count.');
    }

    final selectedSurahs = config.surahNumbers;

    if (selectedSurahs.any((number) => number < 1 || number > 114)) {
      throw ArgumentError('Invalid surah number.');
    }

    if (selectedSurahs.toSet().length != selectedSurahs.length) {
      throw ArgumentError('Duplicate surah selection.');
    }

    switch (config.scope) {
      case MemorizationTestScope.fullQuran:
        break;

      case MemorizationTestScope.singleSurah:
        if (selectedSurahs.length != 1) {
          throw ArgumentError('Select exactly one surah.');
        }
        break;

      case MemorizationTestScope.multipleSurahs:
        if (selectedSurahs.length < 2) {
          throw ArgumentError('Select at least two surahs.');
        }
        break;

      case MemorizationTestScope.ayahRange:
        if (selectedSurahs.length != 1 ||
            config.startAyahNumber == null ||
            config.endAyahNumber == null) {
          throw ArgumentError('Invalid ayah range selection.');
        }

        final start = config.startAyahNumber!;
        final end = config.endAyahNumber!;

        final surahAyahs = ayahs
            .where((ayah) => ayah.surahNumber == selectedSurahs.first)
            .toList();

        if (surahAyahs.isEmpty ||
            start < 1 ||
            end < start ||
            end > surahAyahs.length) {
          throw ArgumentError('Invalid ayah range.');
        }
        break;
    }

    final filteredAyahs = _filterAyahs(config, ayahs);

    if (filteredAyahs.length < config.questionCount) {
      throw ArgumentError('Not enough ayahs for the selected test.');
    }
  }

  List<QuranLocalAyahEntity> _filterAyahs(
    MemorizationTestConfigEntity config,
    List<QuranLocalAyahEntity> ayahs,
  ) {
    switch (config.scope) {
      case MemorizationTestScope.fullQuran:
        return ayahs;

      case MemorizationTestScope.singleSurah:
      case MemorizationTestScope.multipleSurahs:
        return ayahs
            .where((ayah) => config.surahNumbers.contains(ayah.surahNumber))
            .toList();

      case MemorizationTestScope.ayahRange:
        return ayahs.where((ayah) {
          return ayah.surahNumber == config.surahNumbers.first &&
              ayah.ayahNumber >= config.startAyahNumber! &&
              ayah.ayahNumber <= config.endAyahNumber!;
        }).toList();
    }
  }
}
