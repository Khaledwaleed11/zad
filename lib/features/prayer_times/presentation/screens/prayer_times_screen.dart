import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../core/dependency_injection/injection_container.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/prayer_times_entity.dart';
import '../cubit/prayer_times_cubit.dart';
import '../cubit/prayer_times_state.dart';
import '../widgets/prayer_times_state_views.dart';
import '../widgets/prayer_times_widgets.dart';

class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PrayerTimesCubit>()..loadPrayerTimes(),
      child: const _PrayerTimesView(),
    );
  }
}

class _PrayerTimesView extends StatefulWidget {
  const _PrayerTimesView();

  @override
  State<_PrayerTimesView> createState() => _PrayerTimesViewState();
}

class _PrayerTimesViewState extends State<_PrayerTimesView>
    with TickerProviderStateMixin {
  Timer? countdownTimer;
  String nextPrayerName = '';
  String nextPrayerTime = '';
  Duration remainingTime = Duration.zero;
  late AnimationController _pageController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(parent: _pageController, curve: Curves.easeOutCubic),
        );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  void _startCountdown(PrayerTimesEntity prayerTimes) {
    countdownTimer?.cancel();

    _updateNextPrayer(prayerTimes);

    countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateNextPrayer(prayerTimes),
    );

    _pageController.forward(from: 0);
  }

  void _updateNextPrayer(PrayerTimesEntity prayerTimes) {
    final now = DateTime.now();

    final prayers = <String, String>{
      'الفجر': prayerTimes.fajr,
      'الظهر': prayerTimes.dhuhr,
      'العصر': prayerTimes.asr,
      'المغرب': prayerTimes.maghrib,
      'العشاء': prayerTimes.isha,
    };

    String? foundName;
    String? foundTime;
    DateTime? foundDate;

    for (final entry in prayers.entries) {
      final dateTime = _createTodayDateTime(entry.value);

      if (dateTime == null) continue;

      if (dateTime.isAfter(now)) {
        foundName = entry.key;
        foundTime = entry.value;
        foundDate = dateTime;
        break;
      }
    }

    if (foundDate == null) {
      final tomorrowFajr = _createTomorrowDateTime(prayerTimes.fajr);

      if (tomorrowFajr != null) {
        foundName = 'الفجر';
        foundTime = prayerTimes.fajr;
        foundDate = tomorrowFajr;
      }
    }

    if (foundDate == null || foundName == null || foundTime == null) {
      return;
    }

    final difference = foundDate.difference(now);

    if (!mounted) return;

    setState(() {
      nextPrayerName = foundName!;
      nextPrayerTime = foundTime!;
      remainingTime = difference.isNegative ? Duration.zero : difference;
    });
  }

  DateTime? _createTodayDateTime(String time) {
    try {
      final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(time.trim());

      if (match == null) return null;

      final hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);

      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        return null;
      }

      final now = DateTime.now();

      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (_) {
      return null;
    }
  }

  DateTime? _createTomorrowDateTime(String time) {
    try {
      final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(time.trim());

      if (match == null) return null;

      final hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);

      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        return null;
      }

      final tomorrow = DateTime.now().add(const Duration(days: 1));

      return DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        hour,
        minute,
      );
    } catch (_) {
      return null;
    }
  }

  String formatPrayerTime(String time) {
    try {
      final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(time.trim());

      if (match == null) return time;

      int hour = int.parse(match.group(1)!);
      final minute = match.group(2)!;

      if (hour < 0 || hour > 23) return time;

      final period = hour >= 12 ? 'PM' : 'AM';

      hour %= 12;

      if (hour == 0) hour = 12;

      return '$hour:$minute $period';
    } catch (_) {
      return time;
    }
  }

  String formatCountdown(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocConsumer<PrayerTimesCubit, PrayerTimesState>(
      listener: (context, state) {
        if (state.status == PrayerTimesStatus.success &&
            state.prayerTimes != null) {
          _startCountdown(state.prayerTimes!);
        } else if (state.status == PrayerTimesStatus.loading ||
            state.status == PrayerTimesStatus.failure) {
          countdownTimer?.cancel();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: ResponsiveBody(
            child: SafeArea(
              bottom: false,
              child: _buildBody(context, colors, state),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    ColorScheme colors,
    PrayerTimesState state,
  ) {
    if (state.status == PrayerTimesStatus.initial ||
        state.status == PrayerTimesStatus.loading) {
      return _buildScrollableState(
        context,
        colors,
        PrayerTimesLoadingView(colors: colors),
      );
    }

    if (state.status == PrayerTimesStatus.failure ||
        state.prayerTimes == null) {
      return _buildScrollableState(
        context,
        colors,
        PrayerTimesErrorView(
          colors: colors,
          onRetry: () => context.read<PrayerTimesCubit>().loadPrayerTimes(),
        ),
      );
    }

    final prayerTimes = state.prayerTimes!;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: RefreshIndicator(
          color: colors.primary,
          onRefresh: () => context.read<PrayerTimesCubit>().loadPrayerTimes(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            children: [
              PrayerTimesAppBar(
                colors: colors,
                onRefresh: () =>
                    context.read<PrayerTimesCubit>().loadPrayerTimes(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
                child: Column(
                  children: [
                    PrayerTimesHero(colors: colors),
                    const SizedBox(height: 20),
                    NextPrayerCard(
                      colors: colors,
                      pulseController: _pulseController,
                      prayerName: nextPrayerName,
                      prayerTime: formatPrayerTime(nextPrayerTime),
                      remainingTime: formatCountdown(remainingTime),
                      remainingDuration: remainingTime,
                    ),
                    const SizedBox(height: 22),
                    PrayerTimesList(
                      colors: colors,
                      prayerTimes: prayerTimes,
                      nextPrayerName: nextPrayerName,
                      formatPrayerTime: formatPrayerTime,
                    ),
                    const SizedBox(height: 22),
                    PrayerSunInfo(
                      colors: colors,
                      sunrise: formatPrayerTime(prayerTimes.sunrise),
                      sunset: formatPrayerTime(prayerTimes.sunset),
                    ),
                    const SizedBox(height: 18),
                    PrayerLocationCard(colors: colors),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableState(
    BuildContext context,
    ColorScheme colors,
    Widget stateView,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            children: [
              PrayerTimesAppBar(
                colors: colors,
                onRefresh: () =>
                    context.read<PrayerTimesCubit>().loadPrayerTimes(),
              ),
              SizedBox(
                height: constraints.maxHeight > kToolbarHeight
                    ? constraints.maxHeight - kToolbarHeight
                    : MediaQuery.of(context).size.height * 0.7,
                child: stateView,
              ),
            ],
          ),
        );
      },
    );
  }
}
