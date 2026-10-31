import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'core/constants/storage_constants.dart';
import 'core/dependency_injection/injection_container.dart';
import 'features/notifications/data/datasources/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await Hive.openBox(StorageConstants.sebhaBox);
  await Hive.openBox(StorageConstants.settingsBox);
  await Hive.openBox(StorageConstants.audioLibraryBox);
  await Hive.openBox(StorageConstants.customAzkarBox);

  await NotificationService.initialize();
  await initDependencies();

  runApp(const ZadApp());

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await NotificationService.testAzkarNotification();
  });
}