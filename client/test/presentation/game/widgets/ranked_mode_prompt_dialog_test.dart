import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/domain/models/ai_difficulty.dart';
import 'package:client/presentation/game/widgets/ranked_mode_prompt_dialog.dart';

void main() {
  group('RankedModePromptDialog Widget Tests', () {
    testWidgets('renders dialog with bot info and rewards', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RankedModePromptDialog(
              difficulty: AiDifficulty.hard,
              botName: 'Tactician Bot',
              isOnline: true,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Select Match Mode'), findsOneWidget);
      expect(
        find.text(
          'Challenge Tactician Bot in Ranked mode to earn Blast Points, or play Casual Practice.',
        ),
        findsOneWidget,
      );
      expect(find.text('Ranked Match'), findsOneWidget);
      expect(find.text('Casual Practice'), findsOneWidget);
      expect(find.text('+10 BP'), findsOneWidget);
      expect(find.text('CANCEL'), findsOneWidget);
    });

    testWidgets('tapping Casual Practice returns false', (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    result = await showDialog<bool>(
                      context: context,
                      builder: (_) => const RankedModePromptDialog(
                        difficulty: AiDifficulty.hard,
                        botName: 'Tactician Bot',
                        isOnline: true,
                      ),
                    );
                  },
                  child: const Text('Open'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Casual Practice'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });

    testWidgets('tapping Ranked Match when online returns true',
        (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    result = await showDialog<bool>(
                      context: context,
                      builder: (_) => const RankedModePromptDialog(
                        difficulty: AiDifficulty.expert,
                        botName: 'Grandmaster Bot',
                        isOnline: true,
                      ),
                    );
                  },
                  child: const Text('Open'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('+20 BP'), findsOneWidget);

      await tester.tap(find.text('Ranked Match'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });

    testWidgets('tapping CANCEL button dismisses dialog with null',
        (tester) async {
      bool? result = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    result = await showDialog<bool>(
                      context: context,
                      builder: (_) => const RankedModePromptDialog(
                        difficulty: AiDifficulty.hard,
                        botName: 'Tactician Bot',
                        isOnline: true,
                      ),
                    );
                  },
                  child: const Text('Open'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });
  });
}

