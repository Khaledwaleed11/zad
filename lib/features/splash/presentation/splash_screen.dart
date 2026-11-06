import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../../../app/navigation/main_screen.dart';
import '../../notifications/data/datasources/notification_service.dart';
import 'widgets/splash_content.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController logoController;
  late AnimationController contentController;
  late AnimationController pulseController;

  late Animation<double> logoScale;
  late Animation<double> logoFade;
  late Animation<double> contentFade;
  late Animation<Offset> contentSlide;

  bool _hasOpenedMainScreen = false;

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get paperColor =>
      isDark ? const Color(0xFF252017) : const Color(0xFFF7F1DF);

  Color get innerPaperColor =>
      isDark ? const Color(0xFF201B13) : const Color(0xFFFFFCF4);

  Color get goldColor =>
      isDark ? const Color(0xFFD6BE83) : const Color(0xFFA88746);

  Color get lightGoldColor =>
      isDark ? const Color(0xFF806B43) : const Color(0xFFD6BE83);

  Color get textColor =>
      isDark ? const Color(0xFFF2E8D2) : const Color(0xFF493A25);

  Color get mutedColor =>
      isDark ? const Color(0xFFC1B18F) : const Color(0xFF786548);

  @override
  void initState() {
    super.initState();

    logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    logoScale = CurvedAnimation(
      parent: logoController,
      curve: Curves.elasticOut,
    );

    logoFade = CurvedAnimation(parent: logoController, curve: Curves.easeOut);

    contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    contentFade = CurvedAnimation(
      parent: contentController,
      curve: Curves.easeOut,
    );

    contentSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: contentController,
            curve: Curves.easeOutCubic,
          ),
        );

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    logoController.forward();

    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        contentController.forward();
      }
    });

    Future.delayed(const Duration(milliseconds: 2600), openMainScreen);
  }

  void openMainScreen() {
    if (!mounted || _hasOpenedMainScreen) return;

    _hasOpenedMainScreen = true;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) {
          return const MainScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: curvedAnimation,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.97,
                end: 1.0,
              ).animate(curvedAnimation),
              child: child,
            ),
          );
        },
      ),
    );

    Future.delayed(const Duration(milliseconds: 750), () {
      NotificationService.handlePendingNotification();
    });
  }

  @override
  void dispose() {
    logoController.dispose();
    contentController.dispose();
    pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SplashContent(
      logoFade: logoFade,
      logoScale: logoScale,
      contentFade: contentFade,
      contentSlide: contentSlide,
      pulseController: pulseController,
      paperColor: paperColor,
      innerPaperColor: innerPaperColor,
      goldColor: goldColor,
      lightGoldColor: lightGoldColor,
      textColor: textColor,
      mutedColor: mutedColor,
    );
  }
}
