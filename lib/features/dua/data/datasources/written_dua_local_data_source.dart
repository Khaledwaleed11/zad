import 'dart:convert';

import 'package:flutter/services.dart';


import '../models/dua_category_model.dart';
import '../models/written_dua_model.dart';

abstract class WrittenDuaLocalDataSource {
  Future<List<DuaCategoryModel>> getCategories();

  Future<List<WrittenDuaModel>> getAllDuas();

  Future<List<WrittenDuaModel>> getDuasByCategory(String categoryId);

  Future<List<WrittenDuaModel>> searchDuas(String query);
}

class WrittenDuaLocalDataSourceImpl
    implements WrittenDuaLocalDataSource {
  final AssetBundle assetBundle;

  WrittenDuaLocalDataSourceImpl({
    AssetBundle? assetBundle,
  }) : assetBundle = assetBundle ?? rootBundle;

  Map<String, dynamic>? _catalogue;

  Future<Map<String, dynamic>> _loadCatalogue() async {
    if (_catalogue != null) return _catalogue!;

    final jsonString = await assetBundle.loadString(
      'assets/data/duas.json',
    );

    _catalogue = jsonDecode(jsonString) as Map<String, dynamic>;

    return _catalogue!;
  }

  @override
  Future<List<DuaCategoryModel>> getCategories() async {
    final catalogue = await _loadCatalogue();

    final tags = catalogue['tags'] as List<dynamic>? ?? [];

    return tags
        .map(
          (tag) => DuaCategoryModel.fromJson(
        tag as Map<String, dynamic>,
      ),
    )
        .toList();
  }

  @override
  Future<List<WrittenDuaModel>> getAllDuas() async {
    final catalogue = await _loadCatalogue();

    final entries = catalogue['entries'] as List<dynamic>? ?? [];
    final tags = catalogue['tags'] as List<dynamic>? ?? [];

    final categoryNames = {
      for (final tag in tags)
        tag['id'] as String: tag['title'] as String,
    };

    final duas = <WrittenDuaModel>[];
    final addedDuaIds = <String>{};

    for (final entryData in entries) {
      final entry = entryData as Map<String, dynamic>;

      // نستخرج الأدعية الفعلية فقط.
      if (entry['type'] != 'invocation') continue;

      final entryTags = entry['tags'] as List<dynamic>? ?? [];

      if (entryTags.isEmpty) continue;

      final categoryId = entryTags.first as String;
      final categoryName = categoryNames[categoryId];

      if (categoryName == null) continue;

      final variations = entry['variations'] as List<dynamic>? ?? [];

      if (variations.isEmpty) continue;

      // نستخدم أول Variation لتجنب تكرار نفس الدعاء.
      final variation = variations.first as Map<String, dynamic>;

      final steps = variation['steps'] as List<dynamic>? ?? [];

      for (final stepData in steps) {
        final step = stepData as Map<String, dynamic>;

        if (step['type'] != 'recitation') continue;

        final items = step['items'] as List<dynamic>? ?? [];

        for (final itemData in items) {
          final item = itemData as Map<String, dynamic>;

          final dua = item['dua'] as Map<String, dynamic>?;

          if (dua == null) continue;

          final duaId = dua['id'] as String?;

          if (duaId == null || !addedDuaIds.add(duaId)) {
            continue;
          }

          duas.add(
            WrittenDuaModel.fromJson(
              entry: {
                ...entry,
                'tags': [categoryId],
              },
              dua: dua,
              categoryName: categoryName,
              repetitionCount: (item['times'] as num?)?.toInt(),
            ),
          );
        }
      }
    }

    return duas;
  }

  @override
  Future<List<WrittenDuaModel>> getDuasByCategory(
      String categoryId,
      ) async {
    final duas = await getAllDuas();

    return duas
        .where((dua) => dua.categoryId == categoryId)
        .toList();
  }

  @override
  Future<List<WrittenDuaModel>> searchDuas(String query) async {
    final duas = await getAllDuas();

    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) return duas;

    return duas.where((dua) {
      return dua.title.toLowerCase().contains(normalizedQuery) ||
          dua.arabicText.contains(normalizedQuery) ||
          (dua.translation?.toLowerCase().contains(normalizedQuery) ??
              false);
    }).toList();
  }
}