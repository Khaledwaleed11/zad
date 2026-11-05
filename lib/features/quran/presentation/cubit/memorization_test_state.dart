import '../../domain/entities/memorization_test_session_entity.dart';

abstract class MemorizationTestState {
  const MemorizationTestState();
}

class MemorizationTestInitial extends MemorizationTestState {
  const MemorizationTestInitial();
}

class MemorizationTestLoading extends MemorizationTestState {
  const MemorizationTestLoading();
}

class MemorizationTestInProgress extends MemorizationTestState {
  final MemorizationTestSessionEntity session;
  final int currentQuestionIndex;
  final List<bool?> answersCorrectness;
  final bool isAnswerSubmitted;
  final bool? lastAnswerCorrect;

  const MemorizationTestInProgress({
    required this.session,
    required this.currentQuestionIndex,
    required this.answersCorrectness,
    required this.isAnswerSubmitted,
    required this.lastAnswerCorrect,
  });

  bool get isLastQuestion => currentQuestionIndex == session.totalQuestions - 1;
}

class MemorizationTestCompleted extends MemorizationTestState {
  final MemorizationTestSessionEntity session;

  const MemorizationTestCompleted({required this.session});
}

class MemorizationTestFailure extends MemorizationTestState {
  final String message;

  const MemorizationTestFailure(this.message);
}
