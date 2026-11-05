import '../../domain/entities/quran_ayah_entity.dart';
import '../../domain/entities/surah_entity.dart';
import '../../domain/entities/reciter_entity.dart';
import '../../domain/repositories/quran_repository.dart';
import '../datasources/quran_remote_data_source.dart';
import '../models/quran_ayah_model.dart';
import '../models/surah_model.dart';
import '../models/reciter_model.dart';

class QuranRepositoryImpl implements QuranRepository {
  final QuranRemoteDataSource remoteDataSource;

  QuranRepositoryImpl({required this.remoteDataSource});

  @override
  Future<QuranAyahEntity> getRandomAyah() async {
    final response = await remoteDataSource.getRandomAyah();

    final data = response['data'];

    if (data is! Map) {
      throw Exception('Invalid random ayah response');
    }

    final model = QuranAyahModel.fromJson(Map<String, dynamic>.from(data));

    return model.toEntity();
  }

  @override
  Future<List<SurahEntity>> getAllSurahs() async {
    final response = await remoteDataSource.getAllSurahs();

    final data = response['data'];

    if (data is! List) {
      throw Exception('Invalid surahs response');
    }

    return data
        .whereType<Map>()
        .map(
          (surah) =>
              SurahModel.fromJson(Map<String, dynamic>.from(surah)).toEntity(),
        )
        .toList();
  }

  @override
  Future<List<QuranAyahEntity>> getSurahAyahs(int surahNumber) async {
    final response = await remoteDataSource.getSurah(surahNumber);

    final data = response['data'];

    if (data is! Map || data['ayahs'] is! List) {
      throw Exception('Invalid surah response');
    }

    final ayahs = data['ayahs'] as List;

    return ayahs.whereType<Map>().map((ayah) {
      final ayahJson = Map<String, dynamic>.from(ayah);

      // ضمان وجود بيانات السورة لكل آية.
      ayahJson['surah'] = {
        'number': surahNumber,
        'name': data['name'] ?? '',
        'revelationType': data['revelationType'] ?? '',
      };

      return QuranAyahModel.fromJson(ayahJson).toEntity();
    }).toList();
  }

  @override
  Future<List<ReciterEntity>> getAllReciters() async {
    final response = await remoteDataSource.getAllReciters();

    final data = response['reciters'];

    if (data is! List) {
      throw Exception('Invalid MP3Quran reciters response');
    }

    final reciters = <ReciterEntity>[];

    for (final reciter in data) {
      if (reciter is! Map) continue;

      final reciterJson = Map<String, dynamic>.from(reciter);
      final moshafs = reciterJson['moshaf'];

      if (moshafs is! List) continue;

      for (final moshaf in moshafs) {
        if (moshaf is! Map) continue;

        try {
          final model = ReciterModel.fromJson(
            reciterJson,
            Map<String, dynamic>.from(moshaf),
          );

          if (model.server.isNotEmpty && model.surahList.isNotEmpty) {
            reciters.add(model.toEntity());
          }
        } catch (_) {
          // تجاهل بيانات المصحف غير المكتملة.
        }
      }
    }

    if (reciters.isEmpty) {
      throw Exception('No valid reciters were found.');
    }

    return reciters;
  }
}
