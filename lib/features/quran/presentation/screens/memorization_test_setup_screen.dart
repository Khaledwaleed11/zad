
import 'package:flutter/material.dart';

import '../../domain/entities/memorization_test_config_entity.dart';
import '../../domain/entities/surah_entity.dart';

class MemorizationTestSetupScreen extends StatefulWidget {
  final List<SurahEntity> surahs;

  const MemorizationTestSetupScreen({
    super.key,
    required this.surahs,
  });

  @override
  State<MemorizationTestSetupScreen> createState() =>
      _MemorizationTestSetupScreenState();
}

class _MemorizationTestSetupScreenState
    extends State<MemorizationTestSetupScreen> {
  static const Color _gold = Color(0xFFA88746);
  static const Color _lightGold = Color(0xFFD6BE83);
  static const Color _paper = Color(0xFFF7F1DF);
  static const Color _innerPaper = Color(0xFFFFFCF4);
  static const Color _darkPaper = Color(0xFF252017);
  static const Color _darkInnerPaper = Color(0xFF201B13);
  static const Color _brown = Color(0xFF493A25);

  bool get _isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get _background => _isDark ? _darkPaper : _paper;
  Color get _surface => _isDark ? _darkInnerPaper : _innerPaper;
  Color get _textColor =>
      _isDark ? const Color(0xFFF2E8D2) : _brown;
  Color get _mutedColor =>
      _isDark ? const Color(0xFFC1B18F) : const Color(0xFF786548);
  Color get _borderColor =>
      _isDark ? _lightGold.withValues(alpha: 0.25) : _gold.withValues(alpha: 0.25);

  MemorizationTestScope selectedScope =
      MemorizationTestScope.fullQuran;

  MemorizationTestDifficulty selectedDifficulty =
      MemorizationTestDifficulty.easy;

  int selectedQuestionCount = 5;

  int? selectedSurahNumber;
  int startAyahNumber = 1;
  int endAyahNumber = 5;

  final Set<int> selectedSurahNumbers = {};

  SurahEntity? get selectedSurah {
    if (selectedSurahNumber == null) return null;

    for (final surah in widget.surahs) {
      if (surah.number == selectedSurahNumber) {
        return surah;
      }
    }

    return null;
  }

  @override
  void initState() {
    super.initState();

    if (widget.surahs.isNotEmpty) {
      selectedSurahNumber = widget.surahs.first.number;
      endAyahNumber = widget.surahs.first.numberOfAyahs.clamp(1, 5);
    }
  }

  void _selectSurah(int? number) {
    if (number == null) return;

    final surah = widget.surahs.firstWhere(
          (element) => element.number == number,
    );

    setState(() {
      selectedSurahNumber = number;
      startAyahNumber = 1;
      endAyahNumber = surah.numberOfAyahs.clamp(1, 5);
    });
  }

  Future<void> _showMultipleSurahsDialog() async {
    final tempSelection = Set<int>.from(selectedSurahNumbers);

    final result = await showDialog<Set<int>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: _surface,
              title: Text(
                'اختر السور',
                style: TextStyle(
                  color: _textColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: MediaQuery.sizeOf(context).height * 0.55,
                child: ListView.builder(
                  itemCount: widget.surahs.length,
                  itemBuilder: (context, index) {
                    final surah = widget.surahs[index];
                    final isSelected =
                    tempSelection.contains(surah.number);

                    return CheckboxListTile(
                      value: isSelected,
                      activeColor: _gold,
                      checkColor: Colors.white,
                      title: Text(
                        surah.name,
                        style: TextStyle(color: _textColor),
                      ),
                      subtitle: Text(
                        '${surah.numberOfAyahs} آية',
                        style: TextStyle(color: _mutedColor),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          if (value == true) {
                            tempSelection.add(surah.number);
                          } else {
                            tempSelection.remove(surah.number);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'إلغاء',
                    style: TextStyle(color: _mutedColor),
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _gold,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(dialogContext, tempSelection);
                  },
                  child: const Text('تأكيد'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        selectedSurahNumbers
          ..clear()
          ..addAll(result);
      });
    }
  }

  void _startTest() {
    if (widget.surahs.isEmpty) {
      _showMessage('لا توجد بيانات للسور');
      return;
    }

    final List<int> surahNumbers;

    switch (selectedScope) {
      case MemorizationTestScope.fullQuran:
        surahNumbers = [];
        break;

      case MemorizationTestScope.singleSurah:
      case MemorizationTestScope.ayahRange:
        if (selectedSurahNumber == null) {
          _showMessage('اختر السورة أولاً');
          return;
        }
        surahNumbers = [selectedSurahNumber!];
        break;

      case MemorizationTestScope.multipleSurahs:
        if (selectedSurahNumbers.isEmpty) {
          _showMessage('اختر سورة واحدة على الأقل');
          return;
        }
        surahNumbers = selectedSurahNumbers.toList();
        break;
    }

    if (selectedScope == MemorizationTestScope.ayahRange) {
      if (startAyahNumber > endAyahNumber) {
        _showMessage('بداية الآيات يجب أن تسبق نهايتها');
        return;
      }

      if (endAyahNumber - startAyahNumber + 1 <
          selectedQuestionCount) {
        _showMessage('نطاق الآيات أصغر من عدد الأسئلة المختار');
        return;
      }
    }

    final config = MemorizationTestConfigEntity(
      scope: selectedScope,
      difficulty: selectedDifficulty,
      questionCount: selectedQuestionCount,
      surahNumbers: surahNumbers,
      startAyahNumber:
      selectedScope == MemorizationTestScope.ayahRange
          ? startAyahNumber
          : null,
      endAyahNumber:
      selectedScope == MemorizationTestScope.ayahRange
          ? endAyahNumber
          : null,
    );

    Navigator.pop(context, config);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _brown,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBar(
                title: const Text('إعداد اختبار الحفظ'),
                centerTitle: true,
                backgroundColor: _background,
                foregroundColor: _textColor,
                elevation: 0,
                iconTheme: const IconThemeData(color: _gold),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 26),

                    _buildSectionTitle('نطاق الاختبار'),
                    const SizedBox(height: 12),

                    _buildScopeOption(
                      title: 'القرآن الكريم كاملًا',
                      subtitle: 'اختبر حفظك في جميع سور القرآن',
                      icon: Icons.menu_book_rounded,
                      value: MemorizationTestScope.fullQuran,
                    ),
                    _buildScopeOption(
                      title: 'سورة واحدة',
                      subtitle: 'اختر سورة لاختبار حفظك فيها',
                      icon: Icons.auto_stories_rounded,
                      value: MemorizationTestScope.singleSurah,
                    ),
                    _buildScopeOption(
                      title: 'عدة سور',
                      subtitle: 'اختر مجموعة من السور',
                      icon: Icons.library_books_rounded,
                      value: MemorizationTestScope.multipleSurahs,
                    ),
                    _buildScopeOption(
                      title: 'نطاق من الآيات',
                      subtitle: 'حدد سورة وبداية ونهاية الآيات',
                      icon: Icons.format_list_numbered_rounded,
                      value: MemorizationTestScope.ayahRange,
                    ),

                    const SizedBox(height: 16),

                    if (selectedScope == MemorizationTestScope.singleSurah ||
                        selectedScope == MemorizationTestScope.ayahRange)
                      _buildSingleSurahSelector(),

                    if (selectedScope == MemorizationTestScope.multipleSurahs)
                      _buildMultipleSurahsSelector(),

                    if (selectedScope == MemorizationTestScope.ayahRange)
                      _buildAyahRangeSelector(),

                    const SizedBox(height: 12),

                    _buildSectionTitle('مستوى الصعوبة'),
                    const SizedBox(height: 12),
                    _buildDifficultySelector(),

                    const SizedBox(height: 16),

                    _buildSectionTitle('عدد الأسئلة'),
                    const SizedBox(height: 12),
                    _buildQuestionCountSelector(),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton.icon(
                        onPressed: _startTest,
                        style: FilledButton.styleFrom(
                          backgroundColor: _gold,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text(
                          'ابدأ الاختبار',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: _gold,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اختبر حفظك للقرآن',
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'اختر النطاق والمستوى المناسب لك وابدأ رحلتك',
                  style: TextStyle(
                    color: _mutedColor,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 21,
          decoration: BoxDecoration(
            color: _gold,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: TextStyle(
            color: _textColor,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildScopeOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required MemorizationTestScope value,
  }) {
    final isSelected = selectedScope == value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _buildSelectableCard(
        isSelected: isSelected,
        onTap: () => setState(() => selectedScope = value),
        child: Row(
          children: [
            _buildIconContainer(icon, isSelected),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: _textColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: _mutedColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected ? _gold : _mutedColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleSurahSelector() {
    return _buildSectionCard(
      title: 'اختر السورة',
      child: DropdownButtonFormField<int>(
        initialValue: selectedSurahNumber,
        isExpanded: true,
        dropdownColor: _surface,
        style: TextStyle(color: _textColor),
        decoration: _inputDecoration(),
        items: widget.surahs.map((surah) {
          return DropdownMenuItem<int>(
            value: surah.number,
            child: Text(
              '${surah.name} (${surah.numberOfAyahs} آية)',
            ),
          );
        }).toList(),
        onChanged: _selectSurah,
      ),
    );
  }

  Widget _buildMultipleSurahsSelector() {
    return _buildSectionCard(
      title: 'السور المختارة',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تم اختيار ${selectedSurahNumbers.length} سورة',
            style: TextStyle(
              color: _mutedColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _showMultipleSurahsDialog,
            style: OutlinedButton.styleFrom(
              foregroundColor: _gold,
              side: const BorderSide(color: _gold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.library_add_rounded),
            label: const Text('اختيار السور'),
          ),
        ],
      ),
    );
  }

  Widget _buildAyahRangeSelector() {
    final surah = selectedSurah;

    if (surah == null) return const SizedBox.shrink();

    return _buildSectionCard(
      title: 'نطاق الآيات',
      child: Row(
        children: [
          Expanded(
            child: _buildAyahDropdown(
              label: 'من آية',
              value: startAyahNumber,
              maxValue: surah.numberOfAyahs,
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  startAyahNumber = value;
                  if (endAyahNumber < value) {
                    endAyahNumber = value;
                  }
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildAyahDropdown(
              label: 'إلى آية',
              value: endAyahNumber,
              maxValue: surah.numberOfAyahs,
              minValue: startAyahNumber,
              onChanged: (value) {
                if (value == null) return;
                setState(() => endAyahNumber = value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAyahDropdown({
    required String label,
    required int value,
    required int maxValue,
    int minValue = 1,
    required ValueChanged<int?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: _mutedColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: value.clamp(minValue, maxValue),
          isExpanded: true,
          dropdownColor: _surface,
          style: TextStyle(color: _textColor),
          decoration: _inputDecoration(),
          items: List.generate(maxValue - minValue + 1, (index) {
            final number = minValue + index;
            return DropdownMenuItem<int>(
              value: number,
              child: Text(number.toString()),
            );
          }),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDifficultySelector() {
    return Column(
      children: [
        _buildDifficultyOption(
          title: 'سهل',
          subtitle: 'اختر الإجابة الصحيحة',
          value: MemorizationTestDifficulty.easy,
          icon: Icons.check_circle_outline_rounded,
        ),
        _buildDifficultyOption(
          title: 'متوسط',
          subtitle: 'اكتب الكلمات الناقصة',
          value: MemorizationTestDifficulty.medium,
          icon: Icons.edit_note_rounded,
        ),
        _buildDifficultyOption(
          title: 'صعب',
          subtitle: 'أكمل الآية بدون اختيارات',
          value: MemorizationTestDifficulty.hard,
          icon: Icons.psychology_alt_rounded,
        ),
      ],
    );
  }

  Widget _buildDifficultyOption({
    required String title,
    required String subtitle,
    required MemorizationTestDifficulty value,
    required IconData icon,
  }) {
    final isSelected = selectedDifficulty == value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: _buildSelectableCard(
        isSelected: isSelected,
        onTap: () => setState(() => selectedDifficulty = value),
        child: Row(
          children: [
            _buildIconContainer(icon, isSelected),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: _textColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: _mutedColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected ? _gold : _mutedColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCountSelector() {
    return Row(
      children: [5, 10, 20].map((count) {
        final isSelected = selectedQuestionCount == count;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                setState(() => selectedQuestionCount = count);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _gold.withValues(alpha: 0.13)
                      : _surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? _gold : _borderColor,
                    width: isSelected ? 1.4 : 0.8,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$count أسئلة',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: isSelected ? _gold : _textColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: _textColor,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 13),
          child,
        ],
      ),
    );
  }

  Widget _buildSelectableCard({
    required bool isSelected,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Material(
      color: isSelected
          ? _gold.withValues(alpha: 0.09)
          : _surface,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: isSelected ? _gold : _borderColor,
              width: isSelected ? 1.4 : 0.8,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildIconContainer(IconData icon, bool isSelected) {
    return Container(
      width: 43,
      height: 43,
      decoration: BoxDecoration(
        color: _gold.withValues(alpha: isSelected ? 0.16 : 0.09),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(
        icon,
        color: _gold,
        size: 23,
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: _background,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _gold, width: 1.4),
      ),
    );
  }
}
