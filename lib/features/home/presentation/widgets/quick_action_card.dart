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
    if (widget.onTap == null) return;

    await _controller.forward();

    if (!mounted) return;

    await _controller.reverse();

    if (!mounted) return;

    widget.onTap!.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final paper = isDark ? const Color(0xFF252017) : const Color(0xFFF7F1DF);

    final innerPaper = isDark
        ? const Color(0xFF201B13)
        : const Color(0xFFFFFCF4);

    final gold = isDark ? const Color(0xFFD6BE83) : const Color(0xFFA88746);

    final lightGold = isDark
        ? const Color(0xFF806B43)
        : const Color(0xFFD6BE83);

    final textColor = isDark
        ? const Color(0xFFF2E8D2)
        : const Color(0xFF493A25);

    final mutedColor = isDark
        ? const Color(0xFFC1B18F)
        : const Color(0xFF786548);

    return Expanded(
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Container(
          height: 175,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: paper,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: gold, width: 1.3),
            boxShadow: [
              BoxShadow(
                color: gold.withValues(alpha: isDark ? 0.06 : 0.10),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: innerPaper,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: lightGold.withValues(alpha: 0.8),
                width: 0.8,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(15),
              child: InkWell(
                onTap: widget.onTap == null ? null : _handleTap,
                borderRadius: BorderRadius.circular(15),
                splashColor: gold.withValues(alpha: 0.10),
                highlightColor: gold.withValues(alpha: 0.05),
                child: Stack(
                  children: [
                    Positioned(
                      top: 5,
                      right: 6,
                      child: _cornerDecoration(gold),
                    ),
                    Positioned(top: 5, left: 6, child: _cornerDecoration(gold)),
                    Positioned(
                      bottom: 5,
                      right: 6,
                      child: _cornerDecoration(gold),
                    ),
                    Positioned(
                      bottom: 5,
                      left: 6,
                      child: _cornerDecoration(gold),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 43,
                            height: 43,
                            decoration: BoxDecoration(
                              color: gold.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(
                                color: lightGold.withValues(alpha: 0.8),
                              ),
                            ),
                            child: Icon(widget.icon, color: gold, size: 22),
                          ),
                          const SizedBox(height: 11),
                          Text(
                            widget.title,
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            child: Text(
                              widget.subtitle,
                              textAlign: TextAlign.start,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                                color: mutedColor,
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional.bottomStart,
                            child: Container(
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                color: gold.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: lightGold.withValues(alpha: 0.7),
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_back_rounded,
                                size: 14,
                                color: gold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cornerDecoration(Color gold) {
    return Icon(
      Icons.auto_awesome,
      size: 11,
      color: gold.withValues(alpha: 0.55),
    );
  }
}
