import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/presentation/game/widgets/hub_secondary_mode_tile.dart';

void main() {
  group('HubSecondaryModeTile Widget Tests', () {
    testWidgets('renders title, icon, and responds to tap', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HubSecondaryModeTile(
              icon: Icons.people_alt_rounded,
              title: 'PASS & PLAY',
              accentColor: Colors.white,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('PASS & PLAY'), findsOneWidget);
      expect(find.byIcon(Icons.people_alt_rounded), findsOneWidget);

      await tester.tap(find.byType(HubSecondaryModeTile));
      await tester.pump(const Duration(milliseconds: 100));

      expect(tapped, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders optional badge and subtitle when provided',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HubSecondaryModeTile(
              icon: Icons.school_rounded,
              badge: '+50 BP',
              title: 'ACADEMY',
              subtitle: 'Tactical drills',
              accentColor: const Color(0xFFD4A44C),
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('ACADEMY'), findsOneWidget);
      expect(find.text('+50 BP'), findsOneWidget);
      expect(find.text('Tactical drills'), findsOneWidget);
      expect(find.byIcon(Icons.school_rounded), findsOneWidget);
    });
  });
}
