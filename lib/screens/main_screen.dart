import 'package:flutter/material.dart';

import 'azkar_screen.dart';
import 'home_screen.dart';
import 'quran_screen.dart';
import 'setting_screen.dart';

class MainScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const MainScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;

  late AnimationController _navController;

  @override
  void initState() {
    super.initState();

    _navController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _navController.dispose();
    super.dispose();
  }

  void changePage(int index) {
    if (currentIndex == index) return;

    setState(() {
      currentIndex = index;
    });

    _navController.forward(from: 0);
  }

  List<Widget> get pages {
    return [
      HomeScreen(
        isDarkMode: widget.isDarkMode,
        onThemeToggle: widget.onThemeToggle,
      ),

      const QuranScreen(),

      const AzkarScreen(),

      SettingsScreen(
        isDarkMode: widget.isDarkMode,
        onThemeToggle: widget.onThemeToggle,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeIn,

        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },

        child: KeyedSubtree(
          key: ValueKey(currentIndex),
          child: pages[currentIndex],
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,

        onDestinationSelected: changePage,

        backgroundColor: colors.surface,

        surfaceTintColor: Colors.transparent,

        elevation: 0,

        height: 72,

        indicatorColor: colors.primary.withValues(alpha: 0.12),

        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'الرئيسية',
          ),

          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'القرآن',
          ),

          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome_rounded),
            label: 'الأذكار',
          ),

          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}
