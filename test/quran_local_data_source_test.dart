
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

import 'package:zad/features/quran/data/datasources/quran_local_data_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Load and validate all Quran ayahs', () async {
    final dataSource = QuranLocalDataSource();

    final ayahs = await dataSource.getAllAyahs();

    expect(ayahs.length, 6236);
    expect(ayahs.first.surahNumber, 1);
    expect(ayahs.first.ayahNumber, 1);
    expect(ayahs.last.surahNumber, 114);
    expect(ayahs.last.ayahNumber, 6);
  });
}
