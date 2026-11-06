import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

import '../../domain/entities/quran_ayah_entity.dart';
import '../../domain/entities/reciter_entity.dart';

class QuranAudioDataSource {
  final AudioPlayer _audioPlayer = AudioPlayer();

  static const String _mp3QuranBaseUrl = 'https://mp3quran.net/api/v3';

  ReciterEntity? _selectedReciter;

  int? _loadedSurahNumber;
  int? _singleAyahNumber;

  List<QuranAyahEntity> _currentAyahs = [];
  List<_AyahTiming> _timings = [];

  List<Map<String, dynamic>>? _timingReads;

  final Map<String, List<_AyahTiming>> _timingCache = {};

  String get selectedReciter => _selectedReciter?.identifier ?? '';

  bool get isPlaying => _audioPlayer.playing;

  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  Stream<int?> get currentAyahNumberStream => _audioPlayer.positionStream
      .map((_) => currentAyahNumber)
      .distinct()
      .map((ayahNumber) {
        debugPrint(
          'CURRENT AYAH STREAM: $ayahNumber | '
          'POSITION: ${_audioPlayer.position.inMilliseconds} ms',
        );
        return ayahNumber;
      });

  int? get currentAyahNumber {
    if (kDebugMode) {
      debugPrint('========== AYAH DEBUG ==========');
      debugPrint('Position: ${_audioPlayer.position.inMilliseconds}');
      debugPrint('Timings count: ${_timings.length}');
      debugPrint('Current ayahs count: ${_currentAyahs.length}');
    }

    if (_currentAyahs.isEmpty || _timings.isEmpty) {
      return null;
    }

    final position = _audioPlayer.position.inMilliseconds;

    for (final timing in _timings) {
      if (position >= timing.startTime && position < timing.endTime) {
        if (kDebugMode) {
          debugPrint('Current timing ayah: ${timing.ayahNumber}');
        }

        for (final ayah in _currentAyahs) {
          if (ayah.numberInSurah == timing.ayahNumber) {
            if (kDebugMode) {
              debugPrint('Current ayah: ${ayah.number}');
            }

            return ayah.number;
          }
        }
      }
    }

    if (kDebugMode) {
      debugPrint('No matching ayah found for position: $position');
    }

    return null;
  }

  // اختيار القارئ وإيقاف التلاوة السابقة.
  Future<void> selectReciter(ReciterEntity reciter) async {
    if (_selectedReciter?.identifier == reciter.identifier) {
      return;
    }

    await stop();
    _selectedReciter = reciter;
  }

  // إنشاء رابط السورة.
  String _getSurahAudioUrl(int surahNumber) {
    final reciter = _selectedReciter;

    if (reciter == null) {
      throw Exception('No reciter selected.');
    }
    debugPrint('========== AUDIO DEBUG ==========');
    debugPrint('Reciter: ${reciter.name}');
    debugPrint('Moshaf: ${reciter.moshafName}');
    debugPrint('Moshaf ID: ${reciter.identifier}');
    debugPrint('Surah Number: $surahNumber');
    debugPrint('Surah List: ${reciter.surahList}');
    debugPrint('=================================');
    if (!reciter.surahList.contains(surahNumber)) {
      throw Exception('This reciter does not support this surah.');
    }

    final server = reciter.server.endsWith('/')
        ? reciter.server
        : '${reciter.server}/';

    final surahFile = '${surahNumber.toString().padLeft(3, '0')}.mp3';

    return '$server$surahFile';
  }

  // تحميل القراءات التي تحتوي على توقيت للآيات.
  Future<List<Map<String, dynamic>>> _loadTimingReads() async {
    if (_timingReads != null) {
      return _timingReads!;
    }

    final uri = Uri.parse('$_mp3QuranBaseUrl/ayat_timing/reads');

    final response = await http.get(uri).timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Failed to load timing reads: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);

    final List<dynamic> data;

    if (decoded is List) {
      data = decoded;
    } else if (decoded is Map && decoded['reads'] is List) {
      data = decoded['reads'] as List;
    } else {
      throw Exception('Invalid timing reads response.');
    }

    _timingReads = data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    return _timingReads!;
  }

  // البحث عن قراءة التوقيت المطابقة لسيرفر القارئ.
  Future<int?> _getTimingReadId() async {
    final reciter = _selectedReciter;

    if (reciter == null) {
      debugPrint('ERROR: No selected reciter.');
      return null;
    }

    final reads = await _loadTimingReads();

    final selectedUri = Uri.parse(reciter.server);

    debugPrint('========== SELECTED RECITER ==========');
    debugPrint('Name: ${reciter.name}');
    debugPrint('Moshaf: ${reciter.moshafName}');
    debugPrint('Server: ${reciter.server}');
    debugPrint('Server URI: $selectedUri');
    debugPrint('Host: ${selectedUri.host}');
    debugPrint('Path: ${selectedUri.path}');

    debugPrint('========== TIMING READS ==========');

    for (final read in reads) {
      final folderUrl = read['folder_url']?.toString();

      debugPrint(
        'ID: ${read['id']} | '
        'Name: ${read['name']} | '
        'Rewaya: ${read['rewaya']} | '
        'Folder: $folderUrl',
      );

      if (folderUrl == null || folderUrl.isEmpty) {
        continue;
      }

      final timingUri = Uri.tryParse(folderUrl);

      if (timingUri == null) continue;

      final sameHost =
          selectedUri.host.toLowerCase() == timingUri.host.toLowerCase();

      final selectedPath = selectedUri.path.replaceAll(RegExp(r'/+$'), '');

      final timingPath = timingUri.path.replaceAll(RegExp(r'/+$'), '');

      final samePath = selectedPath == timingPath;

      debugPrint(
        'Comparing ID ${read['id']}: '
        'sameHost=$sameHost, samePath=$samePath',
      );

      if (sameHost && samePath) {
        final readId = int.tryParse(read['id'].toString());

        debugPrint('MATCH FOUND: $readId');

        return readId;
      }
    }

    debugPrint('ERROR: No matching timing read found.');
    return null;
  }

  // تحميل توقيت آيات السورة.
  Future<List<_AyahTiming>> _loadAyahTimings(int surahNumber) async {
    debugPrint('========== TIMING LOAD DEBUG ==========');

    final readId = await _getTimingReadId();

    debugPrint('Selected read ID: $readId');
    debugPrint('Surah number: $surahNumber');

    if (readId == null) {
      debugPrint('ERROR: No matching timing read found.');
      return [];
    }

    final cacheKey = '${readId}_$surahNumber';

    if (_timingCache.containsKey(cacheKey)) {
      debugPrint('Using cached timings.');
      return _timingCache[cacheKey]!;
    }

    final uri = Uri.parse('$_mp3QuranBaseUrl/ayat_timing').replace(
      queryParameters: {
        'surah': surahNumber.toString(),
        'read': readId.toString(),
      },
    );

    debugPrint('Timing URL: $uri');

    final response = await http.get(uri).timeout(const Duration(seconds: 20));

    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode != 200) {
      debugPrint('ERROR: Timing request failed.');
      return [];
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      debugPrint('ERROR: Response is not a List.');
      return [];
    }

    debugPrint('Received timing records: ${decoded.length}');

    final timings = decoded
        .whereType<Map>()
        .map(
          (item) => _AyahTiming(
            ayahNumber: int.tryParse(item['ayah'].toString()) ?? -1,
            startTime: int.tryParse(item['start_time'].toString()) ?? 0,
            endTime: int.tryParse(item['end_time'].toString()) ?? 0,
          ),
        )
        .where(
          (timing) =>
              timing.ayahNumber > 0 && timing.endTime > timing.startTime,
        )
        .toList();

    debugPrint('Valid timings: ${timings.length}');
    debugPrint('========================================');

    _timingCache[cacheKey] = timings;

    return timings;
  }

  // تحميل ملف السورة وتجهيز بياناتها.
  Future<void> _loadSurah(List<QuranAyahEntity> ayahs) async {
    if (ayahs.isEmpty) return;

    final surahNumber = ayahs.first.surahNumber;

    if (ayahs.any((ayah) => ayah.surahNumber != surahNumber)) {
      throw Exception('Ayahs must belong to the same surah.');
    }

    final audioUrl = _getSurahAudioUrl(surahNumber);

    final timings = await _loadAyahTimings(surahNumber);

    debugPrint('TIMINGS COUNT: ${timings.length}');
    debugPrint('FIRST TIMING: ${timings.isNotEmpty ? timings.first : 'EMPTY'}');

    await _audioPlayer.setUrl(audioUrl);

    _loadedSurahNumber = surahNumber;
    _currentAyahs = List<QuranAyahEntity>.from(ayahs);
    _timings = timings;
    _singleAyahNumber = null;
  }

  // تشغيل آية منفردة.
  Future<void> toggleAyah(QuranAyahEntity ayah) async {
    if (_selectedReciter == null) {
      throw Exception('No reciter selected.');
    }

    if (_loadedSurahNumber != ayah.surahNumber) {
      await _loadSurah([ayah]);
    }

    final timing = _timings.where(
      (item) => item.ayahNumber == ayah.numberInSurah,
    );

    if (timing.isEmpty) {
      throw Exception(
        'Individual ayah playback is not available for this reciter.',
      );
    }

    final selectedTiming = timing.first;

    if (_singleAyahNumber == ayah.number && currentAyahNumber == ayah.number) {
      if (_audioPlayer.playing) {
        await pause();
      } else {
        await resume();
      }

      return;
    }

    _currentAyahs = [ayah];
    _singleAyahNumber = ayah.number;

    await _audioPlayer.setClip(
      start: Duration(milliseconds: selectedTiming.startTime),
      end: Duration(milliseconds: selectedTiming.endTime),
    );

    await _audioPlayer.seek(Duration(milliseconds: selectedTiming.startTime));

    unawaited(_audioPlayer.play());
  }

  // تشغيل السورة كاملة.
  Future<void> playSurah(List<QuranAyahEntity> ayahs) async {
    if (ayahs.isEmpty) return;

    final isSameSurah = _loadedSurahNumber == ayahs.first.surahNumber;

    if (isSameSurah) {
      if (_audioPlayer.playing && _singleAyahNumber == null) {
        await pause();
        return;
      }

      if (!_audioPlayer.playing &&
          _audioPlayer.processingState != ProcessingState.completed &&
          _singleAyahNumber == null) {
        await resume();
        return;
      }
    }

    if (!isSameSurah) {
      await _loadSurah(ayahs);
    } else {
      _currentAyahs = List<QuranAyahEntity>.from(ayahs);
    }

    await _audioPlayer.setClip();

    _singleAyahNumber = null;

    await _audioPlayer.seek(Duration.zero);

    unawaited(_audioPlayer.play());
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> resume() async {
    if (_loadedSurahNumber == null) return;

    unawaited(_audioPlayer.play());
  }

  Future<void> stop() async {
    await _audioPlayer.stop();

    _loadedSurahNumber = null;
    _singleAyahNumber = null;

    _currentAyahs = [];
    _timings = [];
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}

class _AyahTiming {
  final int ayahNumber;
  final int startTime;
  final int endTime;

  const _AyahTiming({
    required this.ayahNumber,
    required this.startTime,
    required this.endTime,
  });
}
