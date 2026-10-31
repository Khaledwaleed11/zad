
import 'dart:async';

import 'package:just_audio/just_audio.dart';

class AudioPreviewDataSource {
  final AudioPlayer _audioPlayer = AudioPlayer();

  PlayerState get playerState => _audioPlayer.playerState;

  bool get isPlaying => _audioPlayer.playing;

  Stream<PlayerState> get playerStateStream =>
      _audioPlayer.playerStateStream;

  Future<void> play(String source) async {
    await _audioPlayer.stop();

    final uri = Uri.tryParse(source);

    if (uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https')) {
      await _audioPlayer.setUrl(source);
    } else {
      await _audioPlayer.setFilePath(source);
    }

    unawaited(_audioPlayer.play());
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> resume() async {
    if (_audioPlayer.processingState == ProcessingState.completed) {
      await _audioPlayer.seek(Duration.zero);
    }

    unawaited(_audioPlayer.play());
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
