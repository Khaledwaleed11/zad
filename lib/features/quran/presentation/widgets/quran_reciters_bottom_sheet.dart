import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/quran_cubit.dart';
import '../cubit/quran_state.dart';

class QuranRecitersBottomSheet extends StatefulWidget {
  final QuranCubit quranCubit;

  const QuranRecitersBottomSheet({super.key, required this.quranCubit});

  static Future<void> show(BuildContext context, QuranCubit quranCubit) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return QuranRecitersBottomSheet(quranCubit: quranCubit);
      },
    );
  }

  @override
  State<QuranRecitersBottomSheet> createState() =>
      _QuranRecitersBottomSheetState();
}

class _QuranRecitersBottomSheetState extends State<QuranRecitersBottomSheet> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _filterReciters(QuranState state) {
    if (_searchQuery.trim().isEmpty) {
      return state.reciters;
    }

    final query = _searchQuery.trim().toLowerCase();

    return state.reciters.where((reciter) {
      final arabicName = reciter.name.toLowerCase();
      final englishName = reciter.englishName?.toLowerCase() ?? '';

      return arabicName.contains(query) || englishName.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuranCubit, QuranState>(
      bloc: widget.quranCubit,
      builder: (context, state) {
        final colors = Theme.of(context).colorScheme;

        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.12),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.65),
              width: 1.2,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(23),
              ),
              border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 14),
                    child: Row(
                      children: [
                        _buildIconContainer(
                          colors,
                          Icons.record_voice_over_rounded,
                          size: 42,
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Text(
                            'اختر القارئ',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                        Text(
                          '${state.reciters.length} قارئ',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search Field
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: TextField(
                      controller: _searchController,
                      textDirection: TextDirection.rtl,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'ابحث عن اسم القارئ...',
                        hintStyle: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: colors.primary,
                        ),
                        suffixIcon: _searchQuery.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                        filled: true,
                        fillColor: colors.primary.withValues(alpha: 0.06),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 13,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: colors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: colors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: colors.primary,
                            width: 1.3,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Divider(
                    height: 1,
                    color: colors.primary.withValues(alpha: 0.22),
                  ),
                  Expanded(child: _buildRecitersList(context, state)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecitersList(BuildContext context, QuranState state) {
    final colors = Theme.of(context).colorScheme;

    if (state.recitersStatus == QuranRequestStatus.loading ||
        state.recitersStatus == QuranRequestStatus.initial) {
      return Center(
        child: CircularProgressIndicator(
          color: colors.primary,
          strokeWidth: 2.5,
        ),
      );
    }

    if (state.recitersStatus == QuranRequestStatus.failure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_rounded, size: 42, color: colors.error),
              const SizedBox(height: 12),
              Text(
                'تعذر تحميل القرّاء',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: () => widget.quranCubit.loadReciters(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.reciters.isEmpty) {
      return Center(
        child: Text(
          'لا يوجد قرّاء متاحون حاليًا',
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final filteredReciters = _filterReciters(state);

    if (filteredReciters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 42,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد نتائج مطابقة للبحث',
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      itemCount: filteredReciters.length,
      separatorBuilder: (_, _) =>
          Divider(height: 1, color: colors.primary.withValues(alpha: 0.15)),
      itemBuilder: (context, index) {
        final reciter = filteredReciters[index];

        final isSelected =
            state.selectedReciter?.identifier == reciter.identifier;

        return Material(
          color: Colors.transparent,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 3,
            ),
            onTap: () async {
              await widget.quranCubit.selectReciter(reciter);

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Icon(Icons.person_rounded, color: colors.primary),
            ),
            title: Text(
              reciter.name,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: colors.onSurface,
              ),
            ),
            subtitle: reciter.englishName == null
                ? null
                : Text(
                    reciter.englishName!,
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
            trailing: Icon(
              isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: isSelected ? colors.primary : colors.outlineVariant,
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconContainer(
    ColorScheme colors,
    IconData icon, {
    double size = 40,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
      ),
      child: Icon(icon, color: colors.primary, size: 20),
    );
  }
}
