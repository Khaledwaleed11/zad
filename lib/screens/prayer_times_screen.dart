import 'dart:async';

import 'package:flutter/material.dart';

import '../models/prayer_times_model.dart';
import '../services/prayer_service.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen>
    with TickerProviderStateMixin {
  final PrayerService prayerService = PrayerService();

  PrayerTimesModel? prayerTimes;

  Timer? countdownTimer;

  bool isLoading = true;
  String? errorMessage;

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

    loadPrayerTimes();
  }


  Future<void> loadPrayerTimes() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

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

      _pageController.forward(from: 0);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }


  void updateNextPrayer() {
    if (prayerTimes == null) {
      return;
    }

    final now = DateTime.now();

    final prayers = <String, String>{
      'الفجر': prayerTimes!.fajr,
      'الظهر': prayerTimes!.dhuhr,
      'العصر': prayerTimes!.asr,
      'المغرب': prayerTimes!.maghrib,
      'العشاء': prayerTimes!.isha,
    };

    String? foundName;
    String? foundTime;
    DateTime? foundDate;

    for (final entry in prayers.entries) {
      final dateTime = _createTodayDateTime(entry.value);

      if (dateTime == null) {
        continue;
      }

      if (dateTime.isAfter(now)) {
        foundName = entry.key;
        foundTime = entry.value;
        foundDate = dateTime;
        break;
      }
    }


    if (foundDate == null) {
      final tomorrowFajr = _createTomorrowDateTime(prayerTimes!.fajr);

      if (tomorrowFajr != null) {
        foundName = 'الفجر';
        foundTime = prayerTimes!.fajr;
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

  DateTime? _createTomorrowDateTime(String time) {
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,

        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,

              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),

              child: Icon(
                Icons.access_time_rounded,
                size: 20,
                color: colors.primary,
              ),
            ),

            const SizedBox(width: 10),

            const Text(
              'مواقيت الصلاة',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
            ),
          ],
        ),

        centerTitle: true,

        actions: [
          IconButton(
            onPressed: loadPrayerTimes,
            tooltip: 'تحديث',

            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),

      body: _buildBody(context, colors),
    );
  }


  Widget _buildBody(BuildContext context, ColorScheme colors) {
    if (isLoading) {
      return _buildLoading(colors);
    }

    if (errorMessage != null || prayerTimes == null) {
      return _buildError(colors);
    }

    return FadeTransition(
      opacity: _fadeAnimation,

      child: SlideTransition(
        position: _slideAnimation,

        child: RefreshIndicator(
          onRefresh: loadPrayerTimes,

          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),

            padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),

            children: [
              _buildHero(context, colors),

              const SizedBox(height: 18),

              _buildNextPrayer(context, colors),

              const SizedBox(height: 16),

              _buildPrayersGrid(context, colors),

              const SizedBox(height: 16),

              _buildSunInfo(context, colors),

              const SizedBox(height: 16),

              _buildLocationCard(colors),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildHero(BuildContext context, ColorScheme colors) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,

          colors: [
            colors.primary,
            Color.lerp(colors.primary, colors.primaryContainer, 0.45)!,
          ],
        ),

        borderRadius: BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.15),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.mosque_rounded,
              color: Colors.white,
              size: 29,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'اليوم',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  'مواقيت الصلاة',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  'اعرف مواعيد صلواتك واستعد في وقتها',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextPrayer(BuildContext context, ColorScheme colors) {
    return AnimatedBuilder(
      animation: _pulseController,

      builder: (context, child) {
        final glow = 0.05 + (_pulseController.value * 0.04);

        return Container(
          width: double.infinity,

          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: colors.surface,

            borderRadius: BorderRadius.circular(24),

            border: Border.all(color: colors.primary.withValues(alpha: 0.18)),

            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: glow),
                blurRadius: 22,
                offset: const Offset(0, 7),
              ),
            ],
          ),

          child: child,
        );
      },

      child: Column(
        children: [
          Text(
            'الصلاة القادمة',

            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 8),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),

            child: Text(
              nextPrayerName,

              key: ValueKey(nextPrayerName),

              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: colors.onSurface,
              ),
            ),
          ),

          const SizedBox(height: 4),

          Text(
            formatPrayerTime(nextPrayerTime),

            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: colors.primary,
            ),
          ),

          const SizedBox(height: 18),

          Container(
            width: double.infinity,

            padding: const EdgeInsets.symmetric(vertical: 14),

            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.07),

              borderRadius: BorderRadius.circular(16),
            ),

            child: Column(
              children: [
                Text(
                  'متبقي على الصلاة',

                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 5),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),

                  child: Text(
                    formatCountdown(remainingTime),

                    key: ValueKey(remainingTime.inSeconds),

                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: colors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildPrayersGrid(BuildContext context, ColorScheme colors) {
    final prayers = [
      ('الفجر', prayerTimes!.fajr, Icons.nightlight_round),
      ('الظهر', prayerTimes!.dhuhr, Icons.wb_sunny_outlined),
      ('العصر', prayerTimes!.asr, Icons.wb_sunny_rounded),
      ('المغرب', prayerTimes!.maghrib, Icons.wb_twilight_rounded),
      ('العشاء', prayerTimes!.isha, Icons.nights_stay_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          colors,
          'الصلوات',
          'مواعيد اليوم',
          Icons.mosque_outlined,
        ),

        const SizedBox(height: 10),

        ...prayers.map((prayer) {
          final isNext = prayer.$1 == nextPrayerName;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),

            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),

              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),

              decoration: BoxDecoration(
                color: isNext
                    ? colors.primary.withValues(alpha: 0.10)
                    : colors.surface,

                borderRadius: BorderRadius.circular(18),

                border: Border.all(
                  color: isNext
                      ? colors.primary.withValues(alpha: 0.22)
                      : colors.outlineVariant.withValues(alpha: 0.30),
                ),
              ),

              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,

                    decoration: BoxDecoration(
                      color: isNext
                          ? colors.primary
                          : colors.primary.withValues(alpha: 0.09),

                      borderRadius: BorderRadius.circular(13),
                    ),

                    child: Icon(
                      prayer.$3,
                      size: 20,
                      color: isNext ? colors.onPrimary : colors.primary,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prayer.$1,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: colors.onSurface,
                          ),
                        ),

                        if (isNext)
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              'الصلاة القادمة',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: colors.primary,
                              ),
                            ),
                          ),
                      ],
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
          );
        }),
      ],
    );
  }


  Widget _buildSunInfo(BuildContext context, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          colors,
          'الشروق والغروب',
          'معلومات اليوم',
          Icons.wb_sunny_outlined,
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _buildSmallInfoCard(
                colors,
                icon: Icons.wb_sunny_outlined,
                title: 'الشروق',
                value: formatPrayerTime(prayerTimes!.sunrise),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _buildSmallInfoCard(
                colors,
                icon: Icons.wb_twilight_rounded,
                title: 'الغروب',
                value: formatPrayerTime(prayerTimes!.sunset),
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
    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: colors.surface,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.30),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,

            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.09),

              borderRadius: BorderRadius.circular(11),
            ),

            child: Icon(icon, size: 18, color: colors.primary),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(ColorScheme colors) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),

      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.06),

        borderRadius: BorderRadius.circular(17),
      ),

      child: Row(
        children: [
          Icon(Icons.location_on_rounded, size: 19, color: colors.primary),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الموقع',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  'القاهرة، مصر',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
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

  Widget _buildSectionTitle(
    ColorScheme colors,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,

          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.10),

            borderRadius: BorderRadius.circular(12),
          ),

          child: Icon(icon, size: 19, color: colors.primary),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 2),

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
      ],
    );
  }


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
            ),

            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: colors.primary,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'جاري تحميل المواقيت...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'نحدد لك الصلاة القادمة',
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }


  Widget _buildError(ColorScheme colors) {
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
                color: colors.error.withValues(alpha: 0.10),

                shape: BoxShape.circle,
              ),

              child: Icon(
                Icons.cloud_off_rounded,
                size: 40,
                color: colors.error,
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
              onPressed: loadPrayerTimes,

              icon: const Icon(Icons.refresh_rounded),

              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
