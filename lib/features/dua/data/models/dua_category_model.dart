import '../../domain/entities/dua_category_entity.dart';

class DuaCategoryModel extends DuaCategoryEntity {
  const DuaCategoryModel({
    required super.id,
    required super.name,
  });

  factory DuaCategoryModel.fromJson(Map<String, dynamic> json) {
    return DuaCategoryModel(
      id: json['id'] as String,
      name: json['title'] as String,
    );
  }
}