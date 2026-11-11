import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/presentation/game/widgets/mascot_widget.dart';

void main() {
  group('LumiMascot Widget Tests', () {
    testWidgets('renders headline, message, step indicator, and orb',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 120,
              child: LumiMascot(
                headline: 'Strike first from the corner!',
                message:
                    'Corners explode at only 2 orbs. Detonate before their adjacent edge reaches critical mass.',
                stepIndex: 0,
                totalSteps: 6,
              ),
            ),
          ),
        ),
      );

      // Verify headline and message render
      expect(find.text('Strike first from the corner!'), findsOneWidget);
      expect(
        find.textContaining('Corners explode at only 2 orbs.'),
        findsOneWidget,
      );

      // Verify meta header
      expect(find.text('LUMI'), findsOneWidget);
      expect(find.text('STEP 1 OF 6'), findsOneWidget);

      // Verify no overflow exception occurred
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders continue button and responds to onNextPressed',
        (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 140,
              child: LumiMascot(
                headline: 'VICTORY!',
                message: 'You have mastered the perimeter sweep.',
                stepIndex: 5,
                totalSteps: 6,
                nextButtonLabel: 'CLAIM VICTORY',
                onNextPressed: () {
                  pressed = true;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('CLAIM VICTORY'), findsOneWidget);
      await tester.tap(find.text('CLAIM VICTORY'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(pressed, isTrue);
    });

    testWidgets(
        'renders without overflow on narrow viewport with high text scaling and long message',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              textScaler: TextScaler.linear(1.3),
            ),
            child: const Scaffold(
              body: SizedBox(
                height: 120,
                child: LumiMascot(
                  headline: 'Unleash the perimeter wave!',
                  message:
                      'Detonate your corner to trigger a massive cascade and sweep their defenses from behind.',
                  stepIndex: 5,
                  totalSteps: 6,
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
