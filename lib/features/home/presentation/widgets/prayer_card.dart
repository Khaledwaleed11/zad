import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/dependency_injection/injection_container.dart';
import '../../../../features/prayer_times/domain/entities/prayer_times_entity.dart';
import '../../../../features/prayer_times/presentation/cubit/prayer_times_cubit.dart';
import '../../../../features/prayer_times/presentation/cubit/prayer_times_state.dart';

class PrayerCard extends StatelessWidget {
  final VoidCallback? onTap;

  const PrayerCard({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PrayerTimesCubit>()..loadPrayerTimes(),
      child: _PrayerCardView(onTap: onTap),
    );
  }
}

class _PrayerCardView extends StatefulWidget {
  final VoidCallback? onTap;

  const _PrayerCardView({this.onTap});

  @override
  State<_PrayerCardView> createState() => _PrayerCardViewState();
}

class _PrayerCardViewState extends State<_PrayerCardView>
    with SingleTickerProviderStateMixin {
  Timer? countdownTimer;

  String nextPrayerName = '';
  String nextPrayerTime = '';

  Duration remainingTime = Duration.zero;

  late AnimationController _tapController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(
      CurvedAnimation(
        parent: _tapController,
        curve: Curves.easeOut,
      ),
    );
  }

  void _startCountdown(PrayerTimesEntity prayerTimes) {
    countdownTimer?.cancel();

    _updateNextPrayer(prayerTimes);

    countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => _updateNextPrayer(prayerTimes),
    );
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

    String? foundPrayerName;
    String? foundPrayerTime;
    DateTime? foundPrayerDateTime;

    for (final entry in prayers.entries) {
      final prayerDateTime = _createDateTimeForToday(entry.value);

      if (prayerDateTime == null) {
        continue;
      }

      if (prayerDateTime.isAfter(now)) {
        foundPrayerName = entry.key;
        foundPrayerTime = entry.value;
        foundPrayerDateTime = prayerDateTime;
        break;
      }
    }

    if (foundPrayerDateTime == null) {
      final fajrTomorrow = _createDateTimeForTomorrow(prayerTimes.fajr);

      if (fajrTomorrow != null) {
        foundPrayerName = 'الفجر';
        foundPrayerTime = prayerTimes.fajr;
        foundPrayerDateTime = fajrTomorrow;
      }
    }

    if (foundPrayerDateTime == null ||
        foundPrayerName == null ||
        foundPrayerTime == null) {
      return;
    }

    final difference = foundPrayerDateTime.difference(now);

    if (!mounted) return;

    setState(() {
      nextPrayerName = foundPrayerName!;
      nextPrayerTime = foundPrayerTime!;
      remainingTime = difference.isNegative ? Duration.zero : difference;
    });
  }

  DateTime? _createDateTimeForToday(String time) {
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

  DateTime? _createDateTimeForTomorrow(String time) {
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

      final period = hour >= 12 ? 'مساءً' : 'صباحًا';

      hour %= 12;

      if (hour == 0) {
        hour = 12;
      }

      return '$hour:$minute $period';
    } catch (_) {
      return time;
    }
  }

  String formatCountdown(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes =
    duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
    duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  Future<void> _handleTap() async {
    if (widget.onTap == null) return;

    await _tapController.forward();

    if (!mounted) return;

    widget.onTap!();

    _tapController.reverse();
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    _tapController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

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
        return AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(23),
            child: InkWell(
              onTap: widget.onTap == null ? null : _handleTap,
              borderRadius: BorderRadius.circular(23),
              splashColor: colors.primary.withValues(alpha: 0.06),
              highlightColor: colors.primary.withValues(alpha: 0.03),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(23),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.75),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.35),
                      width: 0.8,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        right: 0,
                        child: _CornerDecoration(color: colors.primary),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: _CornerDecoration(color: colors.primary),
                      ),
                      _buildContent(context, state),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(
      BuildContext context,
      PrayerTimesState state,
      ) {
    if (state.status == PrayerTimesStatus.initial ||
        state.status == PrayerTimesStatus.loading) {
      return _buildLoading(context);
    }

    if (state.status == PrayerTimesStatus.failure ||
        state.prayerTimes == null) {
      return _buildError(context);
    }

    return _buildPrayerContent(context, state.prayerTimes!);
  }

  Widget _buildPrayerContent(
      BuildContext context,
      PrayerTimesEntity prayerTimes,
      ) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.30),
                ),
              ),
              child: Icon(
                Icons.mosque_rounded,
                color: colors.primary,
                size: 23,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مواقيت الصلاة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 13,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'القاهرة',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_back_ios_rounded,
              size: 13,
              color: colors.primary,
            ),
            const SizedBox(width: 5),
          ],
        ),

        const SizedBox(height: 19),

        // Next Prayer Section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                colors.primary.withValues(alpha: 0.17),
                colors.primary.withValues(alpha: 0.055),
              ],
            ),
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.22),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.access_time_rounded,
                      color: colors.onPrimary,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الصلاة القادمة',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          nextPrayerName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: colors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatPrayerTime(nextPrayerTime),
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'موعد الصلاة',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(
                height: 1,
                color: colors.primary.withValues(alpha: 0.25),
              ),
              const SizedBox(height: 13),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.hourglass_bottom_rounded,
                    color: colors.primary,
                    size: 17,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'متبقي على الصلاة',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    formatCountdown(remainingTime),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: colors.primary,
                      letterSpacing: 0.7,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 19),

        // Prayer Times
        Row(
          children: [
            Expanded(
              child: Divider(
                color: colors.primary.withValues(alpha: 0.25),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'مواقيت اليوم',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: colors.primary.withValues(alpha: 0.25),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _PrayerTime(
              name: 'الفجر',
              time: prayerTimes.fajr,
              isNext: nextPrayerName == 'الفجر',
            ),
            _PrayerTime(
              name: 'الظهر',
              time: prayerTimes.dhuhr,
              isNext: nextPrayerName == 'الظهر',
            ),
            _PrayerTime(
              name: 'العصر',
              time: prayerTimes.asr,
              isNext: nextPrayerName == 'العصر',
            ),
            _PrayerTime(
              name: 'المغرب',
              time: prayerTimes.maghrib,
              isNext: nextPrayerName == 'المغرب',
            ),
            _PrayerTime(
              name: 'العشاء',
              time: prayerTimes.isha,
              isNext: nextPrayerName == 'العشاء',
            ),
          ],
        ),

        const SizedBox(height: 15),

        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'اضغط لعرض كل المواقيت',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 5),
              Icon(
                Icons.arrow_back_rounded,
                size: 14,
                color: colors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoading(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 185,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'جاري تحميل مواقيت الصلاة...',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 190,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 38,
              color: colors.primary,
            ),
            const SizedBox(height: 10),
            Text(
              'تعذر تحميل مواقيت الصلاة',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                context.read<PrayerTimesCubit>().loadPrayerTimes();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.primary,
                side: BorderSide(color: colors.primary),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 17),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrayerTime extends StatelessWidget {
  final String name;
  final String time;
  final bool isNext;

  const _PrayerTime({
    required this.name,
    required this.time,
    this.isNext = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: isNext
                ? colors.primary.withValues(alpha: 0.13)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: isNext
                  ? colors.primary.withValues(alpha: 0.55)
                  : Colors.transparent,
            ),
          ),
          child: Column(
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isNext ? colors.primary : colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                time,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: isNext ? colors.primary : colors.onSurface,
                ),
              ),
              if (isNext) ...[
                const SizedBox(height: 5),
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CornerDecoration extends StatelessWidget {
  final Color color;

  const _CornerDecoration({
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.auto_awesome,
      size: 15,
      color: color.withValues(alpha: 0.45),
    );
  }
}