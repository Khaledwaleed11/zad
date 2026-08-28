import 'package:flutter/material.dart';

import '../widgets/setting_tile.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pageController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _headerAnimation;
  late Animation<Offset> _appearanceAnimation;
  late Animation<Offset> _prayerAnimation;
  late Animation<Offset> _applicationAnimation;
  late Animation<Offset> _footerAnimation;

  @override
  void initState() {
    super.initState();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOut,
    );

    _headerAnimation =
        Tween<Offset>(begin: const Offset(0, -0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _pageController,
            curve: const Interval(0.00, 0.25, curve: Curves.easeOutCubic),
          ),
        );

    _appearanceAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _pageController,
            curve: const Interval(0.15, 0.45, curve: Curves.easeOutCubic),
          ),
        );

    _prayerAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _pageController,
            curve: const Interval(0.30, 0.60, curve: Curves.easeOutCubic),
          ),
        );

    _applicationAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _pageController,
            curve: const Interval(0.45, 0.75, curve: Curves.easeOutCubic),
          ),
        );

    _footerAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _pageController,
            curve: const Interval(0.65, 1.00, curve: Curves.easeOutCubic),
          ),
        );

    _pageController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
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
                Icons.settings_rounded,
                size: 20,
                color: colors.primary,
              ),
            ),

            const SizedBox(width: 10),

            const Text(
              'الإعدادات',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
            ),
          ],
        ),

        centerTitle: true,
      ),

      body: ListView(
        physics: const BouncingScrollPhysics(),

        padding: const EdgeInsets.fromLTRB(20, 8, 20, 35),

        children: [
          _animatedSection(
            slide: _headerAnimation,
            child: _buildHeroHeader(context, colors),
          ),

          const SizedBox(height: 26),

          _animatedSection(
            slide: _appearanceAnimation,
            child: Column(
              children: [
                _buildSectionHeader(
                  context,
                  icon: Icons.palette_outlined,
                  title: 'المظهر',
                  subtitle: 'خصّص شكل التطبيق',
                ),

                const SizedBox(height: 10),

                _buildThemeTile(context, colors),
              ],
            ),
          ),

          const SizedBox(height: 26),

          _animatedSection(
            slide: _prayerAnimation,
            child: Column(
              children: [
                _buildSectionHeader(
                  context,
                  icon: Icons.mosque_outlined,
                  title: 'الصلاة',
                  subtitle: 'إعدادات مواقيت الصلاة',
                ),

                const SizedBox(height: 10),

                SettingsTile(
                  icon: Icons.location_on_outlined,
                  title: 'الموقع الحالي',
                  subtitle: 'القاهرة، مصر',
                  trailing: _buildArrow(colors),
                  onTap: () {},
                ),

                const SizedBox(height: 10),

                SettingsTile(
                  icon: Icons.calculate_outlined,
                  title: 'طريقة حساب الصلاة',
                  subtitle: 'الهيئة المصرية العامة للمساحة',
                  trailing: _buildArrow(colors),
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),

          _animatedSection(
            slide: _applicationAnimation,
            child: Column(
              children: [
                _buildSectionHeader(
                  context,
                  icon: Icons.apps_rounded,
                  title: 'التطبيق',
                  subtitle: 'معلومات وإعدادات التطبيق',
                ),

                const SizedBox(height: 10),

                SettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'عن زاد',
                  subtitle: 'معلومات عن التطبيق',
                  trailing: _buildArrow(colors),
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),

                const SizedBox(height: 10),

                const SettingsTile(
                  icon: Icons.verified_outlined,
                  title: 'الإصدار',
                  subtitle: '1.0.0',
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          _animatedSection(
            slide: _footerAnimation,
            child: _buildFooter(context, colors),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context, ColorScheme colors) {
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
            color: colors.primary.withValues(alpha: 0.14),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(18),
            ),

            child: const Icon(
              Icons.settings_rounded,
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
                  'خصّص تجربتك',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  'إعدادات زاد',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'كل شيء بالشكل الذي يناسبك',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons.auto_awesome_rounded,
            size: 19,
            color: Colors.white.withValues(alpha: 0.45),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
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

  Widget _buildThemeTile(BuildContext context, ColorScheme colors) {
    return SettingsTile(
      icon: widget.isDarkMode
          ? Icons.dark_mode_rounded
          : Icons.light_mode_rounded,

      title: 'الوضع الداكن',

      subtitle: widget.isDarkMode ? 'الوضع الداكن مفعل' : 'الوضع الفاتح مفعل',

      trailing: Switch.adaptive(
        value: widget.isDarkMode,
        onChanged: (_) {
          widget.onThemeToggle();
        },
      ),
    );
  }

  Widget _buildArrow(ColorScheme colors) {
    return Icon(
      Icons.chevron_right_rounded,
      color: colors.onSurfaceVariant,
      size: 21,
    );
  }

  Widget _buildFooter(BuildContext context, ColorScheme colors) {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,

          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
          ),

          child: Icon(
            Icons.auto_awesome_rounded,
            size: 27,
            color: colors.primary,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'ZAD',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            color: colors.primary,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          'زادك في طريقك إلى الله',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colors.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 10),

        Container(
          width: 55,
          height: 3,

          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  void _showAboutDialog(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    showDialog(
      context: context,

      builder: (dialogContext) {
        return Dialog(
          backgroundColor: colors.surface,

          elevation: 0,

          insetPadding: const EdgeInsets.symmetric(horizontal: 24),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),

          child: Padding(
            padding: const EdgeInsets.all(24),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                Container(
                  width: 62,
                  height: 62,

                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.10),

                    borderRadius: BorderRadius.circular(18),
                  ),

                  child: Icon(
                    Icons.auto_awesome_rounded,
                    size: 30,
                    color: colors.primary,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'عن زاد',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'زاد هو تطبيق إسلامي يساعدك على متابعة القرآن الكريم والأذكار ومواقيت الصلاة واتجاه القبلة والسبحة في مكان واحد.',
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 13,
                    height: 1.7,
                    color: colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 18),

                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),

                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.06),

                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Icon(
                        Icons.verified_outlined,
                        size: 17,
                        color: colors.primary,
                      ),

                      const SizedBox(width: 7),

                      Text(
                        'الإصدار 1.0.0',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,

                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },

                    child: const Text('إغلاق'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
