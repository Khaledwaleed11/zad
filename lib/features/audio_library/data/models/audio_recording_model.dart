
import '../../domain/entities/audio_recording_entity.dart';

class AudioRecordingModel extends AudioRecordingEntity {
  const AudioRecordingModel({
    required super.id,
    required super.name,
    required super.type,
    super.surahNumber,
    required super.filePath,
    required super.createdAt,
  });

  factory AudioRecordingModel.fromMap(Map<dynamic, dynamic> map) {
    return AudioRecordingModel(
      id: map['id'] as String,
      name: map['name'] as String,
      type: AudioRecordingType.values.firstWhere(
            (type) => type.name == map['type'],
      ),
      surahNumber: map['surahNumber'] as int?,
      filePath: map['filePath'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'surahNumber': surahNumber,
      'filePath': filePath,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
