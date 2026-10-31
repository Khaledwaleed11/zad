
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

abstract class AdhanAudioCacheDataSource {
  Future<String> cacheAudio({
    required String voiceId,
    required String audioUrl,
  });

  Future<String?> getCachedAudioPath(String voiceId);
}

class AdhanAudioCacheDataSourceImpl
    implements AdhanAudioCacheDataSource {
  final http.Client client;

  AdhanAudioCacheDataSourceImpl({
    required this.client,
  });

  Future<Directory> get _audioDirectory async {
    final appDirectory = await getApplicationDocumentsDirectory();

    final directory = Directory(
      '${appDirectory.path}/adhan_audio',
    );

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return directory;
  }

  @override
  Future<String> cacheAudio({
    required String voiceId,
    required String audioUrl,
  }) async {
    final directory = await _audioDirectory;
    final file = File('${directory.path}/$voiceId.mp3');

    if (await file.exists() && await file.length() > 0) {
      return file.path;
    }

    final uri = Uri.parse(audioUrl);

    if (uri.scheme != 'https' && uri.scheme != 'http') {
      throw const FormatException('Invalid audio URL');
    }

    final response = await client.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to download Adhan audio: ${response.statusCode}',
      );
    }

    if (response.bodyBytes.isEmpty) {
      throw Exception('Downloaded Adhan audio is empty');
    }

    try {
      await file.writeAsBytes(
        response.bodyBytes,
        flush: true,
      );

      return file.path;
    } catch (_) {
      if (await file.exists()) {
        await file.delete();
      }
      rethrow;
    }
  }

  @override
  Future<String?> getCachedAudioPath(String voiceId) async {
    final directory = await _audioDirectory;
    final file = File('${directory.path}/$voiceId.mp3');

    if (!await file.exists() || await file.length() == 0) {
      return null;
    }

    return file.path;
  }
}
