import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HadithSourceInfo extends StatelessWidget {
  final String source;
  final String license;
  final String link;

  const HadithSourceInfo({
    super.key,
    required this.source,
    required this.license,
    required this.link,
  });

  Future<void> _openLink(BuildContext context) async {
    final uri = Uri.tryParse(link);

    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host != 'bayan.alwa7i.com') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('رابط الحديث غير صالح')));
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تعذر فتح رابط الحديث')));
    }
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gold),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: innerPaper,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: lightGold),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline_rounded, color: gold, size: 21),
                const SizedBox(width: 9),
                Text(
                  'معلومات الحديث',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            _buildInfoItem(
              icon: Icons.menu_book_rounded,
              title: 'المصدر',
              value: source,
              gold: gold,
              textColor: textColor,
              mutedColor: mutedColor,
            ),

            const SizedBox(height: 14),

            Divider(color: lightGold.withValues(alpha: 0.5)),

            const SizedBox(height: 12),

            _buildInfoItem(
              icon: Icons.verified_outlined,
              title: 'الترخيص',
              value: license,
              gold: gold,
              textColor: textColor,
              mutedColor: mutedColor,
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openLink(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: gold,
                  side: BorderSide(color: gold.withValues(alpha: 0.7)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text(
                  'عرض الحديث على موقع البيان',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    required Color gold,
    required Color textColor,
    required Color mutedColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: gold, size: 19),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(color: mutedColor, fontSize: 12, height: 1.6),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
