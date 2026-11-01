
import 'package:flutter/material.dart';

import '../../../azkar/presentation/screens/azkar_screen.dart';
import '../../../prayer_times/presentation/screens/prayer_times_screen.dart';
import '../../../sebha/presentation/screens/sebha_screen.dart';

class NotificationNavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  static String? _pendingPayload;

  static void onNotificationTapped(String? payload) {
    if (payload == null || payload.isEmpty) {
      return;
    }

    if (navigatorKey.currentState == null) {
      _pendingPayload = payload;
      return;
    }

    _openFromPayload(payload);
  }

  static Future<void> handlePendingNotification() async {
    final payload = _pendingPayload;

    if (payload == null || payload.isEmpty) {
      return;
    }

    _pendingPayload = null;

    await Future.delayed(const Duration(milliseconds: 300));

    if (navigatorKey.currentState == null) {
      _pendingPayload = payload;
      return;
    }

    _openFromPayload(payload);
  }

  static void _openFromPayload(String payload) {
    final navigator = navigatorKey.currentState;

    if (navigator == null) {
      _pendingPayload = payload;
      return;
    }

    switch (payload) {
      case 'prayer':
        navigator.push(
          MaterialPageRoute(
            builder: (_) => const PrayerTimesScreen(),
          ),
        );
        break;

      case 'azkar_morning':
        navigator.push(
          MaterialPageRoute(
            builder: (_) => const AzkarScreen(
              initialCategory: 'morning',
            ),
          ),
        );
        break;

      case 'azkar_evening':
        navigator.push(
          MaterialPageRoute(
            builder: (_) => const AzkarScreen(
              initialCategory: 'evening',
            ),
          ),
        );
        break;

      case 'azkar_sleep':
        navigator.push(
          MaterialPageRoute(
            builder: (_) => const AzkarScreen(
              initialCategory: 'sleep',
            ),
          ),
        );
        break;

      case 'salawat':
        navigator.push(
          MaterialPageRoute(
            builder: (_) => const SebhaScreen(),
          ),
        );
        break;
    }
  }
}
