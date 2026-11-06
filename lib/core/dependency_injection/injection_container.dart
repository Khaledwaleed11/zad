import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/storage_constants.dart';
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
import '../../features/azkar/domain/usecases/add_custom_azkar.dart';
import '../../features/azkar/domain/usecases/delete_custom_azkar.dart';
import '../../features/azkar/domain/usecases/get_azkar.dart';
import '../../features/azkar/domain/usecases/update_custom_azkar.dart';
import '../../features/azkar/presentation/cubit/azkar_cubit.dart';
import '../../features/dua/data/datasources/written_dua_local_data_source.dart';
import '../../features/dua/data/repositories/written_dua_repository_impl.dart';
import '../../features/dua/domain/repositories/written_dua_repository.dart';
import '../../features/dua/domain/usecases/written/get_all_duas.dart';
import '../../features/dua/domain/usecases/written/get_dua_categories.dart';
import '../../features/dua/domain/usecases/written/get_duas_by_category.dart';
import '../../features/dua/domain/usecases/written/get_favorite_dua_ids.dart';
import '../../features/dua/domain/usecases/written/search_duas.dart';
import '../../features/dua/domain/usecases/written/toggle_dua_favorite.dart';
import '../../features/dua/presentation/cubit/written_dua_cubit.dart';
import '../../features/hadith/data/datasources/hadith_local_data_source.dart';
import '../../features/hadith/data/datasources/hadith_remote_data_source.dart';
import '../../features/hadith/data/repositories/hadith_repository_impl.dart';
import '../../features/hadith/domain/repositories/hadith_repository.dart';
import '../../features/hadith/domain/usecases/get_hadith_details.dart';
import '../../features/hadith/domain/usecases/get_hadith_of_the_day.dart';
import '../../features/hadith/domain/usecases/get_random_hadith.dart';
import '../../features/hadith/domain/usecases/search_hadith.dart';
import '../../features/hadith/presentation/cubit/hadith_cubit.dart';
import '../../features/notifications/data/datasources/notification_local_data_source.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/domain/usecases/cancel_azkar_notifications.dart';
import '../../features/notifications/domain/usecases/cancel_prayer_notifications.dart';
import '../../features/notifications/domain/usecases/cancel_salawat_notifications.dart';
import '../../features/notifications/domain/usecases/initialize_notifications.dart';
import '../../features/notifications/domain/usecases/save_salawat_notifications.dart';
import '../../features/notifications/domain/usecases/schedule_azkar_notifications.dart';
import '../../features/notifications/domain/usecases/schedule_prayer_notifications.dart';
import '../../features/notifications/domain/usecases/schedule_salawat_notifications.dart';
import '../../features/prophets_stories/data/datasources/prophets_stories_remote_data_source.dart';
import '../../features/prophets_stories/data/repositories/prophets_stories_repository_impl.dart';
import '../../features/prophets_stories/domain/repositories/prophets_stories_repository.dart';
import '../../features/prophets_stories/domain/usecases/get_prophet_story_content.dart';
import '../../features/prophets_stories/domain/usecases/get_prophet_story_sections.dart';
import '../../features/prophets_stories/presentation/cubit/prophets_stories_cubit.dart';
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
import '../../features/quran/data/datasources/memorization_test_local_data_source.dart';
import '../../features/quran/data/datasources/quran_audio_data_source.dart';
import '../../features/quran/data/datasources/quran_local_data_source.dart';
import '../../features/quran/data/datasources/quran_remote_data_source.dart';
import '../../features/quran/data/repositories/memorization_question_generator_repository_impl.dart';
import '../../features/quran/data/repositories/memorization_test_repository_impl.dart';
import '../../features/quran/data/repositories/quran_local_repository_impl.dart';
import '../../features/quran/data/repositories/quran_repository_impl.dart';
import '../../features/quran/domain/repositories/memorization_question_generator_repository.dart';
import '../../features/quran/domain/repositories/memorization_test_repository.dart';
import '../../features/quran/domain/repositories/quran_local_repository.dart';
import '../../features/quran/domain/repositories/quran_repository.dart';
import '../../features/quran/domain/usecases/check_memorization_answer.dart';
import '../../features/quran/domain/usecases/clear_memorization_test_history.dart';
import '../../features/quran/domain/usecases/generate_memorization_questions.dart';
import '../../features/quran/domain/usecases/get_all_local_ayahs.dart';
import '../../features/quran/domain/usecases/get_all_reciters.dart';
import '../../features/quran/domain/usecases/get_all_surahs.dart';
import '../../features/quran/domain/usecases/get_memorization_test_history.dart';
import '../../features/quran/domain/usecases/get_random_ayah.dart';
import '../../features/quran/domain/usecases/get_surah_ayahs.dart';
import '../../features/quran/domain/usecases/save_memorization_test_result.dart';
import '../../features/quran/domain/usecases/start_memorization_test.dart';
import '../../features/quran/domain/usecases/submit_memorization_answer.dart';
import '../../features/quran/presentation/cubit/memorization_test_cubit.dart';
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

