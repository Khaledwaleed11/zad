import 'package:flutter/material.dart';

class QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  State<QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<QuickActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _controller.forward();

    if (!mounted) return;

    await _controller.reverse();

    if (!mounted) return;

    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Expanded(
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Material(
          color: colors.surface,
          borderRadius: BorderRadius.circular(22),

          child: InkWell(
            onTap: _handleTap,
            borderRadius: BorderRadius.circular(22),

            splashColor: colors.primary.withValues(alpha: 0.08),

            highlightColor: colors.primary.withValues(alpha: 0.04),

            child: Container(
              height: 175,
              padding: const EdgeInsets.all(17),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),

                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.30),
                ),

                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withValues(alpha: 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      widget.icon,
                      color: colors.primary,
                      size: 23,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: colors.onSurface,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    widget.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                      color: colors.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 15,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
