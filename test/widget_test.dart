import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zad/features/splash/presentation/widgets/splash_content.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Splash screen displays the app branding', (tester) async {
    const fade = AlwaysStoppedAnimation<double>(1);
    const scale = AlwaysStoppedAnimation<double>(1);
    const slide = AlwaysStoppedAnimation<Offset>(Offset.zero);
    const pulse = AlwaysStoppedAnimation<double>(0);

    await tester.pumpWidget(
      const MaterialApp(
        home: SplashContent(
          logoFade: fade,
          logoScale: scale,
          contentFade: fade,
          contentSlide: slide,
          pulseController: pulse,
          paperColor: Color(0xFFF7F1DF),
          innerPaperColor: Color(0xFFFFFCF4),
          goldColor: Color(0xFFA88746),
          lightGoldColor: Color(0xFFD6BE83),
          textColor: Color(0xFF493A25),
          mutedColor: Color(0xFF786548),
        ),
      ),
    );

    expect(find.text('زاد'), findsOneWidget);
    expect(find.text('جاري تجهيز زاد...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  for (final size in [
    const Size(320, 240),
    const Size(360, 640),
    const Size(844, 390),
    const Size(768, 1024),
    const Size(1024, 768),
  ]) {
    testWidgets('Splash layout fits ${size.width}x${size.height}', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const fade = AlwaysStoppedAnimation<double>(1);
      const scale = AlwaysStoppedAnimation<double>(1);
      const slide = AlwaysStoppedAnimation<Offset>(Offset.zero);
      const pulse = AlwaysStoppedAnimation<double>(0);

      await tester.pumpWidget(
        const MaterialApp(
          home: SplashContent(
            logoFade: fade,
            logoScale: scale,
            contentFade: fade,
            contentSlide: slide,
            pulseController: pulse,
            paperColor: Color(0xFFF7F1DF),
            innerPaperColor: Color(0xFFFFFCF4),
            goldColor: Color(0xFFA88746),
            lightGoldColor: Color(0xFFD6BE83),
            textColor: Color(0xFF493A25),
            mutedColor: Color(0xFF786548),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('زاد'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  }
}
