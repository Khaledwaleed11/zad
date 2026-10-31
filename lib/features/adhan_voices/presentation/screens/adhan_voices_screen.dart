
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../audio_library/domain/repositories/audio_preview_repository.dart';
import '../../../audio_library/presentation/cubit/audio_preview_cubit.dart';
import '../../../audio_library/presentation/cubit/audio_preview_state.dart';
import '../../domain/entities/adhan_voice_entity.dart';
import '../cubit/adhan_voices_cubit.dart';
import '../cubit/adhan_voices_state.dart';

class AdhanVoicesScreen extends StatelessWidget {
  const AdhanVoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AudioPreviewCubit, AudioPreviewState>(
          listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
              current.errorMessage != null,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          },
        ),
        BlocListener<AdhanVoicesCubit, AdhanVoicesState>(
          listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage,
          listener: (context, state) {
            final message = state.errorMessage;

            if (message == null) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          },
        ),
      ],
      child: BlocBuilder<AdhanVoicesCubit, AdhanVoicesState>(
        builder: (context, state) {
          if (state.status == AdhanVoicesStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.status == AdhanVoicesStatus.failure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text('تعذر تحميل أصوات المؤذنين'),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () {
                        context.read<AdhanVoicesCubit>().loadVoices();
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.voices.isEmpty) {
            return const Center(
              child: Text('لا توجد تسجيلات أذان متاحة'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.voices.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final voice = state.voices[index];

              return _AdhanVoiceCard(
                voice: voice,
                isSelected: state.selectedVoiceId == voice.id,
              );
            },
          );
        },
      ),
    );
  }
}

class _AdhanVoiceCard extends StatelessWidget {
  final AdhanVoiceEntity voice;
  final bool isSelected;

  const _AdhanVoiceCard({
    required this.voice,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: isSelected
          ? colors.primaryContainer.withValues(alpha: 0.45)
          : colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected
              ? colors.primary
              : colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.read<AdhanVoicesCubit>().selectVoice(voice.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: colors.primary.withValues(alpha: 0.12),
                child: Icon(
                  Icons.mosque_rounded,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      voice.muezzin.isNotEmpty
                          ? voice.muezzin
                          : voice.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (voice.location.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        voice.location,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (isSelected) ...[
                      const SizedBox(height: 4),
                      Text(
                        'الصوت المختار',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              BlocBuilder<AudioPreviewCubit, AudioPreviewState>(
                builder: (context, previewState) {
                  final isCurrent =
                      previewState.currentFilePath == voice.audioUrl;

                  final isPlaying = isCurrent &&
                      previewState.status == AudioPreviewStatus.playing;

                  final isLoading = isCurrent &&
                      previewState.status == AudioPreviewStatus.loading;

                  return IconButton(
                    tooltip: isPlaying ? 'إيقاف مؤقت' : 'معاينة الأذان',
                    onPressed: isLoading
                        ? null
                        : () {
                      final cubit =
                      context.read<AudioPreviewCubit>();

                      if (!isCurrent) {
                        cubit.play(voice.audioUrl);
                      } else if (isPlaying) {
                        cubit.pause();
                      } else {
                        cubit.resume();
                      }
                    },
                    icon: isLoading
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : Icon(
                      isPlaying
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_fill_rounded,
                      color: colors.primary,
                      size: 32,
                    ),
                  );
                },
              ),
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: isSelected
                    ? colors.primary
                    : colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
