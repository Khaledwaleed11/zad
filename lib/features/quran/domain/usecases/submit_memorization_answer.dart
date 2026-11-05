import '../entities/memorization_question_entity.dart';
import 'check_memorization_answer.dart';

class SubmitMemorizationAnswer {
  final CheckMemorizationAnswer checkMemorizationAnswer;

  SubmitMemorizationAnswer(this.checkMemorizationAnswer);

  bool call({
    required MemorizationQuestionEntity question,
    required String userAnswer,
  }) {
    return checkMemorizationAnswer(
      userAnswer: userAnswer,
      correctAnswer: question.correctAnswer,
    );
  }
}
