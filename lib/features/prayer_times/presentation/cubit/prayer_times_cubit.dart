import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_prayer_times.dart';
import 'prayer_times_state.dart';

class PrayerTimesCubit extends Cubit<PrayerTimesState> {
  final GetPrayerTimes getPrayerTimes;

  PrayerTimesCubit({
    required this.getPrayerTimes,
  }) : super(const PrayerTimesState());

  Future<void> loadPrayerTimes() async {
    emit(
      state.copyWith(
        status: PrayerTimesStatus.loading,
        clearError: true,
      ),
    );

    try {
      final prayerTimes = await getPrayerTimes();

      emit(
        PrayerTimesState(
          status: PrayerTimesStatus.success,
          prayerTimes: prayerTimes,
        ),
      );
    } catch (e) {
      emit(
        PrayerTimesState(
          status: PrayerTimesStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}