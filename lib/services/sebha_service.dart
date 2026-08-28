import 'package:hive_flutter/hive_flutter.dart';

class SebhaService {
  static const String boxName = 'sebha';

  static Box get box => Hive.box(boxName);

  static const String countKey = 'count';
  static const String targetKey = 'target';
  static const String zikrKey = 'zikr';

  static int getCount() {
    return box.get(countKey, defaultValue: 0);
  }

  static int getTarget() {
    return box.get(targetKey, defaultValue: 33);
  }

  static String getZikr() {
    return box.get(
      zikrKey,
      defaultValue: 'سبحان الله',
    );
  }

  static Future<void> save({
    required int count,
    required int target,
    required String zikr,
  }) async {
    await box.put(countKey, count);
    await box.put(targetKey, target);
    await box.put(zikrKey, zikr);
  }

  static Future<void> reset() async {
    await box.put(countKey, 0);
  }
}