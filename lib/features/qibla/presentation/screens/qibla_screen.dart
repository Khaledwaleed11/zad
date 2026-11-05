import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';

import '../../../../../../../core/dependency_injection/injection_container.dart';
import '../cubit/qibla_cubit.dart';
import '../cubit/qibla_state.dart';
import '../widgets/qibla_compass_section.dart';
import '../widgets/qibla_hero_header.dart';
import '../widgets/qibla_info_card.dart';
import '../widgets/qibla_location_card.dart';
import '../widgets/qibla_state_views.dart';
import '../widgets/qibla_status_card.dart';
import '../widgets/qibla_tip_card.dart';

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

  // Scrollable AppBar

  Widget _buildAppBar() {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          body: SafeArea(
            bottom: false,
            child: isLoading
                ? _buildStateBody(
                    QiblaLoadingView(
                      isDark: isDark,
                      paper: paper,
                      innerPaper: innerPaper,
                      gold: gold,
                      lightGold: lightGold,
                      textColor: textColor,
                      mutedColor: mutedColor,
                    ),
                  )
                : hasError || state.qiblaBearing == null
                ? _buildStateBody(
                    QiblaErrorView(
                      error: error,
                      onRetry: initializeQibla,
                      isDark: isDark,
                      paper: paper,
                      innerPaper: innerPaper,
                      gold: gold,
                      lightGold: lightGold,
                      textColor: textColor,
                      mutedColor: mutedColor,
                    ),
                  )
                : _buildBody(),
          ),
        );
      },
    );
  }

  // Loading and Error Views

  Widget _buildStateBody(Widget stateView) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildAppBar(),
              SizedBox(
                height: constraints.maxHeight > 0
                    ? constraints.maxHeight - kToolbarHeight
                    : MediaQuery.of(context).size.height * 0.7,
                child: stateView,
              ),
            ],
          ),
        );
      },
    );
  }

  // Main Content

  Widget _buildBody() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
          child: Column(
            children: [
              _buildAppBar(),

              QiblaHeroHeader(
                isDark: isDark,
                paper: paper,
                innerPaper: innerPaper,
                gold: gold,
                lightGold: lightGold,
                textColor: textColor,
                mutedColor: mutedColor,
              ),
              const SizedBox(height: 18),

              QiblaCompassSection(
                hasCompass: compassHeading != null,
                isAligned: isAligned,
                pulseController: _pulseController,
                rotation: qiblaRotation,
                isDark: isDark,
                paper: paper,
                innerPaper: innerPaper,
                gold: gold,
                lightGold: lightGold,
                mutedColor: mutedColor,
              ),
              const SizedBox(height: 16),

              QiblaStatusCard(
                rotation: qiblaRotation.abs(),
                hasCompass: compassHeading != null,
                isAligned: isAligned,
                paper: paper,
                innerPaper: innerPaper,
                gold: gold,
                lightGold: lightGold,
                textColor: textColor,
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: QiblaInfoCard(
                      icon: Icons.navigation_rounded,
                      title: 'زاوية القبلة',
                      value: '${qiblaBearing!.toStringAsFixed(1)}°',
                      isDark: isDark,
                      paper: paper,
                      innerPaper: innerPaper,
                      gold: gold,
                      lightGold: lightGold,
                      textColor: textColor,
                      mutedColor: mutedColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: QiblaInfoCard(
                      icon: Icons.explore_outlined,
                      title: 'الاتجاه',
                      value: getDirectionName(qiblaBearing!),
                      isDark: isDark,
                      paper: paper,
                      innerPaper: innerPaper,
                      gold: gold,
                      lightGold: lightGold,
                      textColor: textColor,
                      mutedColor: mutedColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              QiblaLocationCard(
                isDark: isDark,
                paper: paper,
                innerPaper: innerPaper,
                gold: gold,
                lightGold: lightGold,
                textColor: textColor,
                mutedColor: mutedColor,
              ),
              const SizedBox(height: 14),

              QiblaTipCard(
                isDark: isDark,
                paper: paper,
                innerPaper: innerPaper,
                gold: gold,
                lightGold: lightGold,
                mutedColor: mutedColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
