import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:client/presentation/auth/providers/auth_provider.dart';
import 'package:client/presentation/auth/providers/profile_provider.dart';
import 'package:client/presentation/auth/screens/auth_screen.dart';
import 'package:client/presentation/core/providers/connectivity_provider.dart';
import 'package:client/presentation/game/providers/bot_history_provider.dart';
import 'package:client/presentation/game/screens/ai_difficulty_selection_screen.dart';
import 'package:client/presentation/game/screens/layout_selection_screen.dart';
import 'package:client/presentation/game/screens/local_match_screen.dart';
import 'package:client/presentation/game/screens/offline_match_setup_screen.dart';
import 'package:client/presentation/game/screens/profile_screen.dart';
import 'package:client/presentation/game/screens/tutorial_list_screen.dart';
import 'package:client/presentation/game/screens/tutorial_screen.dart';

List<Override> _testOverrides() => [
      connectivityProvider.overrideWith((ref) => Stream.value(true)),
      currentUserProvider.overrideWithValue(null),
      userProfileProvider.overrideWith((ref) => Future.value(null)),
      botMatchHistoryProvider.overrideWith((ref) => Future.value([])),
    ];

void main() {
  group('Multi-Device Responsive Screen Tests (8 Screens x 5 Viewports)', () {
    const viewports = <String, Size>{
      'Compact Mobile (iPhone SE)': Size(320, 568),
      'Standard Mobile (iPhone 14)': Size(390, 844),
      'Landscape Mobile (Short Screen)': Size(800, 380),
      'Tablet Portrait (iPad Mini)': Size(768, 1024),
      'Desktop / Tablet Landscape': Size(1280, 800),
    };

    for (final entry in viewports.entries) {
      final name = entry.key;
      final size = entry.value;

      testWidgets('AuthScreen renders without overflow on $name',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          ProviderScope(
            overrides: _testOverrides(),
            child: const MaterialApp(
              home: AuthScreen(),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      });

      testWidgets('LayoutSelectionScreen renders without overflow on $name',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          ProviderScope(
            overrides: _testOverrides(),
            child: const MaterialApp(
              home: LayoutSelectionScreen(),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      });

      testWidgets('TutorialListScreen renders without overflow on $name',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          ProviderScope(
            overrides: _testOverrides(),
            child: const MaterialApp(
              home: TutorialListScreen(),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      });

      testWidgets('OfflineMatchSetupScreen renders without overflow on $name',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          ProviderScope(
            overrides: _testOverrides(),
            child: const MaterialApp(
              home: OfflineMatchSetupScreen(),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      });

      testWidgets(
          'AiDifficultySelectionScreen renders without overflow on $name',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          ProviderScope(
            overrides: _testOverrides(),
            child: const MaterialApp(
              home: AiDifficultySelectionScreen(),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);

        // Test swipe to Hard and Expert to verify ranked toggle and BP badge without overflow
        final pageView = find.byType(PageView);
        if (pageView.evaluate().isNotEmpty) {
          await tester.drag(pageView, const Offset(-300, 0));
          await tester.pump(const Duration(milliseconds: 400));
          expect(tester.takeException(), isNull);

          await tester.drag(pageView, const Offset(-300, 0));
          await tester.pump(const Duration(milliseconds: 400));
          expect(tester.takeException(), isNull);

          await tester.drag(pageView, const Offset(-300, 0));
          await tester.pump(const Duration(milliseconds: 400));
          expect(tester.takeException(), isNull);
        }
      });

      testWidgets('ProfileScreen renders without overflow on $name',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          ProviderScope(
            overrides: _testOverrides(),
            child: const MaterialApp(
              home: ProfileScreen(),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      });

      testWidgets('TutorialScreen renders without overflow on $name',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          ProviderScope(
            overrides: _testOverrides(),
            child: const MaterialApp(
              home: TutorialScreen(),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      });

      testWidgets('LocalMatchScreen renders without overflow on $name',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          ProviderScope(
            overrides: _testOverrides(),
            child: const MaterialApp(
              home: LocalMatchScreen(),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      });
    }
  });
}
