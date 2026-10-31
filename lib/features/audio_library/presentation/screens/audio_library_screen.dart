
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/dependency_injection/injection_container.dart';
import '../../../adhan_voices/presentation/cubit/adhan_voices_cubit.dart';
import '../../../adhan_voices/presentation/screens/adhan_voices_screen.dart';
import '../../domain/entities/audio_recording_entity.dart';
import '../../domain/repositories/audio_preview_repository.dart';
import '../cubit/audio_library_cubit.dart';
import '../cubit/audio_library_state.dart';
import '../cubit/audio_preview_cubit.dart';
import '../cubit/audio_preview_state.dart';
import '../widgets/add_audio_recording_dialog.dart';

class AudioLibraryScreen extends StatelessWidget {
  const AudioLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<AudioLibraryCubit>()..loadRecordings(),
        ),
        BlocProvider(
          create: (_) => sl<AudioPreviewCubit>(),
        ),
        BlocProvider(
          create: (_) => sl<AdhanVoicesCubit>()..loadVoices(),
        ),
      ],
      child: const _AudioLibraryView(),
    );
  }
}

class _AudioLibraryView extends StatelessWidget {
  const _AudioLibraryView();

  void _showAddDialog(BuildContext context) {
    final audioLibraryCubit = context.read<AudioLibraryCubit>();

    showDialog(
      context: context,
      builder: (_) {
        return BlocProvider.value(
          value: audioLibraryCubit,
          child: const AddAudioRecordingDialog(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المكتبة الصوتية'),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'إضافة تسجيل',
              onPressed: () => _showAddDialog(context),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
          bottom: TabBar(
            indicatorColor: colors.primary,
            labelColor: colors.primary,
            unselectedLabelColor: colors.onSurfaceVariant,
            tabs: const [
              Tab(
                icon: Icon(Icons.menu_book_rounded),
                text: 'تسجيلات القرآن',
              ),
              Tab(
                icon: Icon(Icons.mosque_rounded),
                text: 'تسجيلات الأذان',
              ),
              Tab(
                icon: Icon(Icons.record_voice_over_rounded),
                text: 'أصوات المؤذنين',
              ),
            ],
          ),
        ),
        body: BlocListener<AudioLibraryCubit, AudioLibraryState>(
          listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
              current.errorMessage != null,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
              ),
            );
          },
          child: const TabBarView(
            children: [
              _RecordingList(type: AudioRecordingType.quran),
              _RecordingList(type: AudioRecordingType.adhan),
              AdhanVoicesScreen(),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordingList extends StatelessWidget {
  final AudioRecordingType type;

  const _RecordingList({
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioLibraryCubit, AudioLibraryState>(
      builder: (context, state) {
        if (state.status == AudioLibraryStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.status == AudioLibraryStatus.failure &&
            state.recordings.isEmpty) {
          return const Center(
            child: Text('حدث خطأ أثناء تحميل التسجيلات'),
          );
        }

        final recordings = state.recordings
            .where((recording) => recording.type == type)
            .toList();

        if (recordings.isEmpty) {
          return _EmptyLibrary(type: type);
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: recordings.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _RecordingCard(
              recording: recordings[index],
            );
          },
        );
      },
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  final AudioRecordingType type;

  const _EmptyLibrary({
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isQuran = type == AudioRecordingType.quran;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isQuran
                  ? Icons.library_music_outlined
                  : Icons.volume_up_outlined,
              size: 64,
              color: colors.primary.withValues(alpha: 0.55),
            ),
            const SizedBox(height: 16),
            Text(
              isQuran
                  ? 'لا توجد تسجيلات قرآنية'
                  : 'لا توجد تسجيلات أذان',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'يمكنك إضافة تسجيلاتك الشخصية إلى مكتبتك الصوتية',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordingCard extends StatelessWidget {
  final AudioRecordingEntity recording;

  const _RecordingCard({
    required this.recording,
  });

  Future<void> _deleteRecording(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('حذف التسجيل'),
          content: Text('هل تريد حذف "${recording.name}"؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) return;

    final previewState = context.read<AudioPreviewCubit>().state;

    if (previewState.currentFilePath == recording.filePath) {
      await context.read<AudioPreviewCubit>().stop();
    }

    if (!context.mounted) return;

    await context
        .read<AudioLibraryCubit>()
        .deleteRecording(recording.id);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: colors.primary.withValues(alpha: 0.12),
              child: Icon(
                recording.type == AudioRecordingType.quran
                    ? Icons.menu_book_rounded
                    : Icons.mosque_rounded,
                color: colors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recording.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recording.type == AudioRecordingType.quran
                        ? 'السورة رقم ${recording.surahNumber ?? '-'}'
                        : 'تسجيل أذان شخصي',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            BlocBuilder<AudioPreviewCubit, AudioPreviewState>(
              builder: (context, previewState) {
                final isCurrent =
                    previewState.currentFilePath == recording.filePath;

                final isPlaying = isCurrent &&
                    previewState.status == AudioPreviewStatus.playing;

                final isLoading = isCurrent &&
                    previewState.status == AudioPreviewStatus.loading;

                return IconButton(
                  tooltip: isPlaying ? 'إيقاف مؤقت' : 'معاينة',
                  onPressed: isLoading
                      ? null
                      : () {
                    final cubit = context.read<AudioPreviewCubit>();

                    if (!isCurrent) {
                      cubit.play(recording.filePath);
                    } else if (isPlaying) {
                      cubit.pause();
                    } else {
                      cubit.resume();
                    }
                  },
                  icon: isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : Icon(
                    isPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_fill_rounded,
                    color: colors.primary,
                    size: 30,
                  ),
                );
              },
            ),
            IconButton(
              tooltip: 'حذف',
              onPressed: () => _deleteRecording(context),
              icon: Icon(
                Icons.delete_outline_rounded,
                color: colors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
