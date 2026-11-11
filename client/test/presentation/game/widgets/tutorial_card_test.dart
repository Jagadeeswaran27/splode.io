import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/domain/models/tutorial_module.dart';
import 'package:client/presentation/core/widgets/auth_button.dart';
import 'package:client/presentation/game/widgets/module_art_badge.dart';
import 'package:client/presentation/game/widgets/tutorial_card.dart';

void main() {
  group('TutorialCard Widget Tests', () {
    testWidgets(
        'initially hides description; expands on tap to show description and AuthButton',
        (tester) async {
      var started = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TutorialCard(
              module: TutorialModule.edgesAndCorners,
              description: 'Command the high ground.',
              isUnlocked: true,
              onStart: () {
                started = true;
              },
            ),
          ),
        ),
      );

      // Verify collapsed state: Metadata & title visible, description & start button hidden
      expect(find.text('MODULE 04'), findsOneWidget);
      expect(find.text('6 STEPS'), findsOneWidget);
      expect(find.text('Edges and Corners'), findsOneWidget);
      expect(find.byType(ModuleArtBadge), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
      expect(find.text('Command the high ground.'), findsNothing);
      expect(find.byType(AuthButton), findsNothing);

      // Tap card to expand
      await tester.tap(find.byType(TutorialCard));
      await tester.pumpAndSettle();

      // Description and start button are now visible
      expect(find.text('Command the high ground.'), findsOneWidget);
      expect(find.byType(AuthButton), findsOneWidget);
      expect(find.text('Start Module'), findsOneWidget);
      expect(started, isFalse);

      // Tap AuthButton (Start Module)
      await tester.tap(find.byType(AuthButton));
      await tester.pumpAndSettle();
      expect(started, isTrue);

      // Tap header again to collapse
      await tester.tap(find.text('Edges and Corners'));
      await tester.pumpAndSettle();
      expect(find.text('Command the high ground.'), findsNothing);
      expect(find.byType(AuthButton), findsNothing);
    });

    testWidgets(
        'renders locked card, expands on tap to show description and locked requirement banner',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TutorialCard(
              module: TutorialModule.chainReactions,
              description: 'Master the domino effect.',
              isUnlocked: false,
              onStart: () {},
            ),
          ),
        ),
      );

      // Verify collapsed locked icon
      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
      expect(find.text('Master the domino effect.'), findsNothing);
      expect(find.byType(AuthButton), findsNothing);

      // Tap locked card to expand
      await tester.tap(find.byType(TutorialCard));
      await tester.pumpAndSettle();

      // Shows description and locked requirement, but NO start button
      expect(find.text('Master the domino effect.'), findsOneWidget);
      expect(
        find.textContaining('LOCKED • COMPLETE CAPTURING FIRST'),
        findsOneWidget,
      );
      expect(find.byType(AuthButton), findsNothing);
    });

    testWidgets('controlled expansion via isExpanded and onExpansionChanged',
        (tester) async {
      var expansionToggled = false;
      bool? newExpansionState;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TutorialCard(
              module: TutorialModule.basics,
              isUnlocked: true,
              isExpanded: true,
              onExpansionChanged: (val) {
                expansionToggled = true;
                newExpansionState = val;
              },
              onStart: () {},
            ),
          ),
        ),
      );

      // Since isExpanded is true, description is immediately visible
      expect(find.text(TutorialModule.basics.description), findsOneWidget);
      expect(find.byType(AuthButton), findsOneWidget);
      expect(find.text('Start Module'), findsOneWidget);

      // Tap card
      await tester.tap(find.text('The Basics'));
      await tester.pumpAndSettle();
      expect(expansionToggled, isTrue);
      expect(newExpansionState, isFalse);
    });

    testWidgets('renders without overflow on narrow width screens',
        (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TutorialCard(
                      module: TutorialModule.edgesAndCorners,
                      description: 'Command the high ground.',
                      isUnlocked: true,
                      isExpanded: true,
                      onStart: () {},
                    ),
                    const SizedBox(height: 12),
                    TutorialCard(
                      module: TutorialModule.chainReactions,
                      description: 'Master the domino effect.',
                      isUnlocked: false,
                      isExpanded: true,
                      onStart: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders completed badge and replay CTA when module is completed',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TutorialCard(
              module: TutorialModule.basics,
              isUnlocked: true,
              isCompleted: true,
              isExpanded: true,
              onStart: () {},
            ),
          ),
        ),
      );

      // Verify completed pill and replay button
      expect(find.text('✓ 10 BP'), findsOneWidget);
      expect(find.text('Replay Module'), findsOneWidget);
      expect(find.byIcon(Icons.replay_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
