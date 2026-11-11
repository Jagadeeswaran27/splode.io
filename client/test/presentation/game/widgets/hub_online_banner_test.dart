import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/presentation/game/widgets/hub_online_banner.dart';

void main() {
  group('HubOnlineBanner Widget Tests', () {
    testWidgets('renders title, soon badge, and responds to tap',
        (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HubOnlineBanner(
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('ONLINE MULTIPLAYER'), findsOneWidget);
      expect(find.text('SOON'), findsOneWidget);
      expect(find.byIcon(Icons.public_rounded), findsOneWidget);

      await tester.tap(find.byType(HubOnlineBanner));
      await tester.pump(const Duration(milliseconds: 100));

      expect(tapped, isTrue);
      expect(tester.takeException(), isNull);
    });
  });
}
