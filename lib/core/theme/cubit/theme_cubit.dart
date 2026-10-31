import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../constants/storage_constants.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  static const String _boxName = StorageConstants.settingsBox;
  static const String _themeKey = 'isDarkMode';

  ThemeCubit() : super(const ThemeState()) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final box = await Hive.openBox(_boxName);

    final isDarkMode = box.get(
      _themeKey,
      defaultValue: false,
    ) as bool;

    emit(
      ThemeState(
        themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      ),
    );
  }

  Future<void> toggleTheme() async {
    final isDarkMode = state.themeMode != ThemeMode.dark;

    final box = await Hive.openBox(_boxName);

    await box.put(_themeKey, isDarkMode);

    emit(
      ThemeState(
        themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      ),
    );
  }
}