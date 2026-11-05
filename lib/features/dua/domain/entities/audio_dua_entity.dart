
import 'package:equatable/equatable.dart';

class AudioDuaEntity extends Equatable {
  final String id;
  final String title;
  final String reciterName;
  final String audioUrl;
  final int? durationSeconds;
  final String? source;
  final String? license;
  final String? attribution;

  const AudioDuaEntity({
    required this.id,
    required this.title,
    required this.reciterName,
    required this.audioUrl,
    this.durationSeconds,
    this.source,
    this.license,
    this.attribution,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    reciterName,
    audioUrl,
    durationSeconds,
    source,
    license,
    attribution,
  ];
}
