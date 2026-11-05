import 'package:equatable/equatable.dart';

class ReciterEntity extends Equatable {
  final String identifier;
  final String name;
  final String language;
  final String? englishName;

  final int reciterId;
  final String moshafName;
  final String server;
  final int surahTotal;
  final List<int> surahList;

  const ReciterEntity({
    required this.identifier,
    required this.name,
    required this.language,
    this.englishName,
    required this.reciterId,
    required this.moshafName,
    required this.server,
    required this.surahTotal,
    required this.surahList,
  });

  @override
  List<Object?> get props => [
    identifier,
    name,
    language,
    englishName,
    reciterId,
    moshafName,
    server,
    surahTotal,
    surahList,
  ];
}
