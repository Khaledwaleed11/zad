import '../../domain/entities/written_dua_entity.dart';

class WrittenDuaModel extends WrittenDuaEntity {
  const WrittenDuaModel({
    required super.id,
    required super.categoryId,
    required super.categoryName,
    required super.title,
    required super.arabicText,
    super.transliteration,
    super.translation,
    super.reference,
    super.repetitionCount,
  });

  factory WrittenDuaModel.fromJson({
    required Map<String, dynamic> entry,
    required Map<String, dynamic> dua,
    required String categoryName,
    int? repetitionCount,
  }) {
    final references = dua['references'] as List<dynamic>? ?? [];

    return WrittenDuaModel(
      id: dua['id'] as String,
      categoryId: (entry['tags'] as List<dynamic>).first as String,
      categoryName: categoryName,
      title: entry['title'] as String,
      arabicText: dua['arabic'] as String,
      transliteration: dua['transliteration'] as String?,
      translation: dua['translation'] as String?,
      reference: references.isNotEmpty ? references.first.toString() : null,
      repetitionCount: repetitionCount,
    );
  }
}