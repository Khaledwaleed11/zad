import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../audio_library/presentation/cubit/audio_preview_cubit.dart';
import '../../../audio_library/presentation/cubit/audio_preview_state.dart';
import '../cubit/adhan_voices_cubit.dart';
import '../cubit/adhan_voices_state.dart';
import '../widgets/adhan_voice_card.dart';

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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
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
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == AdhanVoicesStatus.failure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 48),
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
            return const Center(child: Text('لا توجد تسجيلات أذان متاحة'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.voices.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final voice = state.voices[index];

              return AdhanVoiceCard(
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
