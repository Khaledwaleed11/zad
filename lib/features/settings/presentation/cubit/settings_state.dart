import 'package:equatable/equatable.dart';

enum SettingsStatus {
  initial,
  loading,
  success,
  failure,
}

class SettingsState extends Equatable {
  final SettingsStatus status;
  final bool prayerNotificationsEnabled;
  final bool azkarNotificationsEnabled;
  final bool adhanEnabled;
  final String? errorMessage;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.prayerNotificationsEnabled = true,
    this.azkarNotificationsEnabled = true,
    this.adhanEnabled = false,
    this.errorMessage,
  });

  SettingsState copyWith({
    SettingsStatus? status,
    bool? prayerNotificationsEnabled,
    bool? azkarNotificationsEnabled,
    bool? adhanEnabled,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SettingsState(
      status: status ?? this.status,
      prayerNotificationsEnabled:
      prayerNotificationsEnabled ?? this.prayerNotificationsEnabled,
      azkarNotificationsEnabled:
      azkarNotificationsEnabled ?? this.azkarNotificationsEnabled,
      adhanEnabled: adhanEnabled ?? this.adhanEnabled,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    prayerNotificationsEnabled,
    azkarNotificationsEnabled,
    adhanEnabled,
    errorMessage,
  ];
}