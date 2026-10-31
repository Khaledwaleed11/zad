import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/dependency_injection/injection_container.dart';
import '../../../quran/domain/entities/surah_entity.dart';
import '../../../quran/domain/usecases/get_all_surahs.dart';
import '../../domain/entities/audio_recording_entity.dart';
import '../cubit/audio_library_cubit.dart';

class AddAudioRecordingDialog extends StatefulWidget {
  const AddAudioRecordingDialog({super.key});

  @override
  State<AddAudioRecordingDialog> createState() =>
      _AddAudioRecordingDialogState();
}

class _AddAudioRecordingDialogState extends State<AddAudioRecordingDialog> {
  final _nameController = TextEditingController();

  Future<List<SurahEntity>>? _surahsFuture;

  AudioRecordingType _type = AudioRecordingType.quran;
  int? _selectedSurah;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _surahsFuture = sl<GetAllSurahs>()();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onTypeChanged(AudioRecordingType? value) {
    if (value == null) return;

    setState(() {
      _type = value;
      _selectedSurah = null;

      if (value == AudioRecordingType.quran) {
        _surahsFuture ??= sl<GetAllSurahs>()();
      }
    });
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      _showMessage('اكتب اسم التسجيل أولاً');
      return;
    }

    if (_type == AudioRecordingType.quran && _selectedSurah == null) {
      _showMessage('اختار السورة أولاً');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final added = await context.read<AudioLibraryCubit>().addRecording(
        name: name,
        type: _type,
        surahNumber: _type == AudioRecordingType.quran ? _selectedSurah : null,
      );

      if (!mounted) return;

      if (added) {
        Navigator.pop(context);
      } else {
        _showMessage('لم تتم إضافة التسجيل، حاول مرة أخرى');
      }
    } catch (e, stackTrace) {
      debugPrint('Add Recording Error: $e');
      debugPrint('Add Recording StackTrace: $stackTrace');

      if (mounted) {
        _showMessage('حدث خطأ أثناء إضافة التسجيل');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('إضافة تسجيل جديد', textAlign: TextAlign.center),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                enabled: !_isSubmitting,
                decoration: const InputDecoration(
                  labelText: 'اسم التسجيل',
                  hintText: 'مثلاً: أذان الفجر',
                  prefixIcon: Icon(Icons.edit_outlined),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<AudioRecordingType>(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'نوع التسجيل',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: AudioRecordingType.quran,
                    child: Text('تسجيل قرآني'),
                  ),
                  DropdownMenuItem(
                    value: AudioRecordingType.adhan,
                    child: Text('تسجيل أذان'),
                  ),
                ],
                onChanged: _isSubmitting ? null : _onTypeChanged,
              ),

              if (_type == AudioRecordingType.quran) ...[
                const SizedBox(height: 16),

                FutureBuilder<List<SurahEntity>>(
                  future: _surahsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LinearProgressIndicator();
                    }

                    if (snapshot.hasError) {
                      debugPrint('Surahs Loading Error: ${snapshot.error}');
                      debugPrint('Surahs StackTrace: ${snapshot.stackTrace}');

                      return Column(
                        children: [
                          const Text(
                            'تعذر تحميل قائمة السور',
                            style: TextStyle(color: Colors.red),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _surahsFuture = sl<GetAllSurahs>()();
                                _selectedSurah = null;
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('إعادة المحاولة'),
                          ),
                        ],
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('لا توجد سور متاحة');
                    }

                    final surahs = snapshot.data!;

                    return DropdownButtonFormField<int>(
                      initialValue: _selectedSurah,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'اختر السورة',
                        prefixIcon: Icon(Icons.menu_book_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: surahs.map((surah) {
                        return DropdownMenuItem(
                          value: surah.number,
                          child: Text('${surah.number}. ${surah.name}'),
                        );
                      }).toList(),
                      onChanged: _isSubmitting
                          ? null
                          : (value) {
                              setState(() {
                                _selectedSurah = value;
                              });
                            },
                    );
                  },
                ),
              ],

              const SizedBox(height: 12),

              Text(
                _type == AudioRecordingType.quran
                    ? 'اختر السورة التي ينتمي إليها التسجيل، ثم اختر ملف الصوت من جهازك.'
                    : 'اختر ملف تسجيل الأذان من جهازك.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('اختيار الملف'),
        ),
      ],
    );
  }
}
