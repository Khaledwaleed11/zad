import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/dependency_injection/injection_container.dart';
import '../../../../core/utils/responsive.dart';
import '../../../adhan_voices/presentation/cubit/adhan_voices_cubit.dart';
import '../../../adhan_voices/presentation/screens/adhan_voices_screen.dart';
import '../../domain/entities/audio_recording_entity.dart';
import '../cubit/audio_library_cubit.dart';
import '../cubit/audio_library_state.dart';
import '../cubit/audio_preview_cubit.dart';
import '../widgets/add_audio_recording_dialog.dart';
import '../widgets/recording_list.dart';

class AudioLibraryScreen extends StatelessWidget {
  const AudioLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AudioLibraryCubit>()..loadRecordings()),
        BlocProvider(create: (_) => sl<AudioPreviewCubit>()),
        BlocProvider(create: (_) => sl<AdhanVoicesCubit>()..loadVoices()),
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
              Tab(icon: Icon(Icons.menu_book_rounded), text: 'تسجيلات القرآن'),
              Tab(icon: Icon(Icons.mosque_rounded), text: 'تسجيلات الأذان'),
              Tab(
                icon: Icon(Icons.record_voice_over_rounded),
                text: 'أصوات المؤذنين',
              ),
            ],
          ),
        ),
        body: ResponsiveBody(
          child: BlocListener<AudioLibraryCubit, AudioLibraryState>(
            listenWhen: (previous, current) =>
                previous.errorMessage != current.errorMessage &&
                current.errorMessage != null,
            listener: (context, state) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            },
            child: const TabBarView(
              children: [
                RecordingList(type: AudioRecordingType.quran),
                RecordingList(type: AudioRecordingType.adhan),
                AdhanVoicesScreen(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
