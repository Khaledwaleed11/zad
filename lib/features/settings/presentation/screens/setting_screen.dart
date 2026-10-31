import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zad/core/constants/app_constants.dart';

import '../../../../../../../core/dependency_injection/injection_container.dart';
import '../../../../../../../core/theme/cubit/theme_cubit.dart';
import '../../../../../../../core/theme/cubit/theme_state.dart';
import '../../../audio_library/presentation/screens/audio_library_screen.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';
import '../widgets/setting_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SettingsCubit>()..loadSettings(),
      child: const _SettingsScreenView(),
    );
  }
}

class _SettingsScreenView extends StatefulWidget {
  const _SettingsScreenView();

  @override
  State<_SettingsScreenView> createState() => _SettingsScreenViewState();
}

class _SettingsScreenViewState extends State<_SettingsScreenView>
    with SingleTickerProviderStateMixin {
  late AnimationController _pageController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _headerAnimation;
  late Animation<Offset> _appearanceAnimation;
  late Animation<Offset> _prayerAnimation;
  late Animation<Offset> _applicationAnimation;
  late Animation<Offset> _footerAnimation;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _paper =>
      _isDark ? const Color(0xFF252017) : const Color(0xFFF7F1DF);

  Color get _innerPaper =>
      _isDark ? const Color(0xFF201B13) : const Color(0xFFFFFCF4);

  Color get _gold =>
      _isDark ? const Color(0xFFD6BE83) : const Color(0xFFA88746);

  Color get _lightGold =>
      _isDark ? const Color(0xFF806B43) : const Color(0xFFD6BE83);

  Color get _textColor =>
      _isDark ? const Color(0xFFF2E8D2) : const Color(0xFF493A25);

  Color get _mutedColor =>
      _isDark ? const Color(0xFFC1B18F) : const Color(0xFF786548);

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

    _headerAnimation = _createSlideAnimation(
      const Offset(0, -0.08),
      0.00,
      0.25,
    );

    _appearanceAnimation = _createSlideAnimation(
      const Offset(0, 0.08),
      0.15,
      0.45,
    );

    _prayerAnimation = _createSlideAnimation(const Offset(0, 0.08), 0.30, 0.60);

    _applicationAnimation = _createSlideAnimation(
      const Offset(0, 0.08),
      0.45,
      0.75,
    );

    _footerAnimation = _createSlideAnimation(const Offset(0, 0.08), 0.65, 1.00);

    _pageController.forward();
  }

  Animation<Offset> _createSlideAnimation(
    Offset begin,
    double start,
    double end,
  ) {
    return Tween<Offset>(begin: begin, end: Offset.zero).animate(
      CurvedAnimation(
        parent: _pageController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
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

  void _openAudioLibrary() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AudioLibraryScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        final isLoading = settingsState.status == SettingsStatus.loading;

        return Scaffold(
          backgroundColor: _paper,
          appBar: _buildAppBar(),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 35),
            children: [
              _animatedSection(
                slide: _headerAnimation,
                child: _buildHeroHeader(),
              ),
              const SizedBox(height: 26),

              _animatedSection(
                slide: _appearanceAnimation,
                child: Column(
                  children: [
                    _buildSectionHeader(
                      icon: Icons.palette_outlined,
                      title: 'المظهر',
                      subtitle: 'خصّص شكل التطبيق',
                    ),
                    const SizedBox(height: 12),
                    _buildThemeTile(),
                  ],
                ),
              ),
              const SizedBox(height: 26),

              _animatedSection(
                slide: _prayerAnimation,
                child: Column(
                  children: [
                    _buildSectionHeader(
                      icon: Icons.mosque_outlined,
                      title: 'الصلاة',
                      subtitle: 'إعدادات مواقيت الصلاة',
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsGroup(
                      children: [
                        _buildTile(
                          icon: Icons.location_on_outlined,
                          title: 'الموقع الحالي',
                          subtitle: 'القاهرة، مصر',
                          trailing: _buildArrow(),
                          onTap: () {},
                        ),
                        _buildGroupDivider(),
                        _buildTile(
                          icon: Icons.calculate_outlined,
                          title: 'طريقة حساب الصلاة',
                          subtitle: 'الهيئة المصرية العامة للمساحة',
                          trailing: _buildArrow(),
                          onTap: () {},
                        ),
                        _buildGroupDivider(),
                        _buildTile(
                          icon: Icons.notifications_active_outlined,
                          title: 'إشعارات الصلاة',
                          subtitle: settingsState.prayerNotificationsEnabled
                              ? 'إشعارات أوقات الصلاة مفعلة'
                              : 'إشعارات أوقات الصلاة متوقفة',
                          trailing: Switch.adaptive(
                            value: settingsState.prayerNotificationsEnabled,
                            activeTrackColor: _gold,
                            onChanged: isLoading
                                ? null
                                : (value) {
                                    context
                                        .read<SettingsCubit>()
                                        .togglePrayerNotifications(value);
                                  },
                          ),
                        ),
                        _buildGroupDivider(),
                        _buildTile(
                          icon: Icons.volume_up_rounded,
                          title: 'الأذان الصوتي',
                          subtitle: settingsState.adhanEnabled
                              ? 'تشغيل الأذان كاملًا في أوقات الصلاة'
                              : 'تشغيل الأذان الصوتي متوقف',
                          trailing: Switch.adaptive(
                            value: settingsState.adhanEnabled,
                            activeTrackColor: _gold,
                            onChanged: isLoading
                                ? null
                                : (value) {
                                    context.read<SettingsCubit>().toggleAdhan(
                                      value,
                                    );
                                  },
                          ),
                        ),
                      ],
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
                      icon: Icons.apps_rounded,
                      title: 'التطبيق',
                      subtitle: 'معلومات وإعدادات التطبيق',
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsGroup(
                      children: [
                        _buildTile(
                          icon: Icons.notifications_none_rounded,
                          title: 'إشعارات الأذكار',
                          subtitle: settingsState.azkarNotificationsEnabled
                              ? 'تذكيرات الأذكار اليومية مفعلة'
                              : 'تذكيرات الأذكار اليومية متوقفة',
                          trailing: Switch.adaptive(
                            value: settingsState.azkarNotificationsEnabled,
                            activeTrackColor: _gold,
                            onChanged: isLoading
                                ? null
                                : (value) {
                                    context
                                        .read<SettingsCubit>()
                                        .toggleAzkarNotifications(value);
                                  },
                          ),
                        ),
                        _buildGroupDivider(),
                        _buildTile(
                          icon: Icons.library_music_outlined,
                          title: 'المكتبة الصوتية',
                          subtitle: 'إدارة تسجيلات القرآن والأذان',
                          trailing: _buildArrow(),
                          onTap: _openAudioLibrary,
                        ),
                        _buildGroupDivider(),
                        _buildTile(
                          icon: Icons.info_outline_rounded,
                          title: 'عن زاد',
                          subtitle: 'معلومات عن التطبيق',
                          trailing: _buildArrow(),
                          onTap: () => _showAboutDialog(context),
                        ),
                        _buildGroupDivider(),
                        _buildTile(
                          icon: Icons.verified_outlined,
                          title: 'الإصدار',
                          subtitle: '1.0.0',
                          trailing: _buildVersionBadge(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _animatedSection(slide: _footerAnimation, child: _buildFooter()),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _paper,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIconBox(Icons.settings_rounded, size: 38),
          const SizedBox(width: 10),
          Text(
            'الإعدادات',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: _textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconBox(IconData icon, {double size = 42}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _gold.withValues(alpha: 0.4)),
      ),
      child: Icon(icon, size: size * 0.52, color: _gold),
    );
  }

  Widget _paperCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    double radius = 20,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _gold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(radius + 3),
        border: Border.all(color: _gold.withValues(alpha: 0.75)),
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: _innerPaper,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: _lightGold.withValues(alpha: 0.55),
            width: 0.8,
          ),
        ),
        child: Stack(
          children: [
            Positioned(top: 0, right: 0, child: _cornerDecoration()),
            Positioned(
              top: 0,
              left: 0,
              child: Transform.rotate(
                angle: 1.5708,
                child: _cornerDecoration(),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Transform.rotate(
                angle: -1.5708,
                child: _cornerDecoration(),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Transform.rotate(
                angle: 3.1416,
                child: _cornerDecoration(),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }

  Widget _cornerDecoration() {
    return Icon(
      Icons.auto_awesome_rounded,
      size: 12,
      color: _gold.withValues(alpha: 0.65),
    );
  }

  Widget _buildHeroHeader() {
    return _paperCard(
      radius: 23,
      padding: const EdgeInsets.all(19),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _gold.withValues(alpha: 0.12),
              border: Border.all(
                color: _gold.withValues(alpha: 0.65),
                width: 1.3,
              ),
            ),
            child: Icon(Icons.settings_rounded, color: _gold, size: 29),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'خصّص تجربتك',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _mutedColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'إعدادات زاد',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'كل شيء بالشكل الذي يناسبك',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _gold,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.auto_awesome_rounded,
            size: 21,
            color: _gold.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        _buildIconBox(icon, size: 40),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _mutedColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsGroup({required List<Widget> children}) {
    return _paperCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      radius: 19,
      child: Column(children: children),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final styledTheme = Theme.of(context).copyWith(
      colorScheme: Theme.of(context).colorScheme.copyWith(
        primary: _gold,
        surface: _innerPaper,
        onSurface: _textColor,
        onSurfaceVariant: _mutedColor,
        outlineVariant: _lightGold,
      ),
    );

    return Theme(
      data: styledTheme,
      child: SettingsTile(
        icon: icon,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  Widget _buildGroupDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Divider(
        height: 1,
        thickness: 0.7,
        color: _lightGold.withValues(alpha: 0.35),
      ),
    );
  }

  Widget _buildThemeTile() {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final isDarkMode = state.themeMode == ThemeMode.dark;

        return _buildSettingsGroup(
          children: [
            _buildTile(
              icon: isDarkMode
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded,
              title: 'الوضع الداكن',
              subtitle: isDarkMode ? 'الوضع الداكن مفعل' : 'الوضع الفاتح مفعل',
              trailing: Switch.adaptive(
                key: ValueKey('theme-switch-$isDarkMode'),
                value: isDarkMode,
                activeTrackColor: _gold,
                onChanged: (_) {
                  context.read<ThemeCubit>().toggleTheme();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildArrow() {
    return Icon(Icons.chevron_right_rounded, color: _gold, size: 23);
  }

  Widget _buildVersionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: _gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _gold.withValues(alpha: 0.4)),
      ),
      child: Text(
        '1.0.0',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: _gold,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: _gold.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: _gold.withValues(alpha: 0.5)),
          ),
          child: Icon(Icons.auto_awesome_rounded, size: 27, color: _gold),
        ),
        const SizedBox(height: 12),
        Text(
          AppConstants.appName,
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            color: _gold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'زادك في طريقك إلى الله',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _mutedColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 55,
          height: 3,
          decoration: BoxDecoration(
            color: _gold.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: _paperCard(
            radius: 23,
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: _gold.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: _gold.withValues(alpha: 0.5)),
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    size: 30,
                    color: _gold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'عن زاد',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'زاد هو تطبيق إسلامي يساعدك على متابعة القرآن الكريم والأذكار ومواقيت الصلاة واتجاه القبلة والسبحة في مكان واحد.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.7,
                    color: _mutedColor,
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
                    color: _gold.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: _gold.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_outlined, size: 17, color: _gold),
                      const SizedBox(width: 7),
                      Text(
                        'الإصدار 1.0.0',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: _gold,
                      foregroundColor: _innerPaper,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text(
                      'إغلاق',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
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
