import 'package:equatable/equatable.dart';

import '../../domain/entities/prayer_times_entity.dart';

enum PrayerTimesStatus {
  initial,
  loading,
  success,
  failure,
}

class PrayerTimesState extends Equatable {
  final PrayerTimesStatus status;
  final PrayerTimesEntity? prayerTimes;
  final String? errorMessage;

  const PrayerTimesState({
    this.status = PrayerTimesStatus.initial,
    this.prayerTimes,
    this.errorMessage,
  });

  PrayerTimesState copyWith({
    PrayerTimesStatus? status,
    PrayerTimesEntity? prayerTimes,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PrayerTimesState(
      status: status ?? this.status,
      prayerTimes: prayerTimes ?? this.prayerTimes,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    prayerTimes,
    errorMessage,
  ];
}