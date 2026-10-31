import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/storage_constants.dart';
abstract class AdhanVoicesLocalDataSource {
  Future<void> saveSelectedVoiceId(String voiceId);

  String? getSelectedVoiceId();
}

class AdhanVoicesLocalDataSourceImpl
    implements AdhanVoicesLocalDataSource {
  static const String _boxName = StorageConstants.settingsBox;
  static const String _selectedVoiceKey = 'selected_adhan_voice_id';

  Box get _box => Hive.box(_boxName);

  @override
  Future<void> saveSelectedVoiceId(String voiceId) async {
    await _box.put(_selectedVoiceKey, voiceId);
  }

  @override
  String? getSelectedVoiceId() {
    return _box.get(_selectedVoiceKey) as String?;
  }
}
