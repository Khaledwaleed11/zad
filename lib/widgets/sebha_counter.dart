import 'dart:math' as math;

import 'package:flutter/material.dart';

class SebhaCounter extends StatefulWidget {
  final int count;
  final int target;
  final VoidCallback onTap;
  final VoidCallback onReset;

  const SebhaCounter({
    super.key,
    required this.count,
    required this.target,
    required this.onTap,
    required this.onReset,
  });

  @override
  State<SebhaCounter> createState() => _SebhaCounterState();
}

class _SebhaCounterState extends State<SebhaCounter>
    with TickerProviderStateMixin {
  late AnimationController _tapController;
  late AnimationController _ringController;
  late AnimationController _completionController;
  late AnimationController _resetController;

  late Animation<double> _tapScale;
  late Animation<double> _tapGlow;
  late Animation<double> _completionScale;
  late Animation<double> _completionGlow;

  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();

    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _tapScale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeOutCubic),
    );

    _tapGlow = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _tapController, curve: Curves.easeOut));

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _completionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _completionScale = Tween<double>(begin: 1.0, end: 1.045).animate(
      CurvedAnimation(parent: _completionController, curve: Curves.easeOut),
    );

    _completionGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _completionController, curve: Curves.easeInOut),
    );

    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAnimations(animate: false);
    });
  }

  @override
  void didUpdateWidget(covariant SebhaCounter oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.count != widget.count || oldWidget.target != widget.target) {
      _updateAnimations(animate: true);
    }
  }

  void _updateAnimations({required bool animate}) {
    final completed = widget.target > 0 && widget.count >= widget.target;

    final wasCompleted = _isCompleted;

    _isCompleted = completed;

    if (animate) {
      final progress = widget.target > 0
          ? (widget.count / widget.target).clamp(0.0, 1.0)
          : 0.0;

      _ringController.animateTo(
        progress,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );

      if (completed && !wasCompleted) {
        _playCompletion();
      }
    } else {
      final progress = widget.target > 0
          ? (widget.count / widget.target).clamp(0.0, 1.0)
          : 0.0;

      _ringController.value = progress;

      if (completed) {
        _completionController.value = 1.0;
      }
    }
  }

  Future<void> _handleTap() async {
    if (_isCompleted) {
      return;
    }

    // زوّد العداد فورًا
    widget.onTap();

    _tapController.forward(from: 0).then((_) {
      if (mounted) {
        _tapController.reverse();
      }
    });
  }

  void _playCompletion() {
    _completionController.forward(from: 0);
  }

  Future<void> _handleReset() async {
    await _resetController.forward(from: 0);

    if (!mounted) return;

    widget.onReset();

    await _resetController.reverse();
  }

  @override
  void dispose() {
    _tapController.dispose();
    _ringController.dispose();
    _completionController.dispose();
    _resetController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final double progress = widget.target > 0
        ? (widget.count / widget.target).clamp(0.0, 1.0)
        : 0.0;

    final bool completed = widget.target > 0 && widget.count >= widget.target;

    return Column(
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([
            _tapController,
            _completionController,
            _resetController,
          ]),

          builder: (context, child) {
            final double pressScale = _tapScale.value;

            final double completionScale = completed
                ? _completionScale.value
                : 1.0;

            final double resetRotation = _resetController.value * math.pi;

            final double scale = pressScale * completionScale;

            final double glow =
                (_tapGlow.value * 0.14) + (_completionGlow.value * 0.20);

            return Transform.rotate(
              angle: resetRotation,
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 286,
                  height: 286,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: glow),
                        blurRadius: 34 + (_completionGlow.value * 10),
                        spreadRadius: _completionGlow.value * 3,
                      ),
                    ],
                  ),

                  child: GestureDetector(
                    onTap: completed ? null : _handleTap,

                    behavior: HitTestBehavior.opaque,

                    child: Stack(
                      alignment: Alignment.center,

                      children: [
                        SizedBox(
                          width: 270,
                          height: 270,

                          child: CustomPaint(
                            painter: _ProgressRingPainter(
                              progress: _ringController.value,

                              primaryColor: colors.primary,

                              trackColor: colors.primary.withValues(
                                alpha: 0.09,
                              ),

                              strokeWidth: 11,
                            ),
                          ),
                        ),

                        Container(
                          width: 238,
                          height: 238,

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,

                            color: colors.surface,

                            border: Border.all(
                              color: colors.outlineVariant.withValues(
                                alpha: 0.30,
                              ),
                              width: 1,
                            ),

                            boxShadow: [
                              BoxShadow(
                                color: colors.shadow.withValues(alpha: 0.08),

                                blurRadius: 25,

                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),

                                transitionBuilder: (child, animation) {
                                  return ScaleTransition(
                                    scale: animation,
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  );
                                },

                                child: Container(
                                  key: ValueKey(completed),

                                  width: 48,
                                  height: 48,

                                  decoration: BoxDecoration(
                                    color: colors.primary.withValues(
                                      alpha: completed ? 0.16 : 0.09,
                                    ),

                                    shape: BoxShape.circle,
                                  ),

                                  child: Icon(
                                    completed
                                        ? Icons.check_rounded
                                        : Icons.touch_app_rounded,

                                    size: 24,

                                    color: colors.primary,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 11),

                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),

                                reverseDuration: const Duration(
                                  milliseconds: 120,
                                ),

                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,

                                    child: ScaleTransition(
                                      scale:
                                          Tween<double>(
                                            begin: 0.82,
                                            end: 1.0,
                                          ).animate(
                                            CurvedAnimation(
                                              parent: animation,
                                              curve: Curves.easeOutBack,
                                            ),
                                          ),

                                      child: child,
                                    ),
                                  );
                                },

                                child: Text(
                                  '${widget.count}',

                                  key: ValueKey(widget.count),

                                  style: TextStyle(
                                    fontSize: 56,
                                    height: 0.95,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1.5,
                                    color: colors.onSurface,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),

                                child: Text(
                                  completed
                                      ? 'أتممت الذكر ✓'
                                      : widget.target > 0
                                      ? 'من ${widget.target}'
                                      : 'ذكر مفتوح',

                                  key: ValueKey(
                                    '${completed}_${widget.target}',
                                  ),

                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: completed
                                        ? colors.primary
                                        : colors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        IgnorePointer(
                          child: AnimatedBuilder(
                            animation: _tapController,

                            builder: (context, child) {
                              return Container(
                                width: 210 + (_tapController.value * 18),

                                height: 210 + (_tapController.value * 18),

                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,

                                  border: Border.all(
                                    color: colors.primary.withValues(
                                      alpha: (1 - _tapController.value) * 0.14,
                                    ),

                                    width: 2,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),

          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.15),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },

          child: Text(
            completed
                ? 'ما شاء الله، تم بحمد الله'
                : 'اضغط على الدائرة للتسبيح',

            key: ValueKey(completed),

            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: completed ? colors.primary : colors.onSurfaceVariant,
            ),
          ),
        ),

        const SizedBox(height: 18),

        AnimatedBuilder(
          animation: _resetController,

          builder: (context, child) {
            return Opacity(
              opacity: 1 - (_resetController.value * 0.25),

              child: Transform.scale(
                scale: 1 - (_resetController.value * 0.05),

                child: child,
              ),
            );
          },

          child: OutlinedButton.icon(
            onPressed: _handleReset,

            icon: const Icon(Icons.refresh_rounded, size: 18),

            label: const Text('إعادة العداد'),

            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color trackColor;
  final double strokeWidth;

  const _ProgressRingPainter({
    required this.progress,
    required this.primaryColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final radius = (size.width - strokeWidth) / 2;

    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;

    final sweepAngle = math.pi * 2 * progress;

    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
