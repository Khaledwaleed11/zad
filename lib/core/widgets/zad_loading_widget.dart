
import 'package:flutter/material.dart';

enum ZadLoadingType {
  dua,
  quran,
}

class ZadLoadingWidget extends StatefulWidget {
  final ZadLoadingType type;

  const ZadLoadingWidget({
    super.key,
    required this.type,
  });

  @override
  State<ZadLoadingWidget> createState() => _ZadLoadingWidgetState();
}

class _ZadLoadingWidgetState extends State<ZadLoadingWidget>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _pulseController;

  late final Animation<double> _pulseAnimation;

  static const Color _goldBase = Color(0xFFA88746);
  static const Color _lightGold = Color(0xFFD6BE83);

  bool get _isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get _gold => _isDark ? _lightGold : _goldBase;

  Color get _paper => _isDark
      ? const Color(0xFF252017)
      : const Color(0xFFF7F1DF);

  Color get _innerPaper => _isDark
      ? const Color(0xFF201B13)
      : const Color(0xFFFFFCF4);

  Color get _text => _isDark
      ? const Color(0xFFF2E8D2)
      : const Color(0xFF493A25);

  Color get _muted => _isDark
      ? const Color(0xFFC1B18F)
      : const Color(0xFF786548);

  bool get _isDua => widget.type == ZadLoadingType.dua;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = _isDua
        ? Icons.volunteer_activism_rounded
        : Icons.menu_book_rounded;

    final title = _isDua
        ? 'جاري تجهيز الأدعية'
        : 'جاري تجهيز اختبار الحفظ';

    final subtitle = _isDua
        ? 'لحظات ونبدأ معًا...'
        : 'نراجع الآيات ونجهز أسئلتك...';

    return Center(
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          final pulse = _pulseAnimation.value;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _paper,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _gold,
                width: 1.3,
              ),
              boxShadow: [
                BoxShadow(
                  color: _gold.withValues(
                    alpha: _isDark ? 0.05 : 0.10,
                  ),
                  blurRadius: 20,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 30,
              ),
              decoration: BoxDecoration(
                color: _innerPaper,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _gold.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 112,
                    height: 112,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        RotationTransition(
                          turns: _rotationController,
                          child: Container(
                            width: 104,
                            height: 104,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _gold.withValues(alpha: 0.45),
                                width: 1.2,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: _buildDecorationDot(),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: _buildDecorationDot(),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: _buildDecorationDot(),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: _buildDecorationDot(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Transform.scale(
                          scale: 0.92 + (pulse * 0.12),
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: _gold.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _gold.withValues(alpha: 0.55),
                              ),
                            ),
                            child: Icon(
                              icon,
                              size: 34,
                              color: _gold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _text,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 22),
                  SizedBox(
                    width: 150,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        minHeight: 6,
                        backgroundColor: _gold.withValues(alpha: 0.15),
                        color: _gold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDecorationDot() {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: _gold,
        shape: BoxShape.circle,
      ),
    );
  }
}
