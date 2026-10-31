
import 'package:flutter/material.dart';

import 'package:zad/features/azkar/presentation/screens/azkar_screen.dart';
import 'package:zad/features/prayer_times/presentation/screens/prayer_times_screen.dart';
import 'package:zad/features/qibla/presentation/screens/qibla_screen.dart';
import 'package:zad/features/quran/presentation/screens/quran_screen.dart';
import 'package:zad/features/sebha/presentation/screens/sebha_screen.dart';
import 'package:zad/features/settings/presentation/screens/setting_screen.dart';

import '../../../../core/dependency_injection/injection_container.dart';
import '../../../notifications/data/datasources/notification_service.dart';
import '../../../notifications/domain/usecases/initialize_notifications.dart';

import '../widgets/daily_ayah_card.dart';
import '../widgets/home_header.dart';
import '../widgets/prayer_card.dart';
import '../widgets/quick_action_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _floatingController;

  late Animation<double> _fadeAnimation;

  late Animation<Offset> _headerSlide;
  late Animation<Offset> _ayahSlide;
  late Animation<Offset> _prayerSlide;
  late Animation<Offset> _quickSlide;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _headerSlide =
        Tween<Offset>(begin: const Offset(0, -0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.00, 0.22, curve: Curves.easeOutCubic),
          ),
        );

    _ayahSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.12, 0.48, curve: Curves.easeOutCubic),
      ),
    );

    _prayerSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.32, 0.68, curve: Curves.easeOutCubic),
      ),
    );

    _quickSlide = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.52, 1.00, curve: Curves.easeOutCubic),
      ),
    );

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _entranceController.forward();

    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      await sl<InitializeNotifications>()();

      await NotificationService.testAzkarNotification();

      await NotificationService.debugPendingNotifications();

      debugPrint('ZAD: Notifications initialized successfully.');
    } catch (e) {
      debugPrint('ZAD: Notification initialization failed: $e');
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  Widget _animatedSection({
    required Animation<Offset> slide,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: slide, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(

        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _animatedSection(
                  slide: _headerSlide,
                  child: HomeHeader(
                    onSettingsTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                _animatedSection(
                  slide: _headerSlide,
                  child: _buildDateCard(context),
                ),

                const SizedBox(height: 22),

                _animatedSection(
                  slide: _ayahSlide,
                  child: AnimatedBuilder(
                    animation: _floatingController,
                    child: const DailyAyahCard(),
                    builder: (context, child) {
                      final value = (_floatingController.value - 0.5) * 2;

                      return Transform.translate(
                        offset: Offset(0, value * 1.2),
                        child: child,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 28),

                _animatedSection(
                  slide: _prayerSlide,
                  child: const _SectionTitle(
                    title: 'مواقيت الصلاة',
                    subtitle: 'تابع صلاتك القادمة',
                    icon: Icons.access_time_rounded,
                  ),
                ),

                const SizedBox(height: 12),

                _animatedSection(
                  slide: _prayerSlide,
                  child: PrayerCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrayerTimesScreen(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),

                _animatedSection(
                  slide: _quickSlide,
                  child: const _SectionTitle(
                    title: 'استكشف زاد',
                    subtitle: 'عبادتك اليومية في مكان واحد',
                    icon: Icons.auto_awesome_rounded,
                  ),
                ),

                const SizedBox(height: 14),

                _animatedSection(
                  slide: _quickSlide,
                  child: _buildQuickActions(context),
                ),

                const SizedBox(height: 28),

                _animatedSection(
                  slide: _quickSlide,
                  child: _buildMotivationalCard(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildDateCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final now = DateTime.now();
    final formattedDate = '${now.day} / ${now.month} / ${now.year}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.65),
          width: 1.1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: colors.primary.withValues(alpha: 0.28),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Icon(
                Icons.calendar_month_rounded,
                size: 17,
                color: colors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'اليوم',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: colors.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Text(
              formattedDate,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.auto_awesome,
              size: 13,
              color: colors.primary.withValues(alpha: 0.65),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            QuickActionCard(
              icon: Icons.menu_book_rounded,
              title: 'القرآن',
              subtitle: 'اقرأ وتدبر كتاب الله',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QuranScreen()),
                );
              },
            ),
            const SizedBox(width: 12),
            QuickActionCard(
              icon: Icons.auto_awesome_rounded,
              title: 'الأذكار',
              subtitle: 'أذكارك اليومية',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AzkarScreen()),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            QuickActionCard(
              icon: Icons.explore_rounded,
              title: 'القبلة',
              subtitle: 'حدد اتجاه القبلة',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QiblaScreen()),
                );
              },
            ),
            const SizedBox(width: 12),
            QuickActionCard(
              icon: Icons.touch_app_rounded,
              title: 'السبحة',
              subtitle: 'اذكر الله وسبّح',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SebhaScreen()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildMotivationalCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

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
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: colors.primary.withValues(alpha: 0.28),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.11),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.favorite_rounded,
                color: colors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    textAlign: TextAlign.start,
                    'لا تنسَ وردك اليوم',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    textAlign: TextAlign.start,
                    'خطوة صغيرة اليوم تصنع أثرًا كبيرًا.',
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.auto_awesome,
              size: 17,
              color: colors.primary.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              textAlign: TextAlign.start,
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              textAlign: TextAlign.start,
              subtitle,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
