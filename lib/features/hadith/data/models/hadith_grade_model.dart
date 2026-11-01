
import '../../domain/entities/hadith_grade_entity.dart';

class HadithGradeModel {
  final String label;
  final String basis;

  const HadithGradeModel({
    required this.label,
    required this.basis,
  });

  factory HadithGradeModel.fromJson(Map<String, dynamic> json) {
    return HadithGradeModel(
      label: json['label'] as String? ?? '',
      basis: json['basis'] as String? ?? '',
    );
  }

  HadithGradeEntity toEntity() {
    return HadithGradeEntity(
      label: label,
      basis: basis,
    );
  }
}
