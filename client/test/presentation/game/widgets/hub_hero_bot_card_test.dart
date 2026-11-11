import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/presentation/game/widgets/hub_hero_bot_card.dart';

void main() {
  group('HubHeroBotCard Widget Tests', () {
    testWidgets('renders default title, crest, and responds to tap',
        (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HubHeroBotCard(
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('PLAY WITH BOT'), findsOneWidget);
      expect(find.byIcon(Icons.psychology_rounded), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);

      await tester.tap(find.byType(HubHeroBotCard));
      await tester.pump(const Duration(milliseconds: 100));

      expect(tapped, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders custom title and icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HubHeroBotCard(
              title: 'VS BOT',
              icon: Icons.memory_rounded,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('VS BOT'), findsOneWidget);
      expect(find.byIcon(Icons.memory_rounded), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
    });
  });
}
