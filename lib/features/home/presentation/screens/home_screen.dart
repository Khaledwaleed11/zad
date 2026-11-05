import 'package:flutter/material.dart';
import 'package:zad/features/prayer_times/presentation/screens/prayer_times_screen.dart';
import 'package:zad/features/settings/presentation/screens/setting_screen.dart';
import '../../../dua/presentation/screens/dua_screen.dart';
import '../../../../core/dependency_injection/injection_container.dart';
import '../../../../core/utils/responsive.dart';
import '../../../notifications/domain/usecases/initialize_notifications.dart';

import '../widgets/daily_ayah_card.dart';
import '../widgets/home_header.dart';
import '../widgets/prayer_card.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/home_date_card.dart';
import '../widgets/home_section_title.dart';
import '../widgets/home_motivational_card.dart';

import '../../../azkar/presentation/screens/azkar_screen.dart';
import '../../../qibla/presentation/screens/qibla_screen.dart';
import '../../../quran/presentation/screens/quran_screen.dart';
import '../../../sebha/presentation/screens/sebha_screen.dart';

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
      debugPrint('ZAD: Notifications initialized successfully.');
    } catch (e) {
      debugPrint('ZAD: Notifications initialization failed: $e');
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
      child: SlideTransition(
        position: slide,
        child: child,
      ),
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
            child: Center(
              child: SizedBox(
                width: Responsive.contentWidth(
                  context,
                  maxWidth: 700,
                ),
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
                  child: const HomeDateCard(),
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
                  child: const HomeSectionTitle(
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
                  child: const HomeSectionTitle(
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
                  child: const HomeMotivationalCard(),
                ),
              ],
            ),
          ),
        ),
      ),
        )
      )
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
                  MaterialPageRoute(
                    builder: (_) => const QuranScreen(),
                  ),
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
                  MaterialPageRoute(
                    builder: (_) => const AzkarScreen(),
                  ),
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
                  MaterialPageRoute(
                    builder: (_) => const QiblaScreen(),
                  ),
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
                  MaterialPageRoute(
                    builder: (_) => const SebhaScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            QuickActionCard(
              icon: Icons.volunteer_activism_rounded,
              title: 'الأدعية',
              subtitle: 'أدعية متنوعة لكل وقت',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DuaScreen(),
                  ),
                );
              },
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }
}