import '../../../../core/utils/arabic_text_normalizer.dart';

class CheckMemorizationAnswer {
  bool call({required String userAnswer, required String correctAnswer}) {
    return ArabicTextNormalizer.normalize(userAnswer) ==
        ArabicTextNormalizer.normalize(correctAnswer);
  }
}
