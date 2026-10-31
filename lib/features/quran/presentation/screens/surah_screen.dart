
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zad/core/constants/app_constants.dart';

import '../../../../core/dependency_injection/injection_container.dart';
import '../../domain/entities/quran_ayah_entity.dart';
import '../../domain/entities/surah_entity.dart';
import '../cubit/quran_cubit.dart';
import '../cubit/quran_state.dart';

class SurahScreen extends StatefulWidget {
  final SurahEntity surah;

  const SurahScreen({super.key, required this.surah});

  @override
  State<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen>
    with SingleTickerProviderStateMixin {
  late final QuranCubit quranCubit;
  late final AnimationController _animationController;

  final Map<int, GlobalKey> _ayahKeys = {};
  int? _lastAutoScrolledAyahNumber;

  @override
  void initState() {
    super.initState();

    quranCubit = sl<QuranCubit>();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    loadSurah();
  }

  Future<void> loadSurah() async {
    _lastAutoScrolledAyahNumber = null;
    await quranCubit.loadSurahAyahs(widget.surah.number);
  }

  void _scrollToCurrentAyah(QuranState state) {
    final ayahNumber = state.currentAyahNumber;

    if (ayahNumber == null ||
        state.audioStatus != QuranAudioStatus.playing ||
        _lastAutoScrolledAyahNumber == ayahNumber) {
      return;
    }

    _lastAutoScrolledAyahNumber = ayahNumber;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final ayahContext = _ayahKeys[ayahNumber]?.currentContext;

      if (ayahContext == null) return;

      Scrollable.ensureVisible(
        ayahContext,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
        alignment: 0.35,
      );
    });
  }

  Future<void> toggleAyahPlayback(int ayahNumber) async {
    final state = quranCubit.state;

    if (state.currentAyahNumber == ayahNumber) {
      if (state.audioStatus == QuranAudioStatus.playing) {
        await quranCubit.pauseAudio();
      } else if (state.audioStatus == QuranAudioStatus.paused) {
        await quranCubit.resumeAudio();
      } else {
        await quranCubit.toggleAyahAudio(ayahNumber);
      }
    } else {
      await quranCubit.toggleAyahAudio(ayahNumber);
    }
  }

  Future<void> toggleSurahPlayback(
      List<QuranAyahEntity> ayahs,
      ) async {
    final status = quranCubit.state.audioStatus;

    if (status == QuranAudioStatus.loading) return;

    if (status == QuranAudioStatus.playing) {
      await quranCubit.pauseAudio();
    } else if (status == QuranAudioStatus.paused) {
      await quranCubit.resumeAudio();
    } else {
      _lastAutoScrolledAyahNumber = null;
      await quranCubit.playSurahAudio(ayahs);
    }
  }

  Future<void> copyAyah(QuranAyahEntity ayah) async {
    await Clipboard.setData(
      ClipboardData(
        text: '${ayah.text}\n\n'
            '${widget.surah.name} - الآية ${ayah.numberInSurah}',
      ),
    );

    if (!mounted) return;

    final colors = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        content: const Row(
          children: [
            Icon(Icons.check_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'تم نسخ الآية',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> shareAyah(QuranAyahEntity ayah) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: '${ayah.text}\n\n'
              '${widget.surah.name} - الآية ${ayah.numberInSurah}\n'
              '${AppConstants.appName}',
        ),
      );
    } catch (e) {
      debugPrint('Share error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر مشاركة الآية')),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    quranCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocListener<QuranCubit, QuranState>(
      bloc: quranCubit,
      listener: (context, state) {
        if (state.surahAyahsStatus == QuranRequestStatus.success) {
          _ayahKeys.clear();
          _animationController.forward(from: 0);
        }

        _scrollToCurrentAyah(state);

        if (state.audioStatus == QuranAudioStatus.failure &&
            state.audioError.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: colors.error,
              content: Text('تعذر تشغيل الصوت: ${state.audioError}'),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: _buildAppBar(colors),
        body: BlocBuilder<QuranCubit, QuranState>(
          bloc: quranCubit,
          buildWhen: (previous, current) {
            return previous.surahAyahsStatus !=
                current.surahAyahsStatus ||
                previous.surahAyahs != current.surahAyahs ||
                previous.surahAyahsError != current.surahAyahsError;
          },
          builder: (context, state) {
            return _buildBody(context, colors, state);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ColorScheme colors) {
    return AppBar(
      backgroundColor: colors.surface,
      foregroundColor: colors.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.surah.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            widget.surah.englishName,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: loadSurah,
          tooltip: 'تحديث',
          icon: Icon(
            Icons.refresh_rounded,
            color: colors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildBody(
      BuildContext context,
      ColorScheme colors,
      QuranState state,
      ) {
    if (state.surahAyahsStatus == QuranRequestStatus.loading ||
        state.surahAyahsStatus == QuranRequestStatus.initial) {
      return _buildLoading(colors);
    }

    if (state.surahAyahsStatus == QuranRequestStatus.failure) {
      return _buildError(colors);
    }

    if (state.surahAyahs.isEmpty) {
      return _buildEmpty(colors);
    }

    return RefreshIndicator(
      onRefresh: loadSurah,
      color: colors.primary,
      backgroundColor: colors.surface,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 35),
        children: [
          _buildSurahHeader(state.surahAyahs),
          ...state.surahAyahs.map((ayah) {
            final ayahKey = _ayahKeys.putIfAbsent(
              ayah.number,
                  () => GlobalKey(),
            );

            return _AnimatedAyahCard(
              key: ValueKey(ayah.number),
              index: ayah.numberInSurah - 1,
              controller: _animationController,
              child: KeyedSubtree(
                key: ayahKey,
                child: _buildAyahAudioCard(ayah),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSurahHeader(List<QuranAyahEntity> ayahs) {
    return BlocSelector<QuranCubit, QuranState, QuranAudioStatus>(
      bloc: quranCubit,
      selector: (state) => state.audioStatus,
      builder: (context, audioStatus) {
        return _SurahHeader(
          surah: widget.surah,
          audioStatus: audioStatus,
          onPlay: () => toggleSurahPlayback(ayahs),
          isLoading: audioStatus == QuranAudioStatus.loading,
          isPlaying: audioStatus == QuranAudioStatus.playing,
        );
      },
    );
  }

  Widget _buildAyahAudioCard(QuranAyahEntity ayah) {
    return BlocSelector<
        QuranCubit,
        QuranState,
        ({bool isCurrent, QuranAudioStatus status})>(
      bloc: quranCubit,
      selector: (state) {
        final isCurrent = state.currentAyahNumber == ayah.number;

        return (
        isCurrent: isCurrent,
        status: isCurrent
            ? state.audioStatus
            : QuranAudioStatus.initial,
        );
      },
      builder: (context, audioState) {
        return _AyahCard(
          ayah: ayah,
          isCurrentAyah: audioState.isCurrent,
          audioStatus: audioState.status,
          onPlayAudio: () => toggleAyahPlayback(ayah.number),
          onCopy: () => copyAyah(ayah),
          onShare: () => shareAyah(ayah),
        );
      },
    );
  }

  Widget _buildLoading(ColorScheme colors) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(21),
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.45),
            ),
          ),
          child: Container(
            height: 175,
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLoadingBox(
                  colors,
                  width: 38,
                  height: 38,
                ),
                const SizedBox(height: 22),
                _buildLoadingBox(
                  colors,
                  width: double.infinity,
                  height: 16,
                ),
                const SizedBox(height: 10),
                _buildLoadingBox(
                  colors,
                  width: 250,
                  height: 16,
                ),
                const SizedBox(height: 10),
                _buildLoadingBox(
                  colors,
                  width: 180,
                  height: 16,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingBox(
      ColorScheme colors, {
        required double width,
        required double height,
      }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 0.8),
      duration: const Duration(milliseconds: 900),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(7),
            ),
          ),
        );
      },
    );
  }

  Widget _buildError(ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatusIcon(
              colors,
              Icons.cloud_off_rounded,
              isError: true,
            ),
            const SizedBox(height: 18),
            Text(
              'تعذر تحميل السورة',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'تحقق من اتصال الإنترنت وحاول مرة أخرى.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: loadSurah,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatusIcon(
              colors,
              Icons.menu_book_rounded,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد آيات للعرض',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(
      ColorScheme colors,
      IconData icon, {
        bool isError = false,
      }) {
    final iconColor = isError ? colors.error : colors.primary;

    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.10),
        shape: BoxShape.circle,
        border: Border.all(
          color: iconColor.withValues(alpha: 0.35),
        ),
      ),
      child: Icon(
        icon,
        size: 35,
        color: iconColor,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Surah Header
// -----------------------------------------------------------------------------

class _SurahHeader extends StatelessWidget {
  final SurahEntity surah;
  final QuranAudioStatus audioStatus;
  final VoidCallback onPlay;
  final bool isLoading;
  final bool isPlaying;

  const _SurahHeader({
    required this.surah,
    required this.audioStatus,
    required this.onPlay,
    required this.isLoading,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final bool isMeccan =
        surah.revelationType.toLowerCase() == 'meccan';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.75),
          width: 1.2,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            _buildDecoration(colors),
            const SizedBox(height: 14),
            Text(
              surah.name,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: colors.onSurface,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              surah.englishName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _SurahInfoChip(
                  icon: Icons.auto_stories_rounded,
                  text: '${surah.numberOfAyahs} آية',
                ),
                _SurahInfoChip(
                  icon: Icons.location_on_outlined,
                  text: isMeccan ? 'مكية' : 'مدنية',
                ),
                _SurahInfoChip(
                  icon: Icons.numbers_rounded,
                  text: '#${surah.number}',
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isLoading ? null : onPlay,
                icon: Icon(
                  isLoading
                      ? Icons.hourglass_top_rounded
                      : isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  size: 22,
                ),
                label: Text(
                  isLoading
                      ? 'جاري التحميل...'
                      : isPlaying
                      ? 'إيقاف مؤقت'
                      : audioStatus == QuranAudioStatus.paused
                      ? 'استكمال التلاوة'
                      : 'استمع للسورة كاملة',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  disabledBackgroundColor:
                  colors.primary.withValues(alpha: 0.35),
                  disabledForegroundColor: colors.onPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            _buildDecoration(
              colors,
              icon: Icons.diamond_outlined,
              iconSize: 13,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecoration(
      ColorScheme colors, {
        IconData icon = Icons.auto_awesome,
        double iconSize = 17,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _decorationLine(colors),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9),
          child: Icon(
            icon,
            color: colors.primary,
            size: iconSize,
          ),
        ),
        _decorationLine(colors),
      ],
    );
  }

  Widget _decorationLine(ColorScheme colors) {
    return Container(
      width: 38,
      height: 1,
      color: colors.primary.withValues(alpha: 0.55),
    );
  }
}

// -----------------------------------------------------------------------------
// Animated Ayah
// -----------------------------------------------------------------------------

class _AnimatedAyahCard extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final Widget child;

  const _AnimatedAyahCard({
    super.key,
    required this.index,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final double delay = (index * 0.03).clamp(0.0, 0.35);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final double value =
        ((controller.value - delay) / (1 - delay))
            .clamp(0.0, 1.0);

        final curved = Curves.easeOutCubic.transform(value);

        return Opacity(
          opacity: curved,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - curved)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// -----------------------------------------------------------------------------
// Ayah Card
// -----------------------------------------------------------------------------
class _AyahCard extends StatelessWidget {
  final QuranAyahEntity ayah;
  final bool isCurrentAyah;
  final QuranAudioStatus audioStatus;
  final VoidCallback onPlayAudio;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const _AyahCard({
    required this.ayah,
    required this.isCurrentAyah,
    required this.audioStatus,
    required this.onPlayAudio,
    required this.onCopy,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final paper = isDark
        ? const Color(0xFF252017)
        : const Color(0xFFF7F1DF);

    final innerPaper = isDark
        ? const Color(0xFF201B13)
        : const Color(0xFFFFFCF4);

    final gold = isDark
        ? const Color(0xFFD6BE83)
        : const Color(0xFFA88746);

    final lightGold = isDark
        ? const Color(0xFF806B43)
        : const Color(0xFFD6BE83);

    final textColor = isDark
        ? const Color(0xFFF2E8D2)
        : const Color(0xFF493A25);

    final mutedColor = isDark
        ? const Color(0xFFC1B18F)
        : const Color(0xFF786548);

    final isPlaying =
        isCurrentAyah &&
            audioStatus == QuranAudioStatus.playing;

    final isLoading =
        isCurrentAyah &&
            audioStatus == QuranAudioStatus.loading;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: gold,
          width: isCurrentAyah ? 1.8 : 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(
              alpha: isDark ? 0.07 : 0.12,
            ),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: innerPaper,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: lightGold.withValues(alpha: 0.8),
            width: 0.9,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 7,
              right: 8,
              child: Icon(
                Icons.auto_awesome,
                size: 18,
                color: gold.withValues(alpha: 0.65),
              ),
            ),
            Positioned(
              top: 7,
              left: 8,
              child: Icon(
                Icons.auto_awesome,
                size: 18,
                color: gold.withValues(alpha: 0.65),
              ),
            ),
            Positioned(
              bottom: 7,
              right: 8,
              child: Icon(
                Icons.auto_awesome,
                size: 18,
                color: gold.withValues(alpha: 0.65),
              ),
            ),
            Positioned(
              bottom: 7,
              left: 8,
              child: Icon(
                Icons.auto_awesome,
                size: 18,
                color: gold.withValues(alpha: 0.65),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                15,
                20,
                15,
                16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: gold.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: lightGold,
                          ),
                        ),
                        child: Text(
                          '۞  ${ayah.numberInSurah}  ۞',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: gold,
                          ),
                        ),
                      ),

                      const Spacer(),

                      _SmallActionButton(
                        icon: isLoading
                            ? Icons.hourglass_top_rounded
                            : isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        onTap: onPlayAudio,
                        isActive: isCurrentAyah,
                      ),

                      const SizedBox(width: 5),

                      _SmallActionButton(
                        icon: Icons.copy_rounded,
                        onTap: onCopy,
                      ),

                      const SizedBox(width: 5),

                      _SmallActionButton(
                        icon: Icons.share_outlined,
                        onTap: onShare,
                      ),
                    ],
                  ),

                  const SizedBox(height: 13),

                  Divider(
                    color: lightGold,
                    height: 1,
                  ),

                  const SizedBox(height: 17),

                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      '﴿ ${ayah.text} ﴾',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 23,
                        height: 2,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      '${ayah.surahName} • الآية ${ayah.numberInSurah}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: mutedColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 19),

                  Divider(
                    color: lightGold,
                    height: 1,
                  ),

                  const SizedBox(height: 13),

                  Row(
                    children: [
                      Icon(
                        Icons.menu_book_outlined,
                        size: 16,
                        color: gold,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'من القرآن الكريم',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: mutedColor,
                        ),
                      ),

                      const Spacer(),

                      if (isCurrentAyah) ...[
                        Icon(
                          isPlaying
                              ? Icons.volume_up_rounded
                              : Icons.graphic_eq_rounded,
                          size: 15,
                          color: gold,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isPlaying
                              ? 'تُتلى الآن'
                              : 'متوقفة مؤقتًا',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: gold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// -----------------------------------------------------------------------------
// Small Action Button
// -----------------------------------------------------------------------------

class _SmallActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  const _SmallActionButton({
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: isActive
          ? colors.primary.withValues(alpha: 0.14)
          : colors.primary.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.22),
            ),
          ),
          child: Icon(
            icon,
            size: 16,
            color: colors.primary,
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Surah Information Chip
// -----------------------------------------------------------------------------

class _SurahInfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SurahInfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: colors.primary,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
