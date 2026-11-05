import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/memorization_test_config_entity.dart';
import '../../domain/entities/memorization_test_session_entity.dart';
import '../../domain/entities/memorization_test_result_entity.dart';
import '../../domain/entities/memorization_missed_ayah_entity.dart';
import '../../domain/usecases/start_memorization_test.dart';
import '../../domain/usecases/submit_memorization_answer.dart';
import '../../domain/usecases/save_memorization_test_result.dart';
import '../../domain/usecases/get_all_surahs.dart';
import 'memorization_test_state.dart';

class MemorizationTestCubit extends Cubit<MemorizationTestState> {
  final StartMemorizationTest startMemorizationTest;
  final SubmitMemorizationAnswer submitMemorizationAnswer;
  final SaveMemorizationTestResult saveMemorizationTestResult;

  MemorizationTestCubit({
    required this.startMemorizationTest,
    required this.submitMemorizationAnswer,
    required this.saveMemorizationTestResult,
    required this.getAllSurahs,

  }) : super(const MemorizationTestInitial());


  final GetAllSurahs getAllSurahs;

  Future<void> startTest({
    required MemorizationTestConfigEntity config,
  }) async {
    debugPrint('🟡 START TEST: EMIT LOADING');

    emit(const MemorizationTestLoading());

    // نضمن إن شاشة التحميل تاخد فرصة تظهر قبل تجهيز الأسئلة.
    final minimumLoadingDuration = Future<void>.delayed(
      const Duration(milliseconds: 600),
    );

    await Future<void>.delayed(
      const Duration(milliseconds: 100),
    );

    try {
      final session = await startMemorizationTest(config: config);

      await minimumLoadingDuration;

      if (isClosed) return;

      emit(
        MemorizationTestInProgress(
          session: session,
          currentQuestionIndex: 0,
          answersCorrectness: List<bool?>.filled(
            session.totalQuestions,
            null,
          ),
          isAnswerSubmitted: false,
          lastAnswerCorrect: null,
        ),
      );
    } catch (e, stackTrace) {
      await minimumLoadingDuration;

      if (isClosed) return;

      debugPrint('MemorizationTestCubit startTest: $e');
      debugPrintStack(stackTrace: stackTrace);

      emit(MemorizationTestFailure(e.toString()));
    }
  }




  void submitAnswer(String userAnswer) {
    final currentState = state;

    if (currentState is! MemorizationTestInProgress ||
        currentState.isAnswerSubmitted) {
      return;
    }

    final question =
        currentState.session.questions[currentState.currentQuestionIndex];

    final isCorrect = submitMemorizationAnswer(
      question: question,
      userAnswer: userAnswer,
    );

    final updatedAnswers = List<bool?>.from(currentState.answersCorrectness);

    updatedAnswers[currentState.currentQuestionIndex] = isCorrect;

    emit(
      MemorizationTestInProgress(
        session: currentState.session,
        currentQuestionIndex: currentState.currentQuestionIndex,
        answersCorrectness: updatedAnswers,
        isAnswerSubmitted: true,
        lastAnswerCorrect: isCorrect,
      ),
    );
  }

  Future<void> nextQuestion() async {
    final currentState = state;

    if (currentState is! MemorizationTestInProgress ||
        !currentState.isAnswerSubmitted) {
      return;
    }

    if (currentState.isLastQuestion) {
      await _completeTest(currentState);
      return;
    }

    emit(
      MemorizationTestInProgress(
        session: currentState.session,
        currentQuestionIndex: currentState.currentQuestionIndex + 1,
        answersCorrectness: currentState.answersCorrectness,
        isAnswerSubmitted: false,
        lastAnswerCorrect: null,
      ),
    );
  }

  Future<void> _completeTest(MemorizationTestInProgress currentState) async {
    try {
      final answers = currentState.answersCorrectness
          .whereType<bool>()
          .toList();
      Map<int, String> surahNames = {};

      try {
        final surahs = await getAllSurahs();
        surahNames = {
          for (final surah in surahs) surah.number: surah.name,
        };
      } catch (e) {
        debugPrint('Failed to load surah names: $e');
      }
      final missedAyahs = <MemorizationMissedAyahEntity>[];

      for (int i = 0; i < answers.length; i++) {
        if (!answers[i]) {
          final question = currentState.session.questions[i];

          missedAyahs.add(
            MemorizationMissedAyahEntity(
              surahNumber: question.surahNumber,
              ayahNumber: question.ayahNumber,
              surahName: surahNames[question.surahNumber],
            ),
          );
        }
      }

      final completedSession = MemorizationTestSessionEntity(
        config: currentState.session.config,
        questions: currentState.session.questions,
        answersCorrectness: answers,
        missedAyahs: missedAyahs,
      );

      final result = MemorizationTestResultEntity(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        date: DateTime.now(),
        scope: completedSession.config.scope.name,
        totalQuestions: completedSession.totalQuestions,
        correctAnswers: completedSession.correctAnswers,
        wrongAnswers: completedSession.wrongAnswers,
        percentage: completedSession.percentage,
        missedAyahs: missedAyahs.map((ayah) => ayah.toMap()).toList(),
      );

      await saveMemorizationTestResult(result);

      emit(MemorizationTestCompleted(session: completedSession));
    } catch (e) {
      emit(MemorizationTestFailure(e.toString()));
    }
  }
}
