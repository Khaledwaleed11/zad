import 'package:flutter/material.dart';

class SettingsTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  State<SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<SettingsTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;

  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0,
      upperBound: 1,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _pressController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (widget.onTap == null) {
      return;
    }

    await _pressController.forward(from: 0);

    if (!mounted) return;

    widget.onTap!();

    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _scaleAnimation,

      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },

      child: Material(
        color: colors.surface,

        borderRadius: BorderRadius.circular(20),

        child: InkWell(
          onTap: _handleTap,

          borderRadius: BorderRadius.circular(20),

          splashColor: colors.primary.withValues(alpha: 0.08),

          highlightColor: colors.primary.withValues(alpha: 0.04),

          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),

              border: Border.all(
                color: colors.outlineVariant.withValues(
                  alpha: isDark ? 0.35 : 0.55,
                ),
              ),

              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: isDark ? 0.0 : 0.035),

                  blurRadius: 12,

                  offset: const Offset(0, 5),
                ),
              ],
            ),

            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),

                  curve: Curves.easeOutCubic,

                  width: 44,
                  height: 44,

                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.10),

                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: Icon(widget.icon, color: colors.primary, size: 21),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        widget.title,

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),

                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 4),

                        Text(
                          widget.subtitle!,

                          maxLines: 2,

                          overflow: TextOverflow.ellipsis,

                          style: TextStyle(
                            fontSize: 11,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                if (widget.trailing != null) ...[
                  const SizedBox(width: 10),

                  widget.trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
