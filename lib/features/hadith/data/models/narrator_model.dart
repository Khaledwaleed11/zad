
import '../../domain/entities/narrator_entity.dart';

class NarratorModel {
  final String name;
  final String link;

  const NarratorModel({
    required this.name,
    required this.link,
  });

  factory NarratorModel.fromJson(Map<String, dynamic> json) {
    return NarratorModel(
      name: json['name'] as String? ?? '',
      link: json['link'] as String? ?? '',
    );
  }

  NarratorEntity toEntity() {
    return NarratorEntity(
      name: name,
      link: link,
    );
  }
}
