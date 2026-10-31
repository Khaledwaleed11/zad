
import 'package:equatable/equatable.dart';

enum AudioRecordingType {
  quran,
  adhan,
}

class AudioRecordingEntity extends Equatable {
  final String id;
  final String name;
  final AudioRecordingType type;
  final int? surahNumber;
  final String filePath;
  final DateTime createdAt;

  const AudioRecordingEntity({
    required this.id,
    required this.name,
    required this.type,
    this.surahNumber,
    required this.filePath,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    surahNumber,
    filePath,
    createdAt,
  ];
}
