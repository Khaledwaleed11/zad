
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

  bool get _isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get _innerPaper => _isDark
      ? const Color(0xFF201B13)
      : const Color(0xFFFFFCF4);

  Color get _gold => _isDark
      ? const Color(0xFFD6BE83)
      : const Color(0xFFA88746);

  Color get _lightGold => _isDark
      ? const Color(0xFF806B43)
      : const Color(0xFFD6BE83);

  Color get _textColor => _isDark
      ? const Color(0xFFF2E8D2)
      : const Color(0xFF493A25);

  Color get _mutedColor => _isDark
      ? const Color(0xFFC1B18F)
      : const Color(0xFF786548);

  @override
  void initState() {
    super.initState();

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (widget.onTap == null) return;

    await _pressController.forward(from: 0);

    if (!mounted) return;

    widget.onTap!();

    if (mounted) {
      _pressController.reverse();
    }
  }

  Widget _cornerDecoration() {
    return Icon(
      Icons.auto_awesome_rounded,
      size: 10,
      color: _gold.withValues(alpha: 0.65),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: _gold.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _gold.withValues(alpha: 0.65),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: _innerPaper,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: _lightGold.withValues(alpha: 0.45),
              width: 0.7,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              onTap: _handleTap,
              borderRadius: BorderRadius.circular(15),
              splashColor: _gold.withValues(alpha: 0.10),
              highlightColor: _gold.withValues(alpha: 0.05),
              child: Stack(
                children: [
                  Positioned(
                    top: 5,
                    right: 5,
                    child: _cornerDecoration(),
                  ),
                  Positioned(
                    bottom: 5,
                    left: 5,
                    child: _cornerDecoration(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOutCubic,
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _gold.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: _gold.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Icon(
                            widget.icon,
                            color: _gold,
                            size: 21,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: _textColor,
                                ),
                              ),
                              if (widget.subtitle != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  widget.subtitle!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10,
                                    height: 1.4,
                                    fontWeight: FontWeight.w600,
                                    color: _mutedColor,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (widget.trailing != null) ...[
                          const SizedBox(width: 8),
                          widget.trailing!,
                        ],
                      ],
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
