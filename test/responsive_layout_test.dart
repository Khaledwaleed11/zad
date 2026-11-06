import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zad/core/utils/responsive.dart';
import 'package:zad/features/qibla/presentation/widgets/qibla_compass.dart';

void main() {
  for (final width in [320.0, 360.0, 600.0, 1024.0]) {
    testWidgets('Qibla compass fits a $width px viewport', (tester) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveBody(
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  key: const ValueKey('viewport-padding'),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: QiblaCompass(rotation: 0),
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      final contentWidth = width < 760 ? width : 760.0;
      expect(
        tester.getSize(find.byKey(const ValueKey('viewport-padding'))).width,
        contentWidth,
      );
      expect(
        tester.getSize(find.byType(QiblaCompass)).width,
        lessThanOrEqualTo(contentWidth - 36),
      );
    });
  }
}