final sl = GetIt.instance;

Future<void> initDependencies() async {
  final memorizationTestsBox =
      Hive.isBoxOpen(StorageConstants.memorizationTestsBox)
      ? Hive.box<dynamic>(StorageConstants.memorizationTestsBox)
      : await Hive.openBox<dynamic>(StorageConstants.memorizationTestsBox);

  // ==================== Hadith ====================

  sl.registerLazySingleton<HadithRemoteDataSource>(
    () => HadithRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<HadithLocalDataSource>(
    () => HadithLocalDataSourceImpl(
      settingsBox: Hive.box(StorageConstants.settingsBox),
    ),
  );

  sl.registerLazySingleton<HadithRepository>(
    () => HadithRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
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

  // ==================== Prophets Stories ====================

  sl.registerLazySingleton<ProphetsStoriesRemoteDataSource>(
    () => ProphetsStoriesRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<ProphetsStoriesRepository>(
    () => ProphetsStoriesRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton(() => GetProphetStorySections(sl()));
  sl.registerLazySingleton(() => GetProphetStoryContent(sl()));

  sl.registerFactory(
    () => ProphetsStoriesCubit(getStorySections: sl(), getStoryContent: sl()),
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

  sl.registerLazySingleton<QuranAudioDataSource>(() => QuranAudioDataSource());

  sl.registerFactory(
    () => QuranCubit(
      getRandomAyah: sl(),
      getAllSurahs: sl(),
      getSurahAyahs: sl(),
      getAllReciters: sl(),
      audioDataSource: sl(),
    ),
  );

  // ==================== Quran Local Data ====================

  sl.registerLazySingleton<QuranLocalDataSource>(() => QuranLocalDataSource());

  sl.registerLazySingleton<QuranLocalRepository>(
    () => QuranLocalRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton(() => GetAllLocalAyahs(sl()));

  // ==================== Memorization Test ====================

  sl.registerLazySingleton<MemorizationTestLocalDataSource>(
    () => MemorizationTestLocalDataSourceImpl(box: memorizationTestsBox),
  );

  sl.registerLazySingleton<MemorizationTestRepository>(
    () => MemorizationTestRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton(() => SaveMemorizationTestResult(sl()));

  sl.registerLazySingleton(() => GetMemorizationTestHistory(sl()));

  sl.registerLazySingleton(() => ClearMemorizationTestHistory(sl()));

  sl.registerLazySingleton<MemorizationQuestionGeneratorRepository>(
    () => MemorizationQuestionGeneratorRepositoryImpl(getAllLocalAyahs: sl()),
  );

  sl.registerLazySingleton(() => GenerateMemorizationQuestions(sl()));

  sl.registerLazySingleton(() => CheckMemorizationAnswer());

  sl.registerLazySingleton(() => SubmitMemorizationAnswer(sl()));

  sl.registerLazySingleton(() => StartMemorizationTest(sl()));

  sl.registerFactory(
    () => MemorizationTestCubit(
      startMemorizationTest: sl(),
      submitMemorizationAnswer: sl(),
      saveMemorizationTestResult: sl(),
      getAllSurahs: sl(),
    ),
  );

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

  // ==================== Audio Library ====================

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

  // ==================== Audio Preview ====================

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

  // ==================== Written Dua ====================

  final duaFavoritesBox = Hive.isBoxOpen('dua_favorites')
      ? Hive.box<dynamic>('dua_favorites')
      : await Hive.openBox<dynamic>('dua_favorites');

  sl.registerLazySingleton<WrittenDuaLocalDataSource>(
    () => WrittenDuaLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<WrittenDuaRepository>(
    () => WrittenDuaRepositoryImpl(
      localDataSource: sl(),
      favoritesBox: duaFavoritesBox,
    ),
  );

  sl.registerLazySingleton(() => GetDuaCategories(sl()));
  sl.registerLazySingleton(() => GetAllDuas(sl()));
  sl.registerLazySingleton(() => GetDuasByCategory(sl()));
  sl.registerLazySingleton(() => SearchDuas(sl()));
  sl.registerLazySingleton(() => GetFavoriteDuaIds(sl()));
  sl.registerLazySingleton(() => ToggleDuaFavorite(sl()));

  sl.registerFactory(
    () => WrittenDuaCubit(
      getDuaCategories: sl(),
      getAllDuas: sl(),
      getDuasByCategory: sl(),
      searchDuas: sl(),
      getFavoriteDuaIds: sl(),
      toggleDuaFavorite: sl(),
    ),
  );
}
