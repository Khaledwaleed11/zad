import 'dart:convert';
import '../../../../core/constants/assets_constants.dart';
import '../../../../core/constants/storage_constants.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/azkar_model.dart';

abstract class AzkarLocalDataSource {
  Future<List<AzkarModel>> getAzkar();

  List<AzkarModel> getCustomAzkar();

  Future<AzkarModel> addCustomAzkar(AzkarModel azkar);

  Future<void> updateCustomAzkar(AzkarModel azkar);

  Future<void> deleteCustomAzkar(int id);
}

class AzkarLocalDataSourceImpl implements AzkarLocalDataSource {
  static const String _azkarPath = AssetsConstants.azkarJson;
  static const String _boxName = StorageConstants.customAzkarBox;
  Box get _box => Hive.box(_boxName);

  @override
  Future<List<AzkarModel>> getAzkar() async {
    final jsonString = await rootBundle.loadString(_azkarPath);
    final List<dynamic> data = jsonDecode(jsonString);

    return data.map((item) {
      return AzkarModel.fromJson(
        Map<String, dynamic>.from(item),
      );
    }).toList();
  }

  @override
  List<AzkarModel> getCustomAzkar() {
    return _box.values.map((item) {
      return AzkarModel.fromMap(
        Map<dynamic, dynamic>.from(item),
      );
    }).toList();
  }

  @override
  Future<AzkarModel> addCustomAzkar(AzkarModel azkar) async {
    final customId = DateTime.now().microsecondsSinceEpoch % 0xFFFFFFFF;

    final customAzkar = AzkarModel(
      id: customId,
      category: 'custom',
      title: azkar.title,
      text: azkar.text,
      count: azkar.count,
      isCustom: true,
    );

    await _box.put(customAzkar.id, customAzkar.toMap());

    return customAzkar;
  }

  @override
  Future<void> updateCustomAzkar(AzkarModel azkar) async {
    final customAzkar = AzkarModel(
      id: azkar.id,
      category: 'custom',
      title: azkar.title,
      text: azkar.text,
      count: azkar.count,
      isCustom: true,
    );

    await _box.put(customAzkar.id, customAzkar.toMap());
  }

  @override
  Future<void> deleteCustomAzkar(int id) async {
    await _box.delete(id);
  }
}