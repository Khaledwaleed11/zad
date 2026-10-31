import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../core/dependency_injection/injection_container.dart';
import '../../domain/entities/prayer_times_entity.dart';
import '../cubit/prayer_times_cubit.dart';
import '../cubit/prayer_times_state.dart';

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
          appBar: _buildAppBar(context, colors),
          body: _buildBody(context, colors, state),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ColorScheme colors) {
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
            'مواقيت الصلاة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: 1,
                color: colors.primary.withValues(alpha: 0.6),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  Icons.auto_awesome,
                  size: 11,
                  color: colors.primary,
                ),
              ),
              Container(
                width: 20,
                height: 1,
                color: colors.primary.withValues(alpha: 0.6),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              context.read<PrayerTimesCubit>().loadPrayerTimes();
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                Icons.refresh_rounded,
                size: 20,
                color: colors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    ColorScheme colors,
    PrayerTimesState state,
  ) {
    if (state.status == PrayerTimesStatus.initial ||
        state.status == PrayerTimesStatus.loading) {
      return _buildLoading(colors);
    }

    if (state.status == PrayerTimesStatus.failure ||
        state.prayerTimes == null) {
      return _buildError(context, colors);
    }

    final prayerTimes = state.prayerTimes!;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: RefreshIndicator(
          color: colors.primary,
          onRefresh: () {
            return context.read<PrayerTimesCubit>().loadPrayerTimes();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
            children: [
              _buildHero(colors),
              const SizedBox(height: 20),
              _buildNextPrayer(colors),
              const SizedBox(height: 22),
              _buildPrayersGrid(colors, prayerTimes),
              const SizedBox(height: 22),
              _buildSunInfo(colors, prayerTimes),
              const SizedBox(height: 18),
              _buildLocationCard(colors),
            ],
          ),
        ),
      ),
    );
  }

  // Hero

  Widget _buildHero(ColorScheme colors) {
    return _DecoratedCard(
      colors: colors,
      padding: const EdgeInsets.all(19),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            child: Icon(Icons.mosque_rounded, size: 29, color: colors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اليوم',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'مواقيت الصلاة',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'اعرف مواعيد صلواتك واستعد في وقتها',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.auto_awesome,
            color: colors.primary.withValues(alpha: 0.45),
            size: 20,
          ),
        ],
      ),
    );
  }

  // Next Prayer

  Widget _buildNextPrayer(ColorScheme colors) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final glow = 0.04 + (_pulseController.value * 0.035);

        return Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.65),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: glow),
                blurRadius: 20,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
            ),
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.access_time_rounded, size: 15, color: colors.primary),
              const SizedBox(width: 6),
              Text(
                'الصلاة القادمة',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              nextPrayerName,
              key: ValueKey(nextPrayerName),
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: colors.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            formatPrayerTime(nextPrayerTime),
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Text(
                  'متبقي على الصلاة',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 7),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Text(
                    formatCountdown(remainingTime),
                    key: ValueKey(remainingTime.inSeconds),
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: colors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Icon(
            Icons.auto_awesome,
            size: 17,
            color: colors.primary.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  // Prayer Times

  Widget _buildPrayersGrid(ColorScheme colors, PrayerTimesEntity prayerTimes) {
    final prayers = [
      ('الفجر', prayerTimes.fajr, Icons.nightlight_round),
      ('الظهر', prayerTimes.dhuhr, Icons.wb_sunny_outlined),
      ('العصر', prayerTimes.asr, Icons.wb_sunny_rounded),
      ('المغرب', prayerTimes.maghrib, Icons.wb_twilight_rounded),
      ('العشاء', prayerTimes.isha, Icons.nights_stay_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          colors,
          'الصلوات',
          'مواعيد الصلوات الخمس',
          Icons.mosque_outlined,
        ),
        const SizedBox(height: 12),
        ...prayers.map((prayer) {
          final isNext = prayer.$1 == nextPrayerName;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: isNext
                    ? colors.primary.withValues(alpha: 0.12)
                    : colors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isNext
                      ? colors.primary.withValues(alpha: 0.65)
                      : colors.primary.withValues(alpha: 0.22),
                  width: isNext ? 1.2 : 0.8,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 43,
                      height: 43,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(prayer.$3, size: 21, color: colors.primary),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prayer.$1,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: colors.onSurface,
                            ),
                          ),
                          if (isNext)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'الصلاة القادمة',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: colors.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (isNext)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 9),
                        child: Icon(
                          Icons.check_circle_rounded,
                          size: 17,
                          color: colors.primary,
                        ),
                      ),
                    Text(
                      formatPrayerTime(prayer.$2),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: isNext ? colors.primary : colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // Sunrise & Sunset

  Widget _buildSunInfo(ColorScheme colors, PrayerTimesEntity prayerTimes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          colors,
          'الشروق والغروب',
          'معلومات إضافية لليوم',
          Icons.wb_sunny_outlined,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSmallInfoCard(
                colors,
                icon: Icons.wb_sunny_outlined,
                title: 'الشروق',
                value: formatPrayerTime(prayerTimes.sunrise),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSmallInfoCard(
                colors,
                icon: Icons.wb_twilight_rounded,
                title: 'الغروب',
                value: formatPrayerTime(prayerTimes.sunset),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallInfoCard(
    ColorScheme colors, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return _DecoratedCard(
      colors: colors,
      padding: const EdgeInsets.all(13),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, size: 21, color: colors.primary),
          ),
          const SizedBox(height: 9),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Location

  Widget _buildLocationCard(ColorScheme colors) {
    return _DecoratedCard(
      colors: colors,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      child: Row(
        children: [
          Icon(Icons.location_on_rounded, size: 21, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الموقع',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'القاهرة، مصر',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle_rounded, size: 19, color: colors.primary),
        ],
      ),
    );
  }

  // Section Title

  Widget _buildSectionTitle(
    ColorScheme colors,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
          ),
          child: Icon(icon, size: 20, color: colors.primary),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.auto_awesome,
          size: 16,
          color: colors.primary.withValues(alpha: 0.5),
        ),
      ],
    );
  }

  // Loading

  Widget _buildLoading(ColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.09),
              shape: BoxShape.circle,
              border: Border.all(color: colors.primary.withValues(alpha: 0.4)),
            ),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: colors.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'جاري تحميل المواقيت...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'نحدد لك الصلاة القادمة',
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  // Error

  Widget _buildError(BuildContext context, ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 40,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'تعذر تحميل المواقيت',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'تأكد من الاتصال بالإنترنت وحاول مرة أخرى.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
              ),
              onPressed: () {
                context.read<PrayerTimesCubit>().loadPrayerTimes();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable decorated card

class _DecoratedCard extends StatelessWidget {
  final ColorScheme colors;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _DecoratedCard({
    required this.colors,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.65),
          width: 1.1,
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: colors.primary.withValues(alpha: 0.28),
            width: 0.8,
          ),
        ),
        child: child,
      ),
    );
  }
}
