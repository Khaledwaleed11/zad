import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';

import '../../../../../../../core/dependency_injection/injection_container.dart';
import '../cubit/qibla_cubit.dart';
import '../cubit/qibla_state.dart';
import '../widgets/qibla_compass.dart';

class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<QiblaCubit>()..loadQibla(),
      child: const _QiblaScreenView(),
    );
  }
}

class _QiblaScreenView extends StatefulWidget {
  const _QiblaScreenView();

  @override
  State<_QiblaScreenView> createState() => _QiblaScreenViewState();
}

class _QiblaScreenViewState extends State<_QiblaScreenView>
    with TickerProviderStateMixin {
  StreamSubscription<CompassEvent>? compassSubscription;

  double? qiblaBearing;
  double? compassHeading;

  String? compassError;

  late AnimationController _pageController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get paper => isDark ? const Color(0xFF252017) : const Color(0xFFF7F1DF);

  Color get innerPaper =>
      isDark ? const Color(0xFF201B13) : const Color(0xFFFFFCF4);

  Color get gold => isDark ? const Color(0xFFD6BE83) : const Color(0xFFA88746);

  Color get lightGold =>
      isDark ? const Color(0xFF806B43) : const Color(0xFFD6BE83);

  Color get textColor =>
      isDark ? const Color(0xFFF2E8D2) : const Color(0xFF493A25);

  Color get mutedColor =>
      isDark ? const Color(0xFFC1B18F) : const Color(0xFF786548);

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
  }

  Future<void> initializeQibla() async {
    await compassSubscription?.cancel();
    compassSubscription = null;

    if (!mounted) return;

    setState(() {
      compassHeading = null;
      compassError = null;
    });

    context.read<QiblaCubit>().loadQibla();
  }

  void startCompass() {
    compassSubscription?.cancel();

    final compassEvents = FlutterCompass.events;

    if (compassEvents == null) {
      if (!mounted) return;

      setState(() {
        compassError = 'حساس البوصلة غير متاح على هذا الجهاز.';
      });

      return;
    }

    compassSubscription = compassEvents.listen(
      (event) {
        final heading = event.heading;

        if (heading == null || !mounted) return;

        if (compassHeading != null && (heading - compassHeading!).abs() < 0.5) {
          return;
        }

        setState(() {
          compassHeading = heading;
          compassError = null;
        });
      },
      onError: (error) {
        if (!mounted) return;

        setState(() {
          compassError = 'تعذر الوصول إلى حساس البوصلة.';
        });
      },
      cancelOnError: false,
    );
  }

  double get qiblaRotation {
    if (qiblaBearing == null || compassHeading == null) {
      return 0;
    }

    return _normalizeAngle(qiblaBearing! - compassHeading!);
  }

  double _normalizeAngle(double angle) {
    angle %= 360;

    if (angle > 180) angle -= 360;
    if (angle < -180) angle += 360;

    return angle;
  }

  bool get isAligned {
    if (qiblaBearing == null || compassHeading == null) {
      return false;
    }

    return qiblaRotation.abs() <= 5;
  }

  String getDirectionName(double angle) {
    final normalized = (angle + 360) % 360;

    if (normalized >= 337.5 || normalized < 22.5) {
      return 'شمال';
    }
    if (normalized < 67.5) return 'شمال شرقي';
    if (normalized < 112.5) return 'شرق';
    if (normalized < 157.5) return 'جنوب شرقي';
    if (normalized < 202.5) return 'جنوب';
    if (normalized < 247.5) return 'جنوب غربي';
    if (normalized < 292.5) return 'غرب';

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

    return BlocConsumer<QiblaCubit, QiblaState>(
      listener: (context, state) {
        if (state.status == QiblaStatus.success) {
          qiblaBearing = state.qiblaBearing;

          startCompass();

          _pageController.forward(from: 0);
        }

        if (state.status == QiblaStatus.failure) {
          compassSubscription?.cancel();
          compassSubscription = null;
        }
      },
      builder: (context, state) {
        final isLoading =
            state.status == QiblaStatus.initial ||
            state.status == QiblaStatus.loading;

        final hasError =
            state.status == QiblaStatus.failure || compassError != null;

        final error = compassError ?? state.errorMessage;

        if (state.status == QiblaStatus.success) {
          qiblaBearing = state.qiblaBearing;
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: gold.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: lightGold),
                  ),
                  child: Icon(Icons.explore_rounded, color: gold, size: 21),
                ),
                const SizedBox(width: 10),
                Text(
                  'اتجاه القبلة',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: initializeQibla,
                tooltip: 'تحديث',
                icon: Icon(Icons.refresh_rounded, color: gold),
              ),
            ],
          ),
          body: isLoading
              ? _buildLoading(colors)
              : hasError || state.qiblaBearing == null
              ? _buildError(colors, error)
              : _buildBody(context, colors),
        );
      },
    );
  }

  // Main Content

  Widget _buildBody(BuildContext context, ColorScheme colors) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
          child: Column(
            children: [
              _buildHeroHeader(),
              const SizedBox(height: 18),
              _buildCompassSection(),
              const SizedBox(height: 16),
              _buildStatusCard(),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.navigation_rounded,
                      title: 'زاوية القبلة',
                      value: '${qiblaBearing!.toStringAsFixed(1)}°',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.explore_outlined,
                      title: 'الاتجاه',
                      value: getDirectionName(qiblaBearing!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildLocationCard(),
              const SizedBox(height: 14),
              _buildTipCard(),
            ],
          ),
        ),
      ),
    );
  }

  // Hero Header

  Widget _buildHeroHeader() {
    return _paperCard(
      padding: const EdgeInsets.all(17),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.10),
              shape: BoxShape.circle,
              border: Border.all(color: lightGold),
            ),
            child: Icon(Icons.explore_rounded, color: gold, size: 31),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'وَلِكُلٍّ وِجْهَةٌ هُوَ مُوَلِّيهَا',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: mutedColor,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'اعرف اتجاه القبلة',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'حرّك هاتفك حتى يشير السهم إلى القبلة',
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                    color: mutedColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Compass

  Widget _buildCompassSection() {
    final hasCompass = compassHeading != null;

    return _paperCard(
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 18),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: hasCompass ? gold : mutedColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                !hasCompass
                    ? 'جاري معايرة البوصلة...'
                    : isAligned
                    ? 'أنت الآن على القبلة'
                    : 'ابحث عن اتجاه القبلة',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: hasCompass && isAligned ? gold : mutedColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

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

          const SizedBox(height: 20),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              !hasCompass
                  ? 'حرّك الهاتف وانتظر قراءة البوصلة'
                  : isAligned
                  ? 'ممتاز، اتجاهك صحيح ✓'
                  : 'أدر الهاتف يمينًا أو يسارًا',
              key: ValueKey('${hasCompass}_$isAligned'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: hasCompass && isAligned ? gold : mutedColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Alignment Status

  Widget _buildStatusCard() {
    final rotation = qiblaRotation.abs();
    final hasCompass = compassHeading != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isAligned ? gold : lightGold,
          width: isAligned ? 1.5 : 1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        decoration: BoxDecoration(
          color: innerPaper,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: lightGold.withValues(alpha: 0.55)),
        ),
        child: Row(
          children: [
            Container(
              width: 41,
              height: 41,
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: lightGold),
              ),
              child: Icon(
                isAligned
                    ? Icons.check_rounded
                    : rotation < 30
                    ? Icons.navigation_rounded
                    : Icons.screen_rotation_alt_rounded,
                size: 21,
                color: gold,
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
                  !hasCompass
                      ? 'في انتظار قراءة البوصلة'
                      : isAligned
                      ? 'اتجاه القبلة مضبوط'
                      : 'تبقى ${rotation.toStringAsFixed(0)}° للوصول إلى القبلة',
                  key: ValueKey(
                    !hasCompass
                        ? 'waiting'
                        : isAligned
                        ? 'aligned'
                        : rotation.toStringAsFixed(0),
                  ),
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.5,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              hasCompass ? '${rotation.toStringAsFixed(0)}°' : '--°',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: gold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Information Cards

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return _paperCard(
      padding: const EdgeInsets.all(11),
      child: Row(
        children: [
          Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: lightGold.withValues(alpha: 0.8)),
            ),
            child: Icon(icon, size: 18, color: gold),
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
                    fontWeight: FontWeight.w700,
                    color: mutedColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Location Card

  Widget _buildLocationCard() {
    return _paperCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Icon(Icons.location_on_rounded, size: 21, color: gold),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الموقع الحالي',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: mutedColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'تم تحديد موقعك وحساب اتجاه القبلة',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle_rounded, size: 20, color: gold),
        ],
      ),
    );
  }

  // Tip Card

  Widget _buildTipCard() {
    return _paperCard(
      padding: const EdgeInsets.all(13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 19, color: gold),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'للحصول على قراءة أدق، أبعد الهاتف عن المعادن والأجهزة الإلكترونية وحافظ عليه بشكل أفقي أثناء تحديد الاتجاه.',
              style: TextStyle(
                fontSize: 11,
                height: 1.7,
                fontWeight: FontWeight.w600,
                color: mutedColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Loading State

  Widget _buildLoading(ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: _paperCard(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                  border: Border.all(color: lightGold),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(19),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: gold,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'جاري تحديد اتجاه القبلة...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'اسمح للتطبيق بالوصول إلى موقعك',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: mutedColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Error State

  Widget _buildError(ColorScheme colors, String? error) {
    final compassError = error != null && error.contains('البوصلة');

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _paperCard(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                  border: Border.all(color: lightGold),
                ),
                child: Icon(
                  compassError
                      ? Icons.explore_off_rounded
                      : Icons.location_off_rounded,
                  size: 38,
                  color: gold,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                compassError ? 'البوصلة غير متاحة' : 'تعذر تحديد القبلة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                compassError
                    ? 'جهازك لا يوفر حساس بوصلة صالحًا للاستخدام.'
                    : 'تأكد من تشغيل الموقع ومنح التطبيق صلاحية الوصول إليه.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.7,
                  fontWeight: FontWeight.w600,
                  color: mutedColor,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: initializeQibla,
                  icon: Icon(Icons.refresh_rounded, color: gold),
                  label: Text(
                    'إعادة المحاولة',
                    style: TextStyle(color: gold, fontWeight: FontWeight.w800),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: gold),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable Parchment Card

  Widget _paperCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(5),
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold, width: 1.3),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: isDark ? 0.05 : 0.09),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: paper,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: lightGold, width: 0.8),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: innerPaper,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: lightGold.withValues(alpha: 0.25)),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 5,
                right: 5,
                child: _cornerDecoration('top_right'),
              ),
              Positioned(
                top: 5,
                left: 5,
                child: _cornerDecoration('top_left'),
              ),
              Positioned(
                bottom: 5,
                right: 5,
                child: _cornerDecoration('bottom_right'),
              ),
              Positioned(
                bottom: 5,
                left: 5,
                child: _cornerDecoration('bottom_left'),
              ),
              Padding(
                padding: padding,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cornerDecoration(String key) {
    return Icon(
      Icons.auto_awesome,
      key: ValueKey(key),
      size: 15,
      color: gold.withValues(alpha: 0.50),
    );
  }
}
