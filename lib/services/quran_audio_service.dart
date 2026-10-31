
import 'dart:async';

import 'package:just_audio/just_audio.dart';

class QuranAudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  int? _currentAyahNumber;

  int? get currentAyahNumber => _currentAyahNumber;

  bool get isPlaying => _audioPlayer.playing;

  Stream<PlayerState> get playerStateStream =>
      _audioPlayer.playerStateStream;

  Future<void> toggleAyah(int ayahNumber) async {
    if (_currentAyahNumber == ayahNumber) {
      if (_audioPlayer.playing) {
        await _audioPlayer.pause();
      } else {
        if (_audioPlayer.processingState ==
            ProcessingState.completed) {
          await _audioPlayer.seek(Duration.zero);
        }

        unawaited(_audioPlayer.play());
      }

      return;
    }

    _currentAyahNumber = ayahNumber;

    final audioUrl =
        'https://cdn.islamic.network/quran/audio/128/ar.alafasy/$ayahNumber.mp3';

    await _audioPlayer.setUrl(audioUrl);

    unawaited(_audioPlayer.play());
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentAyahNumber = null;
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
