import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/calculate_qibla_direction.dart';
import '../../domain/usecases/get_current_position.dart';
import 'qibla_state.dart';

class QiblaCubit extends Cubit<QiblaState> {
  final GetCurrentPosition getCurrentPosition;
  final CalculateQiblaDirection calculateQiblaDirection;

  QiblaCubit({
    required this.getCurrentPosition,
    required this.calculateQiblaDirection,
  }) : super(const QiblaState());

  Future<void> loadQibla() async {
    emit(
      state.copyWith(
        status: QiblaStatus.loading,
        clearError: true,
      ),
    );

    try {
      final position = await getCurrentPosition();

      final bearing = calculateQiblaDirection(
        position.latitude,
        position.longitude,
      );

      emit(
        QiblaState(
          status: QiblaStatus.success,
          qiblaBearing: bearing,
        ),
      );
    } catch (e) {
      emit(
        QiblaState(
          status: QiblaStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}