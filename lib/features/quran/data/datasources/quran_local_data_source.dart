import 'package:flutter/services.dart';

import '../models/quran_local_ayah_model.dart';

class QuranLocalDataSource {
  static const String _quranAssetPath = 'assets/quran/quran-uthmani.txt';
  static const List<int> _expectedAyahCounts = [
    7,
    286,
    200,
    176,
    120,
    165,
    206,
    75,
    129,
    109,
    123,
    111,
    43,
    52,
    99,
    128,
    111,
    110,
    98,
    135,
    112,
    78,
    118,
    64,
    77,
    227,
    93,
    88,
    69,
    60,
    34,
    30,
    73,
    54,
    45,
    83,
    182,
    88,
    75,
    85,
    54,
    53,
    89,
    59,
    37,
    35,
    38,
    29,
    18,
    45,
    60,
    49,
    62,
    55,
    78,
    96,
    29,
    22,
    24,
    13,
    14,
    11,
    11,
    18,
    12,
    12,
    30,
    52,
    52,
    44,
    28,
    28,
    20,
    56,
    40,
    31,
    50,
    40,
    46,
    42,
    29,
    19,
    36,
    25,
    22,
    17,
    19,
    26,
    30,
    20,
    15,
    21,
    11,
    8,
    8,
    19,
    5,
    8,
    8,
    11,
    11,
    8,
    3,
    9,
    5,
    4,
    7,
    3,
    6,
    3,
    5,
    4,
    5,
    6,
  ];
  List<QuranLocalAyahModel>? _cachedAyahs;
  Future<List<QuranLocalAyahModel>>? _loadingFuture;
  Future<List<QuranLocalAyahModel>> getAllAyahs() async {
    if (_cachedAyahs != null) {
      return _cachedAyahs!;
    }

    if (_loadingFuture != null) {
      return _loadingFuture!;
    }

    final future = _loadAyahs();
    _loadingFuture = future;

    try {
      final ayahs = await future;

      _cachedAyahs = List.unmodifiable(ayahs);

      return _cachedAyahs!;
    } finally {
      _loadingFuture = null;
    }
  }

  Future<List<QuranLocalAyahModel>> _loadAyahs() async {
    final content = await rootBundle.loadString(_quranAssetPath);

    final lines = content
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .where((line) => RegExp(r'^\d+\|\d+\|').hasMatch(line));

    final ayahs = lines.map(QuranLocalAyahModel.fromLine).toList();

    _validateQuranData(ayahs);

    return ayahs;
  }
  void _validateQuranData(List<QuranLocalAyahModel> ayahs) {
    if (_expectedAyahCounts.length != 114) {
      throw FormatException('Invalid reference data.');
    }

    final expectedTotal = _expectedAyahCounts.reduce((a, b) => a + b);

    if (ayahs.length != expectedTotal) {
      throw FormatException('Invalid total ayah count.');
    }

    int index = 0;

    for (int surah = 1; surah <= 114; surah++) {
      final expectedCount = _expectedAyahCounts[surah - 1];

      for (int ayahNumber = 1; ayahNumber <= expectedCount; ayahNumber++) {
        final ayah = ayahs[index];

        if (ayah.surahNumber != surah ||
            ayah.ayahNumber != ayahNumber ||
            ayah.text.trim().isEmpty) {
          throw FormatException(
            'Invalid data at Surah $surah, Ayah $ayahNumber.',
          );
        }

        index++;
      }
    }

    if (index != ayahs.length) {
      throw FormatException('Unexpected extra Quran data.');
    }
  }
}
