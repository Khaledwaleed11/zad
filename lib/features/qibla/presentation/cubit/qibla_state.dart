import 'package:equatable/equatable.dart';

enum QiblaStatus {
  initial,
  loading,
  success,
  failure,
}

class QiblaState extends Equatable {
  final QiblaStatus status;
  final double? qiblaBearing;
  final String? errorMessage;

  const QiblaState({
    this.status = QiblaStatus.initial,
    this.qiblaBearing,
    this.errorMessage,
  });

  QiblaState copyWith({
    QiblaStatus? status,
    double? qiblaBearing,
    String? errorMessage,
    bool clearError = false,
  }) {
    return QiblaState(
      status: status ?? this.status,
      qiblaBearing: qiblaBearing ?? this.qiblaBearing,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    qiblaBearing,
    errorMessage,
  ];
}