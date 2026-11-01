
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
import '../widgets/animated_ayah_card.dart';
import '../widgets/ayah_card.dart';
import '../widgets/surah_app_bar.dart';
import '../widgets/surah_empty_view.dart';
import '../widgets/surah_error_view.dart';
import '../widgets/surah_header.dart';
import '../widgets/surah_loading_view.dart';

class SurahScreen extends StatefulWidget {
  final SurahEntity surah;

  const SurahScreen({
    super.key,
    required this.surah,
  });

  @override
  State<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen>
    with SingleTickerProviderStateMixin {
  late final QuranCubit quranCubit;
  late final AnimationController _animationController;

  final Map<int, GlobalKey> _ayahKeys = {};
  int? _lastAutoScrolledAyahNumber;

  bool _hasHandledSurahSuccess = false;

  @override
  void initState() {
    super.initState();

    quranCubit = sl<QuranCubit>();
    quranCubit.startAudioListening(ownsAudio: true);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    loadSurah();
  }

  Future<void> loadSurah() async {
    _ayahKeys.clear();
    _lastAutoScrolledAyahNumber = null;
    _hasHandledSurahSuccess = false;

    await quranCubit.loadSurahAyahs(widget.surah.number);
  }

  void _scrollToCurrentAyah(QuranState state) {
    final ayahNumber = state.currentAyahNumber;

    if (ayahNumber == null ||
        state.audioStatus != QuranAudioStatus.playing ||
        _lastAutoScrolledAyahNumber == ayahNumber) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final currentState = quranCubit.state;

      if (currentState.currentAyahNumber != ayahNumber ||
          currentState.audioStatus != QuranAudioStatus.playing) {
        return;
      }

      final ayahContext = _ayahKeys[ayahNumber]?.currentContext;

      if (ayahContext == null) return;

      _lastAutoScrolledAyahNumber = ayahNumber;

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
        text:
        '${ayah.text}\n\n'
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
            Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 18,
            ),
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
          text:
          '${ayah.text}\n\n'
              '${widget.surah.name} - الآية ${ayah.numberInSurah}\n'
              '${AppConstants.appName}',
        ),
      );
    } catch (e) {
      debugPrint('Share error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر مشاركة الآية'),
        ),
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
        if (state.surahAyahsStatus == QuranRequestStatus.success &&
            !_hasHandledSurahSuccess) {
          _hasHandledSurahSuccess = true;
          _animationController.forward(from: 0);
        }

        _scrollToCurrentAyah(state);

        if (state.audioStatus == QuranAudioStatus.failure &&
            state.audioError.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: colors.error,
              content: Text(
                'تعذر تشغيل الصوت: ${state.audioError}',
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: SurahAppBar(
          surah: widget.surah,
          onRefresh: loadSurah,
        ),
        body: BlocBuilder<QuranCubit, QuranState>(
          bloc: quranCubit,
          buildWhen: (previous, current) {
            return previous.surahAyahsStatus !=
                current.surahAyahsStatus ||
                previous.surahAyahs != current.surahAyahs ||
                previous.surahAyahsError != current.surahAyahsError;
          },
          builder: (context, state) {
            return _buildBody(colors, state);
          },
        ),
      ),
    );
  }

  Widget _buildBody(
      ColorScheme colors,
      QuranState state,
      ) {
    if (state.surahAyahsStatus == QuranRequestStatus.loading ||
        state.surahAyahsStatus == QuranRequestStatus.initial) {
      return SurahLoadingView(colors: colors);
    }

    if (state.surahAyahsStatus == QuranRequestStatus.failure) {
      return SurahErrorView(
        colors: colors,
        onRetry: loadSurah,
      );
    }

    if (state.surahAyahs.isEmpty) {
      return SurahEmptyView(colors: colors);
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

            return AnimatedAyahCard(
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

  Widget _buildSurahHeader(
      List<QuranAyahEntity> ayahs,
      ) {
    return BlocSelector<QuranCubit, QuranState, QuranAudioStatus>(
      bloc: quranCubit,
      selector: (state) => state.audioStatus,
      builder: (context, audioStatus) {
        return SurahHeader(
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
        return AyahCard(
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
}
