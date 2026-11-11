import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:client/presentation/game/widgets/tutorial_complete_overlay.dart';

void main() {
  group('TutorialCompleteOverlay Widget Tests', () {
    testWidgets(
        'renders without horizontal overflow on narrow mobile (360px) with long module name and high text scaling',
        (tester) async {
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      var nextCalled = false;
      String? nextResult;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                textScaler: TextScaler.linear(1.25),
              ),
              child: Scaffold(
                body: TutorialCompleteOverlay(
                  // 'chain_reactions' completes -> next is 'edges_and_corners' ('NEXT: EDGES AND CORNERS')
                  moduleId: 'chain_reactions',
                  onNext: (nextId) {
                    nextCalled = true;
                    nextResult = nextId;
                  },
                ),
              ),
            ),
          ),
        ),
      );

      // Verify no overflow exception was thrown
      expect(tester.takeException(), isNull);

      // Verify header and button exist
      expect(find.text('TUTORIAL COMPLETE'), findsOneWidget);
      expect(find.textContaining('EDGES AND CORNERS'), findsOneWidget);

      // Verify tap works
      await tester.tap(find.textContaining('EDGES AND CORNERS'));
      await tester.pump();
      expect(nextCalled, isTrue);
      expect(nextResult, 'edges_and_corners');
    });

    testWidgets(
        'renders final module completion without next button and handles finish',
        (tester) async {
      var nextCalled = false;
      String? nextResult = 'initial';

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TutorialCompleteOverlay(
                moduleId: 'edges_and_corners',
                onNext: (nextId) {
                  nextCalled = true;
                  nextResult = nextId;
                },
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('FINISH'), findsOneWidget);

      await tester.tap(find.text('FINISH'));
      await tester.pump();
      expect(nextCalled, isTrue);
      expect(nextResult, isNull);
    });
  });
}

