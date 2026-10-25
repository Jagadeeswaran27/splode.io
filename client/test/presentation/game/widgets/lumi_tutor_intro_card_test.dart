import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/presentation/game/widgets/lumi_tutor_intro_card.dart';

void main() {
  group('LumiTutorIntroCard Widget Tests', () {
    testWidgets(
        'plays intro once on mount and preserves completed state when scrolled down and up',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                const LumiTutorIntroCard(),
                const SizedBox(height: 500),
                const Text('Bottom Marker'),
              ],
            ),
          ),
        ),
      );

      // Finish flight animation (1200ms)
      await tester.pump(const Duration(milliseconds: 1300));
      // Trigger .then callback to start typing animation
      await tester.pump();
      // Finish typing animation (1400ms)
      await tester.pump(const Duration(milliseconds: 1500));

      // Verify full dialogue text is visible in RichText
      expect(
        find.textContaining("I'm your guide through Splode", findRichText: true),
        findsOneWidget,
      );

      // Scroll down so LumiTutorIntroCard is completely offscreen
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pump(const Duration(milliseconds: 300));

      // Verify bottom marker is visible
      expect(find.text('Bottom Marker'), findsOneWidget);

      // Scroll back up to the top
      await tester.drag(find.byType(ListView), const Offset(0, 600));
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Lumi's full dialogue is still displayed immediately without restarting typing
      expect(
        find.textContaining("I'm your guide through Splode", findRichText: true),
        findsOneWidget,
      );

      // Verify no exceptions were thrown
      expect(tester.takeException(), isNull);
    });
  });
}
