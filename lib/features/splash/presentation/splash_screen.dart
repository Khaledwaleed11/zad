
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zad/core/constants/app_constants.dart';

import '../../../../../../app/navigation/main_screen.dart';
import '../../notifications/data/datasources/notification_service.dart';

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

  bool get isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get paperColor => isDark
      ? const Color(0xFF252017)
      : const Color(0xFFF7F1DF);

  Color get innerPaperColor => isDark
      ? const Color(0xFF201B13)
      : const Color(0xFFFFFCF4);

  Color get goldColor => isDark
      ? const Color(0xFFD6BE83)
      : const Color(0xFFA88746);

  Color get lightGoldColor => isDark
      ? const Color(0xFF806B43)
      : const Color(0xFFD6BE83);

  Color get textColor => isDark
      ? const Color(0xFFF2E8D2)
      : const Color(0xFF493A25);

  Color get mutedColor => isDark
      ? const Color(0xFFC1B18F)
      : const Color(0xFF786548);

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

    logoFade = CurvedAnimation(
      parent: logoController,
      curve: Curves.easeOut,
    );

    contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    contentFade = CurvedAnimation(
      parent: contentController,
      curve: Curves.easeOut,
    );

    contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
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
    return Scaffold(
      backgroundColor: paperColor,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 18,
              right: 18,
              child: _decoration(size: 100),
            ),
            Positioned(
              bottom: 18,
              left: 18,
              child: _decoration(size: 100),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                color: goldColor.withValues(alpha: 0.55),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: logoFade,
                    child: ScaleTransition(
                      scale: logoScale,
                      child: AnimatedBuilder(
                        animation: pulseController,
                        builder: (context, child) {
                          final glow =
                              0.10 + (pulseController.value * 0.10);

                          return Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(35),
                              border: Border.all(
                                color: goldColor,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: goldColor.withValues(
                                    alpha: glow,
                                  ),
                                  blurRadius: 30,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: Container(
                              width: 118,
                              height: 118,
                              decoration: BoxDecoration(
                                color: innerPaperColor,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: lightGoldColor,
                                  width: 1,
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Icons.menu_book_rounded,
                                    size: 58,
                                    color: goldColor,
                                  ),
                                  Positioned(
                                    top: 20,
                                    right: 25,
                                    child: Icon(
                                      Icons.auto_awesome_rounded,
                                      size: 18,
                                      color: lightGoldColor,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 17,
                                    child: Container(
                                      width: 35,
                                      height: 2,
                                      decoration: BoxDecoration(
                                        color: goldColor,
                                        borderRadius:
                                        BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FadeTransition(
                    opacity: contentFade,
                    child: SlideTransition(
                      position: contentSlide,
                      child: Column(
                        children: [
                          Text(
                            AppConstants.appName,
                            style: TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: 90,
                            height: 1.5,
                            color: goldColor.withValues(alpha: 0.75),
                          ),
                          const SizedBox(height: 13),
                          Text(
                            'زادك في طريقك إلى الله',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: goldColor,
                            ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            'قرآن  •  أذكار  •  صلاة  •  قبلة',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: mutedColor,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 35,
              child: FadeTransition(
                opacity: contentFade,
                child: Column(
                  children: [
                    SizedBox(
                      width: 25,
                      height: 25,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: goldColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'جاري تجهيز زاد...',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: mutedColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _decoration({required double size}) {
    return IgnorePointer(
      child: SizedBox(
        width: size,
        height: size,
        child: Opacity(
          opacity: 0.12,
          child: Icon(
            Icons.auto_awesome,
            size: size,
            color: goldColor,
          ),
        ),
      ),
    );
  }
}
