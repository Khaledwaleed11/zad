import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/azkar_model.dart';

class AzkarService {
  static const String _azkarPath = 'assets/azkar/azkar.json';



  Future<List<AzkarModel>> getAzkar() async {
    final String jsonString = await rootBundle.loadString(_azkarPath);

    final List data = jsonDecode(jsonString);

    return data
        .map((item) => AzkarModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }


  Future<List<AzkarModel>> getAzkarByCategory(String category) async {
    final azkar = await getAzkar();

    return azkar.where((zekr) => zekr.category == category).toList();
  }
}
