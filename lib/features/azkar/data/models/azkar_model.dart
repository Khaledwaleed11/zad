import '../../domain/entities/azkar_entity.dart';

class AzkarModel {
  final int id;
  final String category;
  final String title;
  final String text;
  final int count;
  final bool isCustom;

  const AzkarModel({
    required this.id,
    required this.category,
    required this.title,
    required this.text,
    required this.count,
    this.isCustom = false,
  });

  factory AzkarModel.fromJson(Map<String, dynamic> json) {
    return AzkarModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      category: json['category']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      count: int.tryParse(json['count']?.toString() ?? '') ?? 1,
      isCustom: json['isCustom'] == true,
    );
  }

  factory AzkarModel.fromMap(Map<dynamic, dynamic> map) {
    return AzkarModel(
      id: map['id'] as int,
      category: map['category'] as String,
      title: map['title'] as String,
      text: map['text'] as String,
      count: map['count'] as int,
      isCustom: map['isCustom'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'text': text,
      'count': count,
      'isCustom': isCustom,
    };
  }

  AzkarEntity toEntity() {
    return AzkarEntity(
      id: id,
      category: category,
      title: title,
      text: text,
      count: count,
      isCustom: isCustom,
    );
  }
}