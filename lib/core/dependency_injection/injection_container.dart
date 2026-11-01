import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../../features/adhan_voices/data/datasources/adhan_audio_cache_data_source.dart';
import '../../features/adhan_voices/data/datasources/adhan_voices_local_data_source.dart';
import '../../features/adhan_voices/data/datasources/adhan_voices_remote_data_source.dart';
import '../../features/adhan_voices/data/repositories/adhan_voices_repository_impl.dart';
import '../../features/adhan_voices/domain/repositories/adhan_voices_repository.dart';
import '../../features/adhan_voices/domain/usecases/cache_adhan_voice.dart';
import '../../features/adhan_voices/domain/usecases/get_adhan_voices.dart';
import '../../features/adhan_voices/domain/usecases/get_cached_adhan_voice_path.dart';
import '../../features/adhan_voices/domain/usecases/get_selected_adhan_voice.dart';
import '../../features/adhan_voices/domain/usecases/save_selected_adhan_voice.dart';
import '../../features/adhan_voices/presentation/cubit/adhan_voices_cubit.dart';
import '../../features/audio_library/data/datasources/audio_library_local_data_source.dart';
import '../../features/audio_library/data/datasources/audio_preview_data_source.dart';
import '../../features/audio_library/data/repositories/audio_library_repository_impl.dart';
import '../../features/audio_library/data/repositories/audio_preview_repository_impl.dart';
import '../../features/audio_library/domain/repositories/audio_library_repository.dart';
import '../../features/audio_library/domain/repositories/audio_preview_repository.dart';
import '../../features/audio_library/domain/usecases/add_audio_recording.dart';
import '../../features/audio_library/domain/usecases/delete_audio_recording.dart';
import '../../features/audio_library/domain/usecases/get_audio_recordings.dart';
import '../../features/audio_library/domain/usecases/pause_audio_preview.dart';
import '../../features/audio_library/domain/usecases/play_audio_preview.dart';
import '../../features/audio_library/domain/usecases/resume_audio_preview.dart';
import '../../features/audio_library/domain/usecases/stop_audio_preview.dart';
import '../../features/audio_library/presentation/cubit/audio_library_cubit.dart';
import '../../features/audio_library/presentation/cubit/audio_preview_cubit.dart';
import '../../features/azkar/data/datasources/azkar_local_data_source.dart';
import '../../features/azkar/data/repositories/azkar_repository_impl.dart';
import '../../features/azkar/domain/repositories/azkar_repository.dart';
import '../../features/azkar/domain/usecases/get_azkar.dart';
import '../../features/azkar/presentation/cubit/azkar_cubit.dart';
import '../../features/notifications/data/datasources/notification_local_data_source.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/domain/usecases/cancel_azkar_notifications.dart';
import '../../features/notifications/domain/usecases/cancel_prayer_notifications.dart';
import '../../features/notifications/domain/usecases/initialize_notifications.dart';
import '../../features/notifications/domain/usecases/save_salawat_notifications.dart';
import '../../features/notifications/domain/usecases/schedule_azkar_notifications.dart';
import '../../features/notifications/domain/usecases/schedule_prayer_notifications.dart';
import '../../features/notifications/domain/usecases/schedule_salawat_notifications.dart';
import '../../features/notifications/domain/usecases/cancel_salawat_notifications.dart';
import '../../features/prayer_times/data/datasources/prayer_remote_data_source.dart';
import '../../features/prayer_times/data/repositories/prayer_repository_impl.dart';
import '../../features/prayer_times/domain/repositories/prayer_repository.dart';
import '../../features/prayer_times/domain/usecases/get_prayer_calendar.dart';
import '../../features/prayer_times/domain/usecases/get_prayer_times.dart';
import '../../features/prayer_times/presentation/cubit/prayer_times_cubit.dart';
import '../../features/qibla/data/datasources/qibla_location_data_source.dart';
import '../../features/qibla/data/repositories/qibla_repository_impl.dart';
import '../../features/qibla/domain/repositories/qibla_repository.dart';
import '../../features/qibla/domain/usecases/calculate_qibla_direction.dart';
import '../../features/qibla/domain/usecases/get_current_position.dart';
import '../../features/qibla/presentation/cubit/qibla_cubit.dart';
import '../../features/quran/data/datasources/quran_audio_data_source.dart';
import '../../features/quran/data/datasources/quran_remote_data_source.dart';
import '../../features/quran/data/repositories/quran_repository_impl.dart';
import '../../features/quran/domain/repositories/quran_repository.dart';
import '../../features/quran/domain/usecases/get_all_reciters.dart';
import '../../features/quran/domain/usecases/get_all_surahs.dart';
import '../../features/quran/domain/usecases/get_random_ayah.dart';
import '../../features/quran/domain/usecases/get_surah_ayahs.dart';
import '../../features/quran/presentation/cubit/quran_cubit.dart';
import '../../features/sebha/data/datasources/sebha_local_data_source.dart';
import '../../features/sebha/data/repositories/sebha_repository_impl.dart';
import '../../features/sebha/domain/repositories/sebha_repository.dart';
import '../../features/sebha/domain/usecases/get_sebha_data.dart';
import '../../features/sebha/domain/usecases/reset_sebha_counter.dart';
import '../../features/sebha/domain/usecases/save_sebha_data.dart';
import '../../features/sebha/presentation/cubit/sebha_cubit.dart';
import '../../features/settings/data/datasources/notification_settings_local_data_source.dart';
import '../../features/settings/data/repositories/notification_settings_repository_impl.dart';
import '../../features/settings/domain/repositories/notification_settings_repository.dart';
import '../../features/settings/domain/usecases/get_notification_settings.dart';
import '../../features/settings/domain/usecases/save_adhan_enabled.dart';
import '../../features/settings/domain/usecases/save_azkar_notifications.dart';
import '../../features/settings/domain/usecases/save_prayer_notifications.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';
import '../../services/prayer_service.dart';
import '../../features/azkar/domain/usecases/add_custom_azkar.dart';
import '../../features/azkar/domain/usecases/update_custom_azkar.dart';
import '../../features/azkar/domain/usecases/delete_custom_azkar.dart';
import '../../features/hadith/data/datasources/hadith_remote_data_source.dart';
import '../../features/hadith/data/repositories/hadith_repository_impl.dart';
import '../../features/hadith/domain/repositories/hadith_repository.dart';
import '../../features/hadith/domain/usecases/search_hadith.dart';
import '../../features/hadith/domain/usecases/get_hadith_details.dart';
import '../../features/hadith/domain/usecases/get_hadith_of_the_day.dart';
import '../../features/hadith/domain/usecases/get_random_hadith.dart';
import '../../features/hadith/presentation/cubit/hadith_cubit.dart';
import '../../features/hadith/data/datasources/hadith_local_data_source.dart';
import '../constants/storage_constants.dart';
final sl = GetIt.instance;

Future<void> initDependencies() async {

  // Hadith
  sl.registerLazySingleton<HadithRemoteDataSource>(
        () => HadithRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<HadithLocalDataSource>(
        () => HadithLocalDataSourceImpl(
      settingsBox: Hive.box(StorageConstants.settingsBox),
    ),
  );
  sl.registerLazySingleton<HadithRepository>(
        () => HadithRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton(() => SearchHadith(sl()));
  sl.registerLazySingleton(() => GetHadithDetails(sl()));
  sl.registerLazySingleton(() => GetHadithOfTheDay(sl()));
  sl.registerLazySingleton(() => GetRandomHadith(sl()));
  sl.registerFactory(
        () => HadithCubit(
      searchHadithUseCase: sl(),
      getHadithDetailsUseCase: sl(),
      getHadithOfTheDayUseCase: sl(),
      getRandomHadithUseCase: sl(),
    ),
  );
  // ==================== Quran ====================

  sl.registerLazySingleton<QuranRemoteDataSource>(
    () => QuranRemoteDataSourceImpl(),
  );

  sl.registerLazySingleton<QuranRepository>(
    () => QuranRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton(() => GetRandomAyah(sl()));
  sl.registerLazySingleton(() => GetAllSurahs(sl()));
  sl.registerLazySingleton(() => GetSurahAyahs(sl()));
  sl.registerLazySingleton(() => GetAllReciters(sl()));

  sl.registerFactory(
    () => QuranCubit(
      getRandomAyah: sl(),
      getAllSurahs: sl(),
      getSurahAyahs: sl(),
      getAllReciters: sl(),
      audioDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<QuranAudioDataSource>(() => QuranAudioDataSource());

  // ==================== Azkar ====================

  sl.registerLazySingleton<AzkarLocalDataSource>(
        () => AzkarLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<AzkarRepository>(
        () => AzkarRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton(() => GetAzkar(sl()));
  sl.registerLazySingleton(() => AddCustomAzkar(sl()));
  sl.registerLazySingleton(() => UpdateCustomAzkar(sl()));
  sl.registerLazySingleton(() => DeleteCustomAzkar(sl()));

  sl.registerFactory(
        () => AzkarCubit(
      getAzkar: sl(),
      addCustomAzkar: sl(),
      updateCustomAzkar: sl(),
      deleteCustomAzkar: sl(),
    ),
  );

  // ==================== Prayer Times ====================

  sl.registerLazySingleton<PrayerRemoteDataSource>(
    () => PrayerRemoteDataSourceImpl(),
  );

  sl.registerLazySingleton<PrayerRepository>(
    () => PrayerRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton(() => GetPrayerTimes(sl()));
  sl.registerLazySingleton(() => GetPrayerCalendar(sl()));

  sl.registerFactory(() => PrayerTimesCubit(getPrayerTimes: sl()));

  // ==================== Qibla ====================

  sl.registerLazySingleton<QiblaLocationDataSource>(
    () => QiblaLocationDataSourceImpl(),
  );

  sl.registerLazySingleton<QiblaRepository>(
    () => QiblaRepositoryImpl(locationDataSource: sl()),
  );

  sl.registerLazySingleton(() => GetCurrentPosition(sl()));
  sl.registerLazySingleton(() => CalculateQiblaDirection(sl()));

  sl.registerFactory(
    () => QiblaCubit(getCurrentPosition: sl(), calculateQiblaDirection: sl()),
  );

  // ==================== Sebha ====================

  sl.registerLazySingleton<SebhaLocalDataSource>(
    () => SebhaLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<SebhaRepository>(
    () => SebhaRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton(() => GetSebhaData(sl()));
  sl.registerLazySingleton(() => SaveSebhaData(sl()));
  sl.registerLazySingleton(() => ResetSebhaCounter(sl()));

  sl.registerFactory(
        () => SebhaCubit(
      getSebhaData: sl(),
      saveSebhaData: sl(),
      resetSebhaCounter: sl(),
      getAzkar: sl(),
    ),
  );

  // ==================== Settings ====================

  sl.registerLazySingleton<NotificationSettingsLocalDataSource>(
    () => NotificationSettingsLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<NotificationSettingsRepository>(
    () => NotificationSettingsRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton(() => GetNotificationSettings(sl()));
  sl.registerLazySingleton(() => SavePrayerNotifications(sl()));
  sl.registerLazySingleton(() => SaveAzkarNotifications(sl()));
  sl.registerLazySingleton(() => SaveAdhanEnabled(sl()));
  sl.registerLazySingleton(() => SaveSalawatNotifications(sl()));

  sl.registerFactory(
        () => SettingsCubit(
      getNotificationSettings: sl(),
      savePrayerNotifications: sl(),
      saveAzkarNotifications: sl(),
      saveAdhanEnabled: sl(),
      saveSalawatNotifications: sl(),
      schedulePrayerNotifications: sl(),
      cancelPrayerNotifications: sl(),
      scheduleAzkarNotifications: sl(),
      cancelAzkarNotifications: sl(),
      scheduleSalawatNotifications: sl(),
      cancelSalawatNotifications: sl(),
    ),
  );

  // ==================== Notifications ====================

  sl.registerLazySingleton<PrayerService>(
        () => PrayerService(
      getSelectedAdhanVoice: sl(),
      getCachedAdhanVoicePath: sl(),
    ),
  );
  sl.registerLazySingleton<NotificationLocalDataSource>(
    () => NotificationLocalDataSourceImpl(prayerService: sl()),
  );

  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton(() => SchedulePrayerNotifications(sl()));
  sl.registerLazySingleton(() => CancelPrayerNotifications(sl()));
  sl.registerLazySingleton(() => ScheduleAzkarNotifications(sl()));
  sl.registerLazySingleton(() => CancelAzkarNotifications(sl()));
  sl.registerLazySingleton(() => ScheduleSalawatNotifications(sl()));
  sl.registerLazySingleton(() => CancelSalawatNotifications(sl()));
  sl.registerLazySingleton(
        () => InitializeNotifications(
      getNotificationSettings: sl(),
      schedulePrayerNotifications: sl(),
      cancelPrayerNotifications: sl(),
      scheduleAzkarNotifications: sl(),
      cancelAzkarNotifications: sl(),
      scheduleSalawatNotifications: sl(),
      cancelSalawatNotifications: sl(),
    ),
  );

  // Audio Library

  sl.registerLazySingleton<AudioLibraryLocalDataSource>(
    () => AudioLibraryLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<AudioLibraryRepository>(
    () => AudioLibraryRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton(() => AddAudioRecording(sl()));

  sl.registerLazySingleton(() => GetAudioRecordings(sl()));

  sl.registerLazySingleton(() => DeleteAudioRecording(sl()));
  sl.registerFactory(
    () => AudioLibraryCubit(
      addAudioRecording: sl(),
      getAudioRecordings: sl(),
      deleteAudioRecording: sl(),
    ),
  );
  // Audio Preview

  sl.registerLazySingleton(() => AudioPreviewDataSource());

  sl.registerLazySingleton<AudioPreviewRepository>(
    () => AudioPreviewRepositoryImpl(dataSource: sl()),
  );

  sl.registerLazySingleton(() => PlayAudioPreview(sl()));

  sl.registerLazySingleton(() => PauseAudioPreview(sl()));

  sl.registerLazySingleton(() => ResumeAudioPreview(sl()));

  sl.registerLazySingleton(() => StopAudioPreview(sl()));

  sl.registerFactory(
    () => AudioPreviewCubit(
      playAudioPreview: sl(),
      pauseAudioPreview: sl(),
      resumeAudioPreview: sl(),
      stopAudioPreview: sl(),
      repository: sl(),
    ),
  );
  // ==================== Adhan Voices ====================

  sl.registerLazySingleton<http.Client>(() => http.Client());
  sl.registerLazySingleton<AdhanAudioCacheDataSource>(
    () => AdhanAudioCacheDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<AdhanVoicesRemoteDataSource>(
    () => AdhanVoicesRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<AdhanVoicesLocalDataSource>(
    () => AdhanVoicesLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<AdhanVoicesRepository>(
    () => AdhanVoicesRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      audioCacheDataSource: sl(),
    ),
  );
  sl.registerLazySingleton(() => CacheAdhanVoice(sl()));

  sl.registerLazySingleton(() => GetCachedAdhanVoicePath(sl()));

  sl.registerLazySingleton(() => GetAdhanVoices(sl()));

  sl.registerLazySingleton(() => GetSelectedAdhanVoice(sl()));

  sl.registerLazySingleton(() => SaveSelectedAdhanVoice(sl()));


  sl.registerFactory(
        () => AdhanVoicesCubit(
      getAdhanVoices: sl(),
      getSelectedAdhanVoice: sl(),
      saveSelectedAdhanVoice: sl(),
      cacheAdhanVoice: sl(),
      schedulePrayerNotifications: sl(),
    ),
  );

}
