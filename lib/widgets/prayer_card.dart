import 'dart:async';

import 'package:flutter/material.dart';

import '../models/prayer_times_model.dart';
import '../services/prayer_service.dart';

class PrayerCard extends StatefulWidget {
  final VoidCallback? onTap;

  const PrayerCard({super.key, this.onTap});

  @override
  State<PrayerCard> createState() => _PrayerCardState();
}

class _PrayerCardState extends State<PrayerCard>
    with SingleTickerProviderStateMixin {
  final PrayerService prayerService = PrayerService();

  PrayerTimesModel? prayerTimes;

  bool isLoading = true;
  String? errorMessage;

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
    ).animate(CurvedAnimation(parent: _tapController, curve: Curves.easeOut));

    loadPrayerTimes();
  }

  Future<void> loadPrayerTimes() async {
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
          errorMessage = null;
        });
      }

      countdownTimer?.cancel();

      final result = await prayerService.getPrayerTimes();

      if (!mounted) return;

      setState(() {
        prayerTimes = result;
        isLoading = false;
      });

      updateNextPrayer();

      countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        updateNextPrayer();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void updateNextPrayer() {
    if (prayerTimes == null) return;

    final now = DateTime.now();

    final prayers = <String, String>{
      'الفجر': prayerTimes!.fajr,
      'الظهر': prayerTimes!.dhuhr,
      'العصر': prayerTimes!.asr,
      'المغرب': prayerTimes!.maghrib,
      'العشاء': prayerTimes!.isha,
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
      final fajrTomorrow = _createDateTimeForTomorrow(prayerTimes!.fajr);

      if (fajrTomorrow != null) {
        foundPrayerName = 'الفجر';
        foundPrayerTime = prayerTimes!.fajr;
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
      final parts = time.split(':');

      if (parts.length < 2) {
        return null;
      }

      final hour = int.parse(parts[0]);

      final minute = int.parse(parts[1]);

      final now = DateTime.now();

      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (_) {
      return null;
    }
  }

  DateTime? _createDateTimeForTomorrow(String time) {
    try {
      final parts = time.split(':');

      if (parts.length < 2) {
        return null;
      }

      final hour = int.parse(parts[0]);

      final minute = int.parse(parts[1]);

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
      final parts = time.split(':');

      if (parts.length < 2) {
        return time;
      }

      int hour = int.parse(parts[0]);

      final minute = parts[1];

      final period = hour >= 12 ? 'PM' : 'AM';

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

    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');

    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  Future<void> _handleTap() async {
    if (widget.onTap == null) {
      return;
    }

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
    final theme = Theme.of(context);

    final colors = theme.colorScheme;

    return AnimatedBuilder(
      animation: _scaleAnimation,

      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },

      child: Material(
        color: colors.surface,

        borderRadius: BorderRadius.circular(22),

        child: InkWell(
          onTap: widget.onTap == null ? null : _handleTap,

          borderRadius: BorderRadius.circular(22),

          splashColor: colors.primary.withValues(alpha: 0.06),

          highlightColor: colors.primary.withValues(alpha: 0.03),

          child: Container(
            width: double.infinity,

            padding: const EdgeInsets.all(18),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),

              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.35),
              ),

              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.035),

                  blurRadius: 14,

                  offset: const Offset(0, 6),
                ),
              ],
            ),

            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (isLoading) {
      return _buildLoading(context);
    }

    if (errorMessage != null || prayerTimes == null) {
      return _buildError(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,

              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.10),

                borderRadius: BorderRadius.circular(12),
              ),

              child: Icon(
                Icons.mosque_rounded,
                color: colors.primary,
                size: 20,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    'مواقيت الصلاة',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: colors.onSurface,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: colors.onSurfaceVariant,
                      ),

                      const SizedBox(width: 3),

                      Text(
                        'القاهرة',
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
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: colors.onSurfaceVariant,
            ),

            const SizedBox(width: 4),
          ],
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(15),

          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.08),

            borderRadius: BorderRadius.circular(17),
          ),

          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,

                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),

                child: Icon(
                  Icons.access_time_rounded,
                  color: colors.onPrimary,
                  size: 22,
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
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      nextPrayerName,
                      style: TextStyle(
                        fontSize: 18,
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
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: colors.primary,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    formatCountdown(remainingTime),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurfaceVariant,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 13),

        Container(
          width: double.infinity,

          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),

          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.045),

            borderRadius: BorderRadius.circular(14),
          ),

          child: Row(
            children: [
              Icon(Icons.timer_outlined, size: 16, color: colors.primary),

              const SizedBox(width: 7),

              Expanded(
                child: Text(
                  'متبقي على $nextPrayerName',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),

              Text(
                formatCountdown(remainingTime),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: colors.primary,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            _PrayerTime(name: 'الفجر', time: prayerTimes!.fajr),

            _PrayerTime(name: 'الظهر', time: prayerTimes!.dhuhr),

            _PrayerTime(name: 'العصر', time: prayerTimes!.asr),

            _PrayerTime(name: 'المغرب', time: prayerTimes!.maghrib),

            _PrayerTime(name: 'العشاء', time: prayerTimes!.isha),
          ],
        ),

        const SizedBox(height: 4),

        Align(
          alignment: Alignment.centerLeft,

          child: Text(
            'اضغط لعرض كل المواقيت',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: colors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoading(BuildContext context) {

    return const SizedBox(
      height: 185,

      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),

            SizedBox(height: 14),

            Text(
              'جاري تحميل مواقيت الصلاة...',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
              color: colors.onSurfaceVariant,
            ),

            const SizedBox(height: 10),

            Text(
              'تعذر تحميل مواقيت الصلاة',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: loadPrayerTimes,

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

  const _PrayerTime({required this.name, required this.time});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: colors.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          time,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
          ),
        ),
      ],
    );
  }
}
