import 'dart:async';

import 'package:flutter/material.dart';

import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const SplashScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

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
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),

        reverseTransitionDuration: const Duration(milliseconds: 350),

        pageBuilder: (context, animation, secondaryAnimation) {
          return MainScreen(
            isDarkMode: widget.isDarkMode,
            onThemeToggle: widget.onThemeToggle,
          );
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
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryColor = colors.primary;

    final backgroundColor = isDark
        ? const Color(0xFF0D0C14)
        : const Color(0xFFF7F7FC);

    final secondBackgroundColor = isDark
        ? const Color(0xFF171620)
        : const Color(0xFFEDEAF5);

    final titleColor = colors.onSurface;

    final subtitleColor = colors.onSurfaceVariant;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [backgroundColor, secondBackgroundColor],
          ),
        ),

        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -90,
                right: -70,
                child: _decorativeCircle(
                  size: 230,
                  color: primaryColor.withValues(alpha: isDark ? 0.07 : 0.08),
                ),
              ),
              Positioned(
                bottom: -100,
                left: -80,
                child: _decorativeCircle(
                  size: 250,
                  color: primaryColor.withValues(alpha: isDark ? 0.06 : 0.07),
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
                            final glow = 0.16 + (pulseController.value * 0.08);

                            return Container(
                              width: 124,
                              height: 124,

                              decoration: BoxDecoration(
                                color: primaryColor,

                                borderRadius: BorderRadius.circular(36),

                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withValues(alpha: glow),
                                    blurRadius: 35,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),

                              child: Stack(
                                alignment: Alignment.center,

                                children: [
                                  Icon(
                                    Icons.menu_book_rounded,
                                    size: 56,
                                    color: colors.onPrimary,
                                  ),

                                  Positioned(
                                    top: 22,
                                    right: 28,

                                    child: Icon(
                                      Icons.auto_awesome_rounded,
                                      size: 18,
                                      color: colors.onPrimary.withValues(
                                        alpha: 0.72,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                    FadeTransition(
                      opacity: contentFade,
                      child: SlideTransition(
                        position: contentSlide,

                        child: Column(
                          children: [
                            Text(
                              'ZAD',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4,
                                color: titleColor,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'زادك في طريقك إلى الله',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: subtitleColor,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              'قرآن • أذكار • صلاة • قبلة',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.4,
                                color: subtitleColor,
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
                bottom: 28,

                child: FadeTransition(
                  opacity: contentFade,

                  child: Column(
                    children: [
                      SizedBox(
                        width: 28,
                        height: 28,

                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: primaryColor,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'جاري تجهيز زاد...',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _decorativeCircle({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,

      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
