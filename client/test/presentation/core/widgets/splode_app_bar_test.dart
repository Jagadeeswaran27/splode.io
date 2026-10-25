import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:client/presentation/core/widgets/splode_app_bar.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('SplodeAppBar Widget Tests', () {
    testWidgets('renders title in uppercase with correct styles',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: SplodeAppBar(title: 'Training'),
          ),
        ),
      );

      final textFinder = find.text('TRAINING');
      expect(textFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.color, Colors.white);
      expect(textWidget.style?.fontWeight, FontWeight.w900);
      expect(textWidget.style?.letterSpacing, 4);
      expect(textWidget.style?.fontSize, 14);
    });

    testWidgets('renders back button and responds to onBack', (tester) async {
      bool backTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: SplodeAppBar(
              title: 'Select Opponent',
              onBack: () => backTapped = true,
            ),
          ),
        ),
      );

      final backButtonFinder = find.byIcon(Icons.arrow_back);
      expect(backButtonFinder, findsOneWidget);

      await tester.tap(backButtonFinder);
      expect(backTapped, isTrue);
    });

    testWidgets('hides leading widget when showLeading is false',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: SplodeAppBar(
              title: 'Menu',
              showLeading: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('renders actions when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: SplodeAppBar(
              title: 'Profile',
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('applies custom backgroundColor and borderColor',
        (tester) async {
      const customBg = Color(0xFF111111);
      const customBorder = Colors.white;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: SplodeAppBar(
              title: 'Training',
              backgroundColor: customBg,
              borderColor: customBorder,
            ),
          ),
        ),
      );

      final appBarFinder = find.byType(AppBar);
      expect(appBarFinder, findsOneWidget);

      final appBarWidget = tester.widget<AppBar>(appBarFinder);
      expect(appBarWidget.backgroundColor, customBg);
      expect(appBarWidget.shape, isA<Border>());
    });
  });
}
