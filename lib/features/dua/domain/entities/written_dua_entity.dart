
import 'package:equatable/equatable.dart';

class WrittenDuaEntity extends Equatable {
  final String id;
  final String categoryId;
  final String categoryName;
  final String title;
  final String arabicText;
  final String? transliteration;
  final String? translation;
  final String? reference;
  final int? repetitionCount;

  const WrittenDuaEntity({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.title,
    required this.arabicText,
    this.transliteration,
    this.translation,
    this.reference,
    this.repetitionCount,
  });

  @override
  List<Object?> get props => [
    id,
    categoryId,
    categoryName,
    title,
    arabicText,
    transliteration,
    translation,
    reference,
    repetitionCount,
  ];
}
