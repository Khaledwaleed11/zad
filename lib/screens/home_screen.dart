import 'package:flutter/material.dart';
import 'package:zad/screens/azkar_screen.dart';
import 'package:zad/screens/prayer_times_screen.dart';
import 'package:zad/screens/qibla_screen.dart';
import 'package:zad/screens/quran_screen.dart';
import 'package:zad/screens/sebha_screen.dart';
import 'package:zad/screens/setting_screen.dart';

import '../widgets/daily_ayah_card.dart';
import '../widgets/home_header.dart';
import '../widgets/prayer_card.dart';
import '../widgets/quick_action_card.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
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

    _ayahSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.12, 0.48, curve: Curves.easeOutCubic),
          ),
        );

    _prayerSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.32, 0.68, curve: Curves.easeOutCubic),
          ),
        );

    _quickSlide = Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero)
        .animate(
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
    final colors = theme.colorScheme;

    return Scaffold(
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
                        builder: (_) => SettingsScreen(
                          isDarkMode: widget.isDarkMode,
                          onThemeToggle: widget.onThemeToggle,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              _animatedSection(
                slide: _headerSlide,
                child: _buildWelcomeSection(context),
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
                child: _SectionTitle(
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
                child: _SectionTitle(
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
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final now = DateTime.now();

    final formattedDate = '${now.day} / ${now.month} / ${now.year}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'أهلاً بك في زاد',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'اجعل يومك أقرب إلى الله',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),

          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),

            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.30),
            ),
          ),

          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 13,
                color: colors.primary,
              ),

              const SizedBox(width: 6),

              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
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

      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withValues(alpha: 0.10),
            colors.secondary.withValues(alpha: 0.08),
          ],
        ),

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: colors.primary.withValues(alpha: 0.10)),
      ),

      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
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
                  'لا تنسَ وردك اليوم',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'خطوة صغيرة اليوم تصنع أثرًا كبيرًا.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 13,
            color: colors.primary,
          ),
        ],
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
              title,
              style: TextStyle(
                fontSize: 18,
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
      ],
    );
  }
}
