import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/zad_loading_widget.dart';
import '../../domain/entities/memorization_test_session_entity.dart';
import '../cubit/memorization_test_cubit.dart';
import '../cubit/memorization_test_state.dart';

class MemorizationTestScreen extends StatefulWidget {
  const MemorizationTestScreen({super.key});

  @override
  State<MemorizationTestScreen> createState() => _MemorizationTestScreenState();
}

class _MemorizationTestScreenState extends State<MemorizationTestScreen>
    with TickerProviderStateMixin {
  final TextEditingController _answerController = TextEditingController();

  late final AnimationController _pageController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  String? _selectedOption;

  static const Color _gold = Color(0xFFA88746);
  static const Color _lightGold = Color(0xFFD6BE83);

  static const Color _paper = Color(0xFFF7F1DF);
  static const Color _innerPaper = Color(0xFFFFFCF4);
  static const Color _darkPaper = Color(0xFF252017);
  static const Color _darkInnerPaper = Color(0xFF201B13);

  static const Color _brown = Color(0xFF493A25);
  static const Color _darkText = Color(0xFFF2E8D2);

  @override
  void initState() {
    super.initState();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
          CurvedAnimation(parent: _pageController, curve: Curves.easeOutCubic),
        );
  }

  @override
  void dispose() {
    _answerController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _paperColor => _isDark ? _darkPaper : _paper;

  Color get _innerPaperColor => _isDark ? _darkInnerPaper : _innerPaper;

  Color get _goldColor => _isDark ? _lightGold : _gold;

  Color get _borderColor => _isDark ? const Color(0xFF806B43) : _lightGold;

  Color get _textColor => _isDark ? _darkText : _brown;

  Color get _mutedColor =>
      _isDark ? const Color(0xFFC1B18F) : const Color(0xFF786548);

  void _resetQuestionInput() {
    _answerController.clear();
    _selectedOption = null;
  }

  void _submitAnswer(BuildContext context, String answer) {
    if (answer.trim().isEmpty) return;

    context.read<MemorizationTestCubit>().submitAnswer(answer);
  }

  void _nextQuestion(BuildContext context) {
    _resetQuestionInput();

    context.read<MemorizationTestCubit>().nextQuestion();

    _pageController.forward(from: 0);
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MemorizationTestCubit, MemorizationTestState>(
      listener: (context, state) {
        if (state is MemorizationTestInProgress && !state.isAnswerSubmitted) {
          _resetQuestionInput();
          _pageController.forward(from: 0);
        }
      },
      builder: (context, state) {
        debugPrint('🔵 TEST SCREEN STATE: ${state.runtimeType}');

        // شاشة التحميل تظل مستقلة وتغطي الشاشة بالكامل.
        if (state is MemorizationTestLoading) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: _buildLoading(),
          );
        }

        // AppBar والمحتوى بالكامل داخل Scroll واحدة.
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAppBar(context),
                  _buildStateContent(context, state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStateContent(BuildContext context, MemorizationTestState state) {
    if (state is MemorizationTestFailure) {
      return _buildFailure(state.message);
    }

    if (state is MemorizationTestInProgress) {
      return _buildQuestionScreen(context, state);
    }

    if (state is MemorizationTestCompleted) {
      return _buildResultScreen(state.session);
    }

    return _buildEmptyState();
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: _lightGold),
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: _gold,
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'اختبار الحفظ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Question Screen
  // ============================================================

  Widget _buildQuestionScreen(
    BuildContext context,
    MemorizationTestInProgress state,
  ) {
    final question = state.session.questions[state.currentQuestionIndex];

    final isEasy = state.session.config.difficulty.name == 'easy';
    final isHard = state.session.config.difficulty.name == 'hard';

    final progress =
        (state.currentQuestionIndex + 1) / state.session.totalQuestions;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProgressCard(state, progress),
              const SizedBox(height: 22),

              _buildSectionTitle(
                isHard ? 'أكمل الآية الكريمة' : 'تذكّر الكلمات الناقصة',
                isHard
                    ? 'استكمل الآية من الموضع المحدد'
                    : 'تأمل الآية واختر الكلمات المناسبة',
              ),
              const SizedBox(height: 18),

              _buildAyahCard(
                question.questionText,
                isHard: isHard,
                correctAnswer: question.correctAnswer,
                userAnswer: _answerController.text,
                isSubmitted: state.isAnswerSubmitted,
                lastAnswerCorrect: state.lastAnswerCorrect ?? false,
                missingIndexes: question.missingIndexes,
              ),
              const SizedBox(height: 24),

              if (isEasy)
                _buildOptions(
                  context: context,
                  options: question.options,
                  correctAnswer: question.correctAnswer,
                  isSubmitted: state.isAnswerSubmitted,
                )
              else
                _buildTextAnswer(
                  isSubmitted: state.isAnswerSubmitted,
                  isHard: isHard,
                  correctAnswer: question.correctAnswer,
                ),

              if (state.isAnswerSubmitted) ...[
                const SizedBox(height: 18),
                _buildFeedback(
                  isCorrect: state.lastAnswerCorrect ?? false,
                  correctAnswer: question.correctAnswer,
                ),
                const SizedBox(height: 22),
                _buildPrimaryButton(
                  label: state.isLastQuestion ? 'عرض النتيجة' : 'السؤال التالي',
                  icon: state.isLastQuestion
                      ? Icons.emoji_events_rounded
                      : Icons.arrow_back_rounded,
                  onPressed: () => _nextQuestion(context),
                ),
              ] else if (!isEasy) ...[
                const SizedBox(height: 18),
                _buildPrimaryButton(
                  label: 'تأكيد الإجابة',
                  icon: Icons.check_circle_outline_rounded,
                  onPressed: _answerController.text.trim().isEmpty
                      ? null
                      : () => _submitAnswer(context, _answerController.text),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(MemorizationTestInProgress state, double progress) {
    return _buildDecoratedCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.bookmark_added_rounded, color: _goldColor, size: 19),
              const SizedBox(width: 8),
              Text(
                'السؤال ${state.currentQuestionIndex + 1}',
                style: TextStyle(
                  color: _textColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                '${state.session.totalQuestions} أسئلة',
                style: TextStyle(
                  color: _mutedColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: _borderColor.withValues(alpha: 0.3),
              color: _goldColor,
            ),
          ),
          const SizedBox(height: 9),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${(progress * 100).round()}% مكتمل',
              style: TextStyle(
                color: _mutedColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _textColor,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _mutedColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAyahCard(
    String questionText, {
    required bool isHard,
    required String correctAnswer,
    required String userAnswer,
    required bool isSubmitted,
    required bool lastAnswerCorrect,
    required List<int> missingIndexes,
  }) {
    final words = questionText.trim().split(RegExp(r'\s+'));

    final correctWords = correctAnswer.trim().isEmpty
        ? <String>[]
        : correctAnswer.trim().split(RegExp(r'\s+'));

    final userWords = userAnswer.trim().isEmpty
        ? <String>[]
        : userAnswer.trim().split(RegExp(r'\s+'));

    final displayedWords = lastAnswerCorrect ? correctWords : userWords;

    final wordWidgets = <Widget>[];

    if (isHard) {
      for (final word in words) {
        wordWidgets.add(
          Text(
            word,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _textColor,
              fontSize: 23,
              height: 2.15,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }

      for (int i = 0; i < correctWords.length; i++) {
        wordWidgets.add(
          _buildAyahAnswerSlot(
            word: i < displayedWords.length ? displayedWords[i] : '',
            isSubmitted: isSubmitted,
            isCorrect: lastAnswerCorrect,
          ),
        );
      }
    } else {
      for (int i = 0; i < words.length; i++) {
        if (missingIndexes.contains(i)) {
          final slotIndex = missingIndexes.indexOf(i);

          wordWidgets.add(
            _buildAyahAnswerSlot(
              word: slotIndex < displayedWords.length
                  ? displayedWords[slotIndex]
                  : '',
              isSubmitted: isSubmitted,
              isCorrect: lastAnswerCorrect,
            ),
          );
        } else {
          wordWidgets.add(
            Text(
              words[i],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _textColor,
                fontSize: 23,
                height: 2.15,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }
      }
    }

    return _buildDecoratedCard(
      padding: const EdgeInsets.all(7),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 25, 18, 22),
        decoration: BoxDecoration(
          color: _innerPaperColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _borderColor.withValues(alpha: 0.55)),
        ),
        child: Column(
          children: [
            Icon(Icons.auto_awesome_rounded, color: _goldColor, size: 23),
            const SizedBox(height: 18),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 5,
                runSpacing: 10,
                children: wordWidgets,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Divider(color: _borderColor)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.auto_awesome, color: _goldColor, size: 16),
                ),
                Expanded(child: Divider(color: _borderColor)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isHard ? 'التكملة' : 'موضع الكلمات الناقصة',
              style: TextStyle(
                color: _mutedColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAyahAnswerSlot({
    required String word,
    required bool isSubmitted,
    required bool isCorrect,
  }) {
    const green = Color(0xFF4C9365);
    const red = Color(0xFFB65C4E);

    final statusColor = isCorrect ? green : red;

    final backgroundColor = !isSubmitted
        ? _goldColor.withValues(alpha: 0.08)
        : statusColor.withValues(alpha: 0.12);

    final borderColor = !isSubmitted
        ? _goldColor.withValues(alpha: 0.65)
        : statusColor.withValues(alpha: 0.7);

    return Container(
      constraints: const BoxConstraints(
        minWidth: 65,
        maxWidth: 150,
        minHeight: 39,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1.3),
      ),
      child: Text(
        word.isEmpty ? '...' : word,
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          color: isSubmitted ? statusColor : _goldColor,
          fontSize: 19,
          height: 1.7,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // Options
  // ============================================================

  Widget _buildOptions({
    required BuildContext context,
    required List<String> options,
    required String correctAnswer,
    required bool isSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSmallHeading('اختر الإجابة الصحيحة'),
        const SizedBox(height: 13),
        ...List.generate(options.length, (index) {
          final option = options[index];
          final selected = _selectedOption == option;

          return Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: _buildOptionCard(
              option: option,
              number: index + 1,
              selected: selected,
              correctAnswer: correctAnswer,
              isSubmitted: isSubmitted,
              onTap: () {
                if (isSubmitted) return;

                setState(() {
                  _selectedOption = option;
                });

                _submitAnswer(context, option);
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildOptionCard({
    required String option,
    required int number,
    required bool selected,
    required String correctAnswer,
    required bool isSubmitted,
    required VoidCallback onTap,
  }) {
    const green = Color(0xFF4C9365);
    const red = Color(0xFFB65C4E);

    final isCorrectOption = option == correctAnswer;
    final isWrongSelected = isSubmitted && selected && !isCorrectOption;
    final isCorrectSelected = isSubmitted && isCorrectOption;

    final Color statusColor = isWrongSelected ? red : green;
    final bool hasStatus = isWrongSelected || isCorrectSelected;

    final Color cardBackground = isSubmitted && hasStatus
        ? statusColor.withValues(alpha: 0.12)
        : selected
        ? _goldColor.withValues(alpha: 0.12)
        : _paperColor;

    final Color innerBackground = isSubmitted && hasStatus
        ? statusColor.withValues(alpha: 0.07)
        : _innerPaperColor;

    final Color borderColor = isSubmitted && hasStatus
        ? statusColor
        : selected
        ? _goldColor
        : _borderColor;

    return Material(
      color: cardBackground,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: isSubmitted ? null : onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: borderColor,
              width: isSubmitted && hasStatus ? 1.8 : 1.1,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
            decoration: BoxDecoration(
              color: innerBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                Container(
                  width: 31,
                  height: 31,
                  decoration: BoxDecoration(
                    color: hasStatus
                        ? statusColor.withValues(alpha: 0.12)
                        : _goldColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: hasStatus ? statusColor : _borderColor,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: hasStatus
                      ? Icon(
                          isCorrectSelected
                              ? Icons.check_rounded
                              : Icons.close_rounded,
                          color: statusColor,
                          size: 19,
                        )
                      : Text(
                          '$number',
                          style: TextStyle(
                            color: _goldColor,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      option,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 18,
                        height: 1.8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (isSubmitted && isCorrectSelected)
                  const Icon(Icons.check_circle_rounded, color: green, size: 22)
                else if (isWrongSelected)
                  const Icon(Icons.cancel_rounded, color: red, size: 22)
                else
                  Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: selected ? _goldColor : _mutedColor,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Text Answer
  // ============================================================

  Widget _buildTextAnswer({
    required bool isSubmitted,
    required bool isHard,
    required String correctAnswer,
  }) {
    final isCorrect =
        isSubmitted && _answerController.text.trim() == correctAnswer.trim();

    const statusColor = Color(0xFF4C9365);

    final fieldBackgroundColor = isCorrect
        ? statusColor.withValues(alpha: 0.10)
        : _innerPaperColor;

    final borderColor = isCorrect ? statusColor : _borderColor;

    if (isCorrect && _answerController.text != correctAnswer) {
      _answerController.value = TextEditingValue(
        text: correctAnswer,
        selection: TextSelection.collapsed(offset: correctAnswer.length),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSmallHeading(
          isHard ? 'اكتب تكملة الآية' : 'اكتب الكلمات الناقصة',
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: _paperColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: isCorrect ? 1.5 : 1),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: fieldBackgroundColor,
              borderRadius: BorderRadius.circular(13),
            ),
            child: TextField(
              controller: _answerController,
              enabled: !isSubmitted,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              minLines: isHard ? 4 : 3,
              maxLines: null,
              style: TextStyle(
                color: _textColor,
                fontSize: 20,
                height: 1.9,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'اكتب إجابتك هنا...',
                hintTextDirection: TextDirection.rtl,
                hintStyle: TextStyle(
                  color: _mutedColor.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.all(16),
                border: InputBorder.none,
                prefixIcon: isCorrect
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF4C9365),
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'يمكنك كتابة الإجابة بدون تشكيل.',
          textAlign: TextAlign.right,
          style: TextStyle(color: _mutedColor, fontSize: 11),
        ),
      ],
    );
  }

  // ============================================================
  // Feedback
  // ============================================================

  Widget _buildFeedback({
    required bool isCorrect,
    required String correctAnswer,
  }) {
    final feedbackColor = isCorrect
        ? const Color(0xFF4C9365)
        : const Color(0xFFB65C4E);

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _paperColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: feedbackColor.withValues(alpha: 0.7)),
      ),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: feedbackColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  isCorrect ? Icons.check_circle_rounded : Icons.info_rounded,
                  color: feedbackColor,
                  size: 21,
                ),
                const SizedBox(width: 8),
                Text(
                  isCorrect ? 'أحسنت! إجابة صحيحة' : 'إجابة غير صحيحة',
                  style: TextStyle(
                    color: feedbackColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            if (!isCorrect) ...[
              const SizedBox(height: 13),
              Text(
                'الإجابة الصحيحة',
                style: TextStyle(
                  color: _mutedColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  correctAnswer,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 20,
                    height: 1.9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Result Screen
  // ============================================================

  Widget _buildResultScreen(MemorizationTestSessionEntity session) {
    final percentage = session.percentage;
    final isSuccessful = percentage >= 70;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      child: Column(
        children: [
          _buildDecoratedCard(
            padding: const EdgeInsets.all(7),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(23),
              decoration: BoxDecoration(
                color: _innerPaperColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _borderColor),
              ),
              child: Column(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: _goldColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: _borderColor),
                    ),
                    child: Icon(
                      isSuccessful
                          ? Icons.emoji_events_rounded
                          : Icons.auto_stories_rounded,
                      color: _goldColor,
                      size: 39,
                    ),
                  ),
                  const SizedBox(height: 17),
                  Text(
                    'انتهى الاختبار',
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    isSuccessful
                        ? 'أحسنت! واصل مراجعة كتاب الله'
                        : 'استمر في المراجعة، فكل خطوة تقدم',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _mutedColor, fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: _goldColor,
                      fontSize: 43,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'نسبة الإجابات الصحيحة',
                    style: TextStyle(
                      color: _mutedColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 19),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 9,
                      backgroundColor: _borderColor.withValues(alpha: 0.3),
                      color: _goldColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildResultStat(
                  title: 'إجابات صحيحة',
                  value: session.correctAnswers,
                  color: const Color(0xFF4C9365),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildResultStat(
                  title: 'إجابات خاطئة',
                  value: session.wrongAnswers,
                  color: const Color(0xFFB65C4E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (session.missedAyahs.isNotEmpty) ...[
            _buildSmallHeading('آيات تحتاج إلى مراجعة'),
            const SizedBox(height: 13),
            ...session.missedAyahs.map(
                  (ayah) => _buildMissedAyah(
                surahNumber: ayah.surahNumber,
                surahName: ayah.surahName?.isNotEmpty == true
                    ? ayah.surahName!
                    : 'سورة رقم ${ayah.surahNumber}',
                ayahNumber: ayah.ayahNumber,
              ),
            ),
          ] else
            _buildDecoratedCard(
              padding: const EdgeInsets.all(17),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF4C9365),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'ممتاز! أجبت عن جميع الأسئلة بشكل صحيح.',
                      style: TextStyle(
                        color: _textColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          _buildPrimaryButton(
            label: 'العودة إلى القرآن',
            icon: Icons.menu_book_rounded,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildResultStat({
    required String title,
    required int value,
    required Color color,
  }) {
    return _buildDecoratedCard(
      padding: const EdgeInsets.all(13),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _mutedColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissedAyah({required int surahNumber, required int ayahNumber,  required String surahName,}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: _paperColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _borderColor),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
        decoration: BoxDecoration(
          color: _innerPaperColor,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          children: [
            Icon(Icons.bookmark_outline_rounded, color: _goldColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                surahName.isNotEmpty ? surahName : 'سورة رقم $surahNumber',
                style: TextStyle(
                  color: _textColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
            Text(
              'الآية $ayahNumber',
              style: TextStyle(
                color: _mutedColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Shared Widgets
  // ============================================================

  Widget _buildDecoratedCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(5),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _paperColor,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: _goldColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _goldColor.withValues(alpha: _isDark ? 0.05 : 0.09),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _borderColor.withValues(alpha: 0.7)),
        ),
        child: child,
      ),
    );
  }

  Widget _buildSmallHeading(String title) {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        children: [
          Container(
            width: 5,
            height: 17,
            decoration: BoxDecoration(
              color: _goldColor,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: _textColor,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _paperColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _borderColor),
      ),
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 19),
        label: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: _gold,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _gold.withValues(alpha: 0.35),
          minimumSize: const Size(double.infinity, 51),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  // ============================================================
  // Loading
  // ============================================================

  Widget _buildLoading() {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return ColoredBox(
      color: backgroundColor,
      child: SizedBox.expand(
        child: SafeArea(
          bottom: false,
          child: Center(
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.65,
              width: double.infinity,
              child: const ZadLoadingWidget(
                key: ValueKey('memorization_loading'),
                type: ZadLoadingType.quran,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Failure & Empty State
  // ============================================================

  Widget _buildFailure(String message) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: _buildDecoratedCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFB65C4E),
                size: 42,
              ),
              const SizedBox(height: 14),
              Text(
                'تعذر بدء الاختبار',
                style: TextStyle(
                  color: _textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: _mutedColor),
              ),
              const SizedBox(height: 17),
              _buildPrimaryButton(
                label: 'العودة',
                icon: Icons.arrow_back_rounded,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(
          'لم يبدأ الاختبار بعد',
          style: TextStyle(color: _mutedColor),
        ),
      ),
    );
  }
}
