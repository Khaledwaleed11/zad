import 'package:flutter/material.dart';

class SplashContent extends StatelessWidget {
  final Animation<double> logoFade;
  final Animation<double> logoScale;
  final Animation<double> contentFade;
  final Animation<Offset> contentSlide;
  final Animation<double> pulseController;
  final Color paperColor;
  final Color innerPaperColor;
  final Color goldColor;
  final Color lightGoldColor;
  final Color textColor;
  final Color mutedColor;

  const SplashContent({
    super.key,
    required this.logoFade,
    required this.logoScale,
    required this.contentFade,
    required this.contentSlide,
    required this.pulseController,
    required this.paperColor,
    required this.innerPaperColor,
    required this.goldColor,
    required this.lightGoldColor,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: paperColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 540;
            final extraCompact = constraints.maxHeight < 400;
            final logoSize = extraCompact
                ? (constraints.maxHeight * 0.25).clamp(52.0, 72.0).toDouble()
                : (compact ? 96.0 : 118.0);

            return Stack(
              children: [
                Positioned(
                  top: 18,
                  right: 18,
                  child: _SplashDecoration(size: 100, color: goldColor),
                ),
                Positioned(
                  bottom: 18,
                  left: 18,
                  child: _SplashDecoration(size: 100, color: goldColor),
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
                  child: Transform.translate(
                    offset: Offset(
                      0,
                      extraCompact
                          ? -constraints.maxHeight * 0.12
                          : (compact ? -10 : 0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
                                    width: logoSize,
                                    height: logoSize,
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
                                          size: logoSize * 0.49,
                                          color: goldColor,
                                        ),
                                        Positioned(
                                          top: logoSize * 0.17,
                                          right: logoSize * 0.21,
                                          child: Icon(
                                            Icons.auto_awesome_rounded,
                                            size: logoSize * 0.15,
                                            color: lightGoldColor,
                                          ),
                                        ),
                                        Positioned(
                                          bottom: logoSize * 0.14,
                                          child: Container(
                                            width: logoSize * 0.30,
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
                        SizedBox(
                          height: extraCompact ? 14 : (compact ? 20 : 32),
                        ),
                        FadeTransition(
                          opacity: contentFade,
                          child: SlideTransition(
                            position: contentSlide,
                            child: Column(
                              children: [
                                Text(
                                  'زاد',
                                  style: TextStyle(
                                    fontSize: extraCompact
                                        ? 34
                                        : (compact ? 40 : 44),
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 4,
                                    color: textColor,
                                  ),
                                ),
                                SizedBox(height: extraCompact ? 7 : 10),
                                Container(
                                  width: 90,
                                  height: 1.5,
                                  color: goldColor.withValues(alpha: 0.75),
                                ),
                                SizedBox(height: extraCompact ? 9 : 13),
                                Text(
                                  'زادك في طريقك إلى الله',
                                  style: TextStyle(
                                    fontSize: extraCompact ? 13 : 15,
                                    fontWeight: FontWeight.w800,
                                    color: goldColor,
                                  ),
                                ),
                                SizedBox(height: extraCompact ? 6 : 9),
                                Text(
                                  'قرآن  •  أذكار  •  صلاة  •  قبلة',
                                  style: TextStyle(
                                    fontSize: extraCompact ? 9 : 11,
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
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: extraCompact ? 14 : (compact ? 22 : 35),
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
                        SizedBox(height: extraCompact ? 7 : 12),
                        Text(
                          'جاري تجهيز زاد...',
                          style: TextStyle(
                            fontSize: extraCompact ? 9 : 11,
                            fontWeight: FontWeight.w700,
                            color: mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SplashDecoration extends StatelessWidget {
  final double size;
  final Color color;

  const _SplashDecoration({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: size,
        height: size,
        child: Opacity(
          opacity: 0.12,
          child: Icon(Icons.auto_awesome, size: size, color: color),
        ),
      ),
    );
  }
}
