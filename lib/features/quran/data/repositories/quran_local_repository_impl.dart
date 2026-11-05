import '../../domain/entities/quran_local_ayah_entity.dart';
import '../../domain/repositories/quran_local_repository.dart';
import '../datasources/quran_local_data_source.dart';

class QuranLocalRepositoryImpl implements QuranLocalRepository {
  final QuranLocalDataSource localDataSource;

  QuranLocalRepositoryImpl({required this.localDataSource});

  @override
  Future<List<QuranLocalAyahEntity>> getAllAyahs() async {
    final ayahs = await localDataSource.getAllAyahs();

    return ayahs.map((ayah) => ayah.toEntity()).toList();
  }
}
