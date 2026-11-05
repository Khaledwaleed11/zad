import '../../domain/entities/reciter_entity.dart';

class ReciterModel extends ReciterEntity {
  const ReciterModel({
    required super.identifier,
    required super.name,
    required super.language,
    super.englishName,
    required super.reciterId,
    required super.moshafName,
    required super.server,
    required super.surahTotal,
    required super.surahList,
  });

  factory ReciterModel.fromJson(
    Map<String, dynamic> reciterJson,
    Map<String, dynamic> moshafJson,
  ) {
    final rawSurahList = moshafJson['surah_list'];

    final surahList = rawSurahList is List
        ? rawSurahList
              .map((value) => int.tryParse(value.toString()))
              .whereType<int>()
              .toList()
        : (rawSurahList?.toString() ?? '')
              .split(',')
              .map((value) => int.tryParse(value.trim()))
              .whereType<int>()
              .toList();

    return ReciterModel(
      identifier: moshafJson['id'].toString(),
      name: reciterJson['name'] as String,
      language: 'ar',
      reciterId: int.parse(reciterJson['id'].toString()),
      moshafName: moshafJson['name'] as String,
      server: moshafJson['server'] as String,
      surahTotal: int.parse(moshafJson['surah_total'].toString()),
      surahList: surahList,
    );
  }

  ReciterEntity toEntity() {
    return ReciterEntity(
      identifier: identifier,
      name: name,
      language: language,
      englishName: englishName,
      reciterId: reciterId,
      moshafName: moshafName,
      server: server,
      surahTotal: surahTotal,
      surahList: surahList,
    );
  }
}
