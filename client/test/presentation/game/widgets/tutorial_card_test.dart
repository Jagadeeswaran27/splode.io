import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/presentation/game/widgets/module_art_badge.dart';
import 'package:client/presentation/game/widgets/tutorial_card.dart';
import 'package:client/presentation/game/widgets/tutorial_card_footer.dart';
import 'package:client/presentation/game/widgets/tutorial_card_header.dart';

void main() {
  group('TutorialCard Widget Tests', () {
    testWidgets('renders all metadata, headers, badge, and footer when unlocked',
        (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TutorialCard(
              moduleId: 'edges_and_corners',
              moduleNumber: '04',
              category: 'Strategy',
              stepCount: 6,
              title: 'Edges and Corners',
              description: 'Command the high ground.',
              isUnlocked: true,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      // Verify Header
      expect(find.byType(TutorialCardHeader), findsOneWidget);
      expect(find.text('MODULE 04'), findsOneWidget);
      expect(find.text('STRATEGY'), findsOneWidget);
      expect(find.text('6 STEPS'), findsOneWidget);

      // Verify Content
      expect(find.text('Edges and Corners'), findsOneWidget);
      expect(find.text('Command the high ground.'), findsOneWidget);
      expect(find.byType(ModuleArtBadge), findsOneWidget);

      // Verify Footer
      expect(find.byType(TutorialCardFooter), findsOneWidget);
      expect(find.text('INTERACTIVE SIMULATION'), findsOneWidget);
      expect(find.text('START'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);

      // Tap card
      await tester.tap(find.byType(TutorialCard));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('renders locked status and disables interaction when locked',
        (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TutorialCard(
              moduleId: 'chain_reactions',
              moduleNumber: '03',
              category: 'Mastery',
              stepCount: 7,
              title: 'Chain Reactions',
              description: 'Master the domino effect.',
              isUnlocked: false,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      // Verify locked footer elements
      expect(find.text('LOCKED MODULE'), findsOneWidget);
      expect(find.text('LOCKED'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);

      // Verify tap on locked card does not invoke callback
      await tester.tap(find.byType(TutorialCard));
      await tester.pumpAndSettle();
      expect(tapped, isFalse);
    });

    testWidgets('renders without overflow on narrow width screens',
        (tester) async {
      // Set small physical screen size (e.g. 320x568)
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TutorialCard(
                moduleId: 'edges_and_corners',
                moduleNumber: '04',
                category: 'Strategy',
                stepCount: 6,
                title: 'Edges and Corners',
                description: 'Command the high ground.',
                isUnlocked: true,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
