
import 'package:equatable/equatable.dart';

class DuaCategoryEntity extends Equatable {
  final String id;
  final String name;

  const DuaCategoryEntity({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}
