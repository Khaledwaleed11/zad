import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../core/dependency_injection/injection_container.dart';
import '../../../../../../../core/theme/cubit/theme_cubit.dart';
import '../../../../../../../core/theme/cubit/theme_state.dart';
import '../../../audio_library/presentation/screens/audio_library_screen.dart';
import '../../../notifications/data/datasources/notification_service.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';
import '../widgets/setting_tile.dart';
import '../widgets/settings_about_dialog.dart';
import '../widgets/settings_app_bar.dart';
import '../widgets/settings_footer.dart';
import '../widgets/settings_group.dart';
import '../widgets/settings_hero_header.dart';
import '../widgets/settings_salawat_countdown.dart';
import '../widgets/settings_section_header.dart';
import '../widgets/settings_version_badge.dart';

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

  Timer? _countdownTimer;
  bool _isRefreshingSalawatTime = false;

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

    _refreshSalawatCountdown();

    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _refreshSalawatCountdown(),
    );
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
    _countdownTimer?.cancel();
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

  Future<void> _refreshSalawatCountdown() async {
    if (_isRefreshingSalawatTime) return;

    _isRefreshingSalawatTime = true;

    try {
      await NotificationService.refreshNextSalawatNotificationTime();

      if (mounted) {
        setState(() {});
      }
    } finally {
      _isRefreshingSalawatTime = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        final isLoading = settingsState.status == SettingsStatus.loading;

        return Scaffold(
          backgroundColor: _paper,
          body: SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: SettingsAppBar(
                    paper: _paper,
                    gold: _gold,
                    textColor: _textColor,
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 35),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _animatedSection(
                          slide: _headerAnimation,
                          child: _buildHeroHeader(),
                        ),

                        const SizedBox(height: 34),

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

                        const SizedBox(height: 34),

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
                                    subtitle:
                                    settingsState.prayerNotificationsEnabled
                                        ? 'إشعارات أوقات الصلاة مفعلة'
                                        : 'إشعارات أوقات الصلاة متوقفة',
                                    trailing: Switch.adaptive(
                                      value:
                                      settingsState.prayerNotificationsEnabled,
                                      activeTrackColor: _gold,
                                      onChanged: isLoading
                                          ? null
                                          : (value) {
                                        context
                                            .read<SettingsCubit>()
                                            .togglePrayerNotifications(
                                          value,
                                        );
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
                                        context
                                            .read<SettingsCubit>()
                                            .toggleAdhan(value);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 34),

                        _animatedSection(
                          slide: _applicationAnimation,
                          child: Column(
                            children: [
                              _buildSectionHeader(
                                icon: Icons.apps_rounded,
                                title: 'التطبيق',
                                subtitle: 'معلومات وإعدادات التطبيق',
                              ),

                              const SizedBox(height: 16),

                              _buildSettingsGroup(
                                children: [
                                  _buildTile(
                                    icon: Icons.notifications_none_rounded,
                                    title: 'إشعارات الأذكار',
                                    subtitle:
                                    settingsState.azkarNotificationsEnabled
                                        ? 'تذكيرات الأذكار اليومية مفعلة'
                                        : 'تذكيرات الأذكار اليومية متوقفة',
                                    trailing: Switch.adaptive(
                                      value:
                                      settingsState.azkarNotificationsEnabled,
                                      activeTrackColor: _gold,
                                      onChanged: isLoading
                                          ? null
                                          : (value) {
                                        context
                                            .read<SettingsCubit>()
                                            .toggleAzkarNotifications(
                                          value,
                                        );
                                      },
                                    ),
                                  ),

                                  _buildGroupDivider(),

                                  _buildTile(
                                    icon: Icons.favorite_rounded,
                                    title: 'الصلاة على النبي ﷺ',
                                    subtitle:
                                    settingsState.salawatNotificationsEnabled
                                        ? 'تذكيرات الصلاة على النبي مفعلة'
                                        : 'تذكيرات الصلاة على النبي متوقفة',
                                    trailing: Switch.adaptive(
                                      value:
                                      settingsState.salawatNotificationsEnabled,
                                      activeTrackColor: _gold,
                                      onChanged: isLoading
                                          ? null
                                          : (value) async {
                                        await context
                                            .read<SettingsCubit>()
                                            .toggleSalawatNotifications(
                                          value,
                                        );

                                        if (value) {
                                          await _refreshSalawatCountdown();
                                        } else if (mounted) {
                                          setState(() {});
                                        }
                                      },
                                    ),
                                  ),

                                  if (settingsState.salawatNotificationsEnabled)
                                    Padding(
                                      padding:
                                      const EdgeInsetsDirectional.only(
                                        start: 12,
                                        end: 12,
                                        top: 4,
                                        bottom: 10,
                                      ),
                                      child: _buildSalawatCountdown(),
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

                        _animatedSection(
                          slide: _footerAnimation,
                          child: _buildFooter(),
                        ),
                      ],
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

  Widget _buildSalawatCountdown() {
    return SettingsSalawatCountdown(
      nextTime: NotificationService.getNextSalawatNotificationTime(),
      gold: _gold,
      mutedColor: _mutedColor,
    );
  }

  Widget _buildHeroHeader() {
    return SettingsHeroHeader(
      gold: _gold,
      mutedColor: _mutedColor,
      textColor: _textColor,
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return SettingsSectionHeader(
      icon: icon,
      title: title,
      subtitle: subtitle,
      gold: _gold,
      textColor: _textColor,
      mutedColor: _mutedColor,
    );
  }

  Widget _buildSettingsGroup({required List<Widget> children}) {
    return SettingsGroup(
      gold: _gold,
      innerPaper: _innerPaper,
      lightGold: _lightGold,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    return SettingsVersionBadge(gold: _gold);
  }

  Widget _buildFooter() {
    return SettingsFooter(gold: _gold, mutedColor: _mutedColor);
  }

  void _showAboutDialog(BuildContext context) {
    SettingsAboutDialog.show(
      context: context,
      gold: _gold,
      innerPaper: _innerPaper,
      lightGold: _lightGold,
      textColor: _textColor,
      mutedColor: _mutedColor,
    );
  }
}
