import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jagain/app.dart';
import 'package:jagain/features/home/home_page.dart';
import 'package:jagain/features/splash/splash_page.dart';

void main() {
  group('Splash Screen & Home Header Tests', () {
    testWidgets('SplashPage displays logo without text, welcome message, and tagline', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: SplashPage()),
        ),
      );

      // Verify Welcome greeting
      expect(find.text('Selamat Datang di'), findsOneWidget);

      // Verify app title & taglines
      expect(find.text('JAGAIN'), findsOneWidget);
      expect(find.text('Jaga yang Berarti'), findsOneWidget);
      expect(find.text('Jangan cuma punya, JAGAIN.'), findsOneWidget);

      // Verify textless logo asset
      final imageFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/icons/vaficon_hijau.png',
      );
      expect(imageFinder, findsOneWidget);
    });

    testWidgets('HomePage top bar displays horizontal logo and no separate JAGAIN text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: HomePage())),
        ),
      );

      // Check horizontal logo exists
      final horizontalLogoFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            ((widget.image as AssetImage).assetName ==
                    'assets/icons/horizontal_logo.png' ||
                (widget.image as AssetImage).assetName ==
                    'assets/icons/horizontal_logo_dark.png'),
      );
      expect(horizontalLogoFinder, findsOneWidget);

      // Verify there is NO stand-alone header text 'JAGAIN' in HomePage
      expect(find.text('JAGAIN'), findsNothing);
    });

    testWidgets('Tapping SplashPage navigates smoothly to MainShell', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: JagainApp()),
      );

      expect(find.byType(SplashPage), findsOneWidget);

      // Tap on screen to skip splash
      await tester.tap(find.byType(SplashPage));
      await tester.pumpAndSettle();

      expect(find.byType(MainShell), findsOneWidget);
      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}
