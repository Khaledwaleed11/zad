import 'package:flutter/material.dart';

import '../../domain/entities/prayer_times_entity.dart';

class PrayerTimesAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ColorScheme colors;
  final VoidCallback onRefresh;

  const PrayerTimesAppBar({
    super.key,
    required this.colors,
    required this.onRefresh,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            onTap: onRefresh,
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
}

class PrayerTimesHero extends StatelessWidget {
  final ColorScheme colors;

  const PrayerTimesHero({super.key, required this.colors});

  @override
  Widget build(BuildContext context) {
    return PrayerDecoratedCard(
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
}

class NextPrayerCard extends StatelessWidget {
  final ColorScheme colors;
  final Animation<double> pulseController;
  final String prayerName;
  final String prayerTime;
  final String remainingTime;
  final Duration remainingDuration;

  const NextPrayerCard({
    super.key,
    required this.colors,
    required this.pulseController,
    required this.prayerName,
    required this.prayerTime,
    required this.remainingTime,
    required this.remainingDuration,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        final glow = 0.04 + (pulseController.value * 0.035);

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
              prayerName,
              key: ValueKey(prayerName),
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: colors.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            prayerTime,
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
                    remainingTime,
                    key: ValueKey(remainingDuration.inSeconds),
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
}

class PrayerTimesList extends StatelessWidget {
  final ColorScheme colors;
  final PrayerTimesEntity prayerTimes;
  final String nextPrayerName;
  final String Function(String) formatPrayerTime;

  const PrayerTimesList({
    super.key,
    required this.colors,
    required this.prayerTimes,
    required this.nextPrayerName,
    required this.formatPrayerTime,
  });

  @override
  Widget build(BuildContext context) {
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
        PrayerSectionTitle(
          colors: colors,
          title: 'الصلوات',
          subtitle: 'مواعيد الصلوات الخمس',
          icon: Icons.mosque_outlined,
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
}

class PrayerSunInfo extends StatelessWidget {
  final ColorScheme colors;
  final String sunrise;
  final String sunset;

  const PrayerSunInfo({
    super.key,
    required this.colors,
    required this.sunrise,
    required this.sunset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PrayerSectionTitle(
          colors: colors,
          title: 'الشروق والغروب',
          subtitle: 'معلومات إضافية لليوم',
          icon: Icons.wb_sunny_outlined,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: PrayerSmallInfoCard(
                colors: colors,
                icon: Icons.wb_sunny_outlined,
                title: 'الشروق',
                value: sunrise,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrayerSmallInfoCard(
                colors: colors,
                icon: Icons.wb_twilight_rounded,
                title: 'الغروب',
                value: sunset,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class PrayerSmallInfoCard extends StatelessWidget {
  final ColorScheme colors;
  final IconData icon;
  final String title;
  final String value;

  const PrayerSmallInfoCard({
    super.key,
    required this.colors,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return PrayerDecoratedCard(
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
}

class PrayerLocationCard extends StatelessWidget {
  final ColorScheme colors;

  const PrayerLocationCard({super.key, required this.colors});

  @override
  Widget build(BuildContext context) {
    return PrayerDecoratedCard(
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
}

class PrayerSectionTitle extends StatelessWidget {
  final ColorScheme colors;
  final String title;
  final String subtitle;
  final IconData icon;

  const PrayerSectionTitle({
    super.key,
    required this.colors,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
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
}

class PrayerDecoratedCard extends StatelessWidget {
  final ColorScheme colors;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const PrayerDecoratedCard({
    super.key,
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
