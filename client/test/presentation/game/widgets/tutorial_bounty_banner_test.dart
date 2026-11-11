import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/presentation/game/widgets/tutorial_bounty_banner.dart';

void main() {
  group('TutorialBountyBanner Widget Tests', () {
    testWidgets('renders bounty title and in-progress state correctly',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TutorialBountyBanner(
              earnedBp: 20,
              totalBp: 50,
            ),
          ),
        ),
      );

      expect(find.text('ACADEMY BOUNTY'), findsOneWidget);
      expect(find.text('+50 BP'), findsOneWidget);
      expect(
        find.text('20 of 50 BP earned • Complete modules to claim'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.emoji_events_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders all-claimed state when full 50 BP is earned',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TutorialBountyBanner(
              earnedBp: 50,
              totalBp: 50,
            ),
          ),
        ),
      );

      expect(find.text('ACADEMY BOUNTY'), findsOneWidget);
      expect(find.text('✓ 50 BP'), findsOneWidget);
      expect(
        find.text('Academy Mastered • All 50 BP claimed!'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

