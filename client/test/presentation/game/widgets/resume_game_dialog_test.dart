import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/presentation/game/widgets/resume_game_dialog.dart';

void main() {
  group('ResumeGameDialog Widget Tests', () {
    testWidgets('renders title, content and buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResumeGameDialog(),
          ),
        ),
      );

      expect(find.text('Resume Game?'), findsOneWidget);
      expect(
        find.text(
          'You have an unfinished game in progress. Would you like to resume it?',
        ),
        findsOneWidget,
      );
      expect(find.text('New Game'), findsOneWidget);
      expect(find.text('Resume'), findsOneWidget);
    });

    testWidgets('show static helper pops with result', (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await ResumeGameDialog.show(context);
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(ResumeGameDialog), findsOneWidget);

      await tester.tap(find.text('Resume'));
      await tester.pumpAndSettle();

      expect(find.byType(ResumeGameDialog), findsNothing);
      expect(result, isTrue);
    });
  });
}

