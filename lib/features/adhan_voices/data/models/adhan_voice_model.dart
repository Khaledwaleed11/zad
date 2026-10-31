
import '../../domain/entities/adhan_voice_entity.dart';

class AdhanVoiceModel {
  final String id;
  final String name;
  final String muezzin;
  final String location;
  final String audioUrl;

  const AdhanVoiceModel({
    required this.id,
    required this.name,
    required this.muezzin,
    required this.location,
    required this.audioUrl,
  });

  factory AdhanVoiceModel.fromJson(Map<String, dynamic> json) {
    const baseUrl = 'https://alfurqan.online';

    final id = json['id']?.toString() ?? '';
    final audioPath = json['audioUrl']?.toString() ?? '';

    return AdhanVoiceModel(
      id: id,
      name: json['name']?.toString() ?? '',
      muezzin: json['muezzin']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      audioUrl: audioPath.startsWith('http')
          ? audioPath
          : '$baseUrl$audioPath',
    );
  }

  AdhanVoiceEntity toEntity() {
    return AdhanVoiceEntity(
      id: id,
      name: name,
      muezzin: muezzin,
      location: location,
      audioUrl: audioUrl,
    );
  }
}
