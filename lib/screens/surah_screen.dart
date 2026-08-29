import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../models/quran_ayah_model.dart';
import '../models/surah_model.dart';
import '../services/quran_service.dart';

class SurahScreen extends StatefulWidget {
  final SurahModel surah;

  const SurahScreen({super.key, required this.surah});

  @override
  State<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen>
    with SingleTickerProviderStateMixin {
  final QuranService quranService = QuranService();

  List<QuranAyahModel> ayahs = [];

  bool isLoading = true;
  String? errorMessage;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    loadSurah();
  }

  Future<void> loadSurah() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final data = await quranService.getSurah(widget.surah.number);

      final rawAyahs = data['ayahs'];

      if (rawAyahs is! List) {
        throw Exception('Invalid ayahs response');
      }

      final loadedAyahs = rawAyahs
          .whereType<Map>()
          .map(
            (ayah) => QuranAyahModel.fromJson(Map<String, dynamic>.from(ayah)),
          )
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        ayahs = loadedAyahs;
        isLoading = false;
      });

      _animationController.forward(from: 0);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> copyAyah(QuranAyahModel ayah) async {
    await Clipboard.setData(
      ClipboardData(
        text:
            '${ayah.text}\n\n'
            '${widget.surah.name} - الآية ${ayah.numberInSurah}',
      ),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1),

        behavior: SnackBarBehavior.floating,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),

        content: const Row(
          children: [
            Icon(Icons.check_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('تم نسخ الآية', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Future<void> shareAyah(QuranAyahModel ayah) async {
    try {
      final result = await SharePlus.instance.share(
        ShareParams(
          text:
              '${ayah.text}\n\n'
              '${widget.surah.name} - الآية ${ayah.numberInSurah}\n'
              'ZAD',
        ),
      );

      debugPrint('Share result: $result');
    } catch (e) {
      debugPrint('Share error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Share Error: $e')));
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
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

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            Text(
              widget.surah.name,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
            ),

            const SizedBox(height: 1),

            Text(
              widget.surah.englishName,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),

        centerTitle: true,

        actions: [
          IconButton(
            onPressed: loadSurah,

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

    if (errorMessage != null) {
      return _buildError(colors);
    }

    if (ayahs.isEmpty) {
      return _buildEmpty(colors);
    }

    return RefreshIndicator(
      onRefresh: loadSurah,

      color: colors.primary,

      backgroundColor: colors.surface,

      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.fromLTRB(20, 12, 20, 35),

        itemCount: ayahs.length + 1,

        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildSurahHeader(context, colors);
          }

          final ayah = ayahs[index - 1];

          return _AnimatedAyahCard(
            key: ValueKey(ayah.numberInSurah),

            index: index - 1,

            controller: _animationController,

            child: _AyahCard(
              ayah: ayah,

              onCopy: () {
                copyAyah(ayah);
              },

              onShare: () {
                shareAyah(ayah);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSurahHeader(BuildContext context, ColorScheme colors) {
    final bool isMeccan = widget.surah.revelationType.toLowerCase() == 'meccan';

    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(bottom: 18),

      padding: const EdgeInsets.all(22),

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
            color: colors.primary.withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        children: [
          Text(
            widget.surah.name,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            widget.surah.englishName,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SurahInfoChip(
                icon: Icons.auto_stories_rounded,
                text: '${widget.surah.numberOfAyahs} آية',
              ),

              const SizedBox(width: 8),

              _SurahInfoChip(
                icon: Icons.location_on_outlined,
                text: isMeccan ? 'مكية' : 'مدنية',
              ),

              const SizedBox(width: 8),

              _SurahInfoChip(
                icon: Icons.numbers_rounded,
                text: '#${widget.surah.number}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(ColorScheme colors) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),

      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),

      itemCount: 5,

      itemBuilder: (context, index) {
        return Container(
          height: 190,

          margin: const EdgeInsets.only(bottom: 14),

          padding: const EdgeInsets.all(18),

          decoration: BoxDecoration(
            color: colors.surface,

            borderRadius: BorderRadius.circular(20),

            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.25),
            ),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              _buildLoadingBox(width: 34, height: 34),

              const SizedBox(height: 20),

              _buildLoadingBox(width: double.infinity, height: 18),

              const SizedBox(height: 10),

              _buildLoadingBox(width: 260, height: 18),

              const SizedBox(height: 10),

              _buildLoadingBox(width: 190, height: 18),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingBox({required double width, required double height}) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: width,
      height: height,

      decoration: BoxDecoration(
        color: colors.onSurface.withValues(alpha: 0.06),

        borderRadius: BorderRadius.circular(7),
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
              width: 82,
              height: 82,

              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.10),

                shape: BoxShape.circle,
              ),

              child: Icon(
                Icons.cloud_off_rounded,
                size: 38,
                color: colors.error,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'تعذر تحميل السورة',

              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'تحقق من اتصال الإنترنت وحاول مرة أخرى.',

              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: colors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: loadSurah,

              icon: const Icon(Icons.refresh_rounded),

              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(ColorScheme colors) {
    return Center(
      child: Text(
        'لا توجد آيات للعرض',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _AnimatedAyahCard extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final Widget child;

  const _AnimatedAyahCard({
    super.key,
    required this.index,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final double delay = (index * 0.03).clamp(0.0, 0.35);

    return AnimatedBuilder(
      animation: controller,

      builder: (context, child) {
        final double value = ((controller.value - delay) / (1 - delay)).clamp(
          0.0,
          1.0,
        );

        final curved = Curves.easeOutCubic.transform(value);

        return Opacity(
          opacity: curved,

          child: Transform.translate(
            offset: Offset(0, 16 * (1 - curved)),
            child: child,
          ),
        );
      },

      child: child,
    );
  }
}

class _AyahCard extends StatelessWidget {
  final QuranAyahModel ayah;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const _AyahCard({
    required this.ayah,
    required this.onCopy,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),

      decoration: BoxDecoration(
        color: colors.surface,

        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.28),
        ),

        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,

                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.09),

                  shape: BoxShape.circle,
                ),

                child: Center(
                  child: Text(
                    '${ayah.numberInSurah}',

                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              Row(
                children: [
                  _SmallActionButton(icon: Icons.copy_rounded, onTap: onCopy),

                  const SizedBox(width: 4),

                  _SmallActionButton(
                    icon: Icons.share_outlined,
                    onTap: onShare,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          Directionality(
            textDirection: TextDirection.rtl,

            child: Text(
              ayah.text,

              textAlign: TextAlign.right,

              style: TextStyle(
                fontSize: 24,
                height: 2.05,
                fontWeight: FontWeight.w500,
                color: colors.onSurface,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Container(
                width: 5,
                height: 5,

                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 7),

              Text(
                'آية ${ayah.numberInSurah}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SmallActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainerLow,

      borderRadius: BorderRadius.circular(10),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(10),

        child: SizedBox(
          width: 32,
          height: 32,

          child: Icon(icon, size: 16, color: colors.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _SurahInfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SurahInfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),

        borderRadius: BorderRadius.circular(12),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(icon, size: 13, color: Colors.white),

          const SizedBox(width: 5),

          Text(
            text,

            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
