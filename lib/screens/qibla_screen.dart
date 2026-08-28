import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

import '../services/qibla_service.dart';
import '../widgets/qibla_compass.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with TickerProviderStateMixin {
  final QiblaService qiblaService = QiblaService();

  StreamSubscription<CompassEvent>? compassSubscription;

  double? qiblaBearing;
  double? compassHeading;

  bool isLoading = true;
  String? errorMessage;

  late AnimationController _pageController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(parent: _pageController, curve: Curves.easeOutCubic),
        );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    initializeQibla();
  }

  Future<void> initializeQibla() async {
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
          errorMessage = null;
        });
      }

      final position = await qiblaService.getCurrentPosition();

      final bearing = qiblaService.calculateQiblaDirection(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      setState(() {
        qiblaBearing = bearing;
        isLoading = false;
      });

      startCompass();

      _pageController.forward(from: 0);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void startCompass() {
    compassSubscription?.cancel();

    compassSubscription = FlutterCompass.events?.listen((event) {
      final heading = event.heading;

      if (heading == null) return;
      if (!mounted) return;

      setState(() {
        compassHeading = heading;
      });
    });
  }

  double get qiblaRotation {
    if (qiblaBearing == null || compassHeading == null) {
      return 0;
    }

    return _normalizeAngle(qiblaBearing! - compassHeading!);
  }

  double _normalizeAngle(double angle) {
    angle %= 360;

    if (angle > 180) {
      angle -= 360;
    }

    if (angle < -180) {
      angle += 360;
    }

    return angle;
  }

  bool get isAligned {
    return qiblaRotation.abs() <= 5;
  }

  String getDirectionName(double angle) {
    final normalized = (angle + 360) % 360;

    if (normalized >= 337.5 || normalized < 22.5) {
      return 'شمال';
    }

    if (normalized < 67.5) {
      return 'شمال شرقي';
    }

    if (normalized < 112.5) {
      return 'شرق';
    }

    if (normalized < 157.5) {
      return 'جنوب شرقي';
    }

    if (normalized < 202.5) {
      return 'جنوب';
    }

    if (normalized < 247.5) {
      return 'جنوب غربي';
    }

    if (normalized < 292.5) {
      return 'غرب';
    }

    return 'شمال غربي';
  }

  @override
  void dispose() {
    compassSubscription?.cancel();
    _pageController.dispose();
    _pulseController.dispose();

    super.dispose();
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
                Icons.explore_rounded,
                color: colors.primary,
                size: 21,
              ),
            ),

            const SizedBox(width: 10),

            const Text(
              'اتجاه القبلة',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
            ),
          ],
        ),

        centerTitle: true,

        actions: [
          IconButton(
            onPressed: initializeQibla,
            tooltip: 'تحديث',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),

      body: _buildBody(context, colors),
    );
  }

  Widget _buildBody(BuildContext context, ColorScheme colors) {
    if (isLoading) {
      return _buildLoading(colors);
    }

    if (errorMessage != null || qiblaBearing == null) {
      return _buildError(colors);
    }

    return FadeTransition(
      opacity: _fadeAnimation,

      child: SlideTransition(
        position: _slideAnimation,

        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),

          child: Column(
            children: [
              _buildHeroHeader(context, colors),

              const SizedBox(height: 18),

              _buildCompassSection(context, colors),

              const SizedBox(height: 18),

              _buildStatusCard(context, colors),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      context,
                      colors,
                      icon: Icons.navigation_rounded,
                      title: 'زاوية القبلة',
                      value: '${qiblaBearing!.toStringAsFixed(1)}°',
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _buildInfoCard(
                      context,
                      colors,
                      icon: Icons.explore_outlined,
                      title: 'الاتجاه',
                      value: getDirectionName(qiblaBearing!),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              _buildLocationCard(context, colors),

              const SizedBox(height: 14),

              _buildTipCard(context, colors),
            ],
          ),
        ),
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
            color: colors.primary.withValues(alpha: 0.15),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.explore_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'وَلِكُلٍّ وِجْهَةٌ هُوَ مُوَلِّيهَا',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'اعرف اتجاه القبلة',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'حرّك هاتفك حتى يشير السهم إلى القبلة',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompassSection(BuildContext context, ColorScheme colors) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(15, 22, 15, 20),

      decoration: BoxDecoration(
        color: colors.surface,

        borderRadius: BorderRadius.circular(28),

        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.28),
        ),

        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),

      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Container(
                width: 7,
                height: 7,

                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 7),

              Text(
                isAligned ? 'أنت الآن على القبلة' : 'ابحث عن اتجاه القبلة',

                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isAligned ? colors.primary : colors.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          AnimatedBuilder(
            animation: _pulseController,

            builder: (context, child) {
              final pulse = isAligned
                  ? 1 + (_pulseController.value * 0.015)
                  : 1.0;

              return Transform.scale(scale: pulse, child: child);
            },

            child: QiblaCompass(rotation: qiblaRotation),
          ),

          const SizedBox(height: 18),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),

            child: Text(
              isAligned
                  ? 'ممتاز، اتجاهك صحيح ✓'
                  : 'أدر الهاتف يمينًا أو يسارًا',

              key: ValueKey(isAligned),

              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isAligned ? colors.primary : colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, ColorScheme colors) {
    final double rotation = qiblaRotation.abs();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),

      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

      decoration: BoxDecoration(
        color: isAligned
            ? colors.primary.withValues(alpha: 0.09)
            : colors.surface,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: isAligned
              ? colors.primary.withValues(alpha: 0.18)
              : colors.outlineVariant.withValues(alpha: 0.28),
        ),
      ),

      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),

            width: 40,
            height: 40,

            decoration: BoxDecoration(
              color: isAligned
                  ? colors.primary
                  : colors.primary.withValues(alpha: 0.10),

              shape: BoxShape.circle,
            ),

            child: Icon(
              isAligned
                  ? Icons.check_rounded
                  : rotation < 30
                  ? Icons.navigation_rounded
                  : Icons.screen_rotation_alt_rounded,

              size: 20,

              color: isAligned ? colors.onPrimary : colors.primary,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),

              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },

              child: Text(
                isAligned
                    ? 'اتجاه القبلة مضبوط'
                    : 'تبقى ${rotation.toStringAsFixed(0)}° للوصول إلى القبلة',

                key: ValueKey(
                  isAligned ? 'aligned' : rotation.toStringAsFixed(0),
                ),

                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),

          Text(
            '${rotation.toStringAsFixed(0)}°',

            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: colors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    ColorScheme colors, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: colors.surface,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.28),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,

            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.10),

              borderRadius: BorderRadius.circular(11),
            ),

            child: Icon(icon, size: 18, color: colors.primary),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, ColorScheme colors) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),

      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.055),

        borderRadius: BorderRadius.circular(17),
      ),

      child: Row(
        children: [
          Icon(Icons.location_on_rounded, size: 19, color: colors.primary),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'الموقع الحالي',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  'تم تحديد موقعك وحساب اتجاه القبلة',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),

          Icon(Icons.check_circle_rounded, size: 19, color: colors.primary),
        ],
      ),
    );
  }

  Widget _buildTipCard(BuildContext context, ColorScheme colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 17,
          color: colors.onSurfaceVariant,
        ),

        const SizedBox(width: 7),

        Expanded(
          child: Text(
            'للحصول على قراءة أدق، أبعد الهاتف عن المعادن والأجهزة الإلكترونية وحافظ عليه بشكل أفقي أثناء تحديد الاتجاه.',

            style: TextStyle(
              fontSize: 10,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoading(ColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Container(
            width: 82,
            height: 82,

            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.09),

              shape: BoxShape.circle,
            ),

            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: colors.primary,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'جاري تحديد اتجاه القبلة...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'اسمح للتطبيق بالوصول إلى موقعك',
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildError(ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: 84,
              height: 84,

              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),

              child: Icon(
                Icons.explore_off_rounded,
                size: 40,
                color: colors.error,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'تعذر تحديد القبلة',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'تأكد من تشغيل الموقع ومنح التطبيق صلاحية الوصول إليه.',

              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: colors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: initializeQibla,

              icon: const Icon(Icons.refresh_rounded),

              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
