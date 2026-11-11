import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:client/domain/models/tutorial_module.dart';
import 'package:client/presentation/auth/providers/auth_provider.dart';
import 'package:client/presentation/game/providers/tutorial_progress_provider.dart';
import 'package:client/presentation/game/services/tutorial_progress_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TutorialProgressNotifier Tests with TutorialModule Enum', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initially only basics is unlocked and others are locked', () async {
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(null),
          tutorialProgressServiceProvider.overrideWithValue(
            TutorialProgressService(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(tutorialProgressProvider.notifier);

      expect(notifier.isUnlocked(TutorialModule.basics), isTrue);
      expect(notifier.isUnlocked(TutorialModule.capturing), isFalse);
      expect(notifier.isUnlocked(TutorialModule.chainReactions), isFalse);
      expect(notifier.isUnlocked(TutorialModule.edgesAndCorners), isFalse);

      expect(notifier.isCompleted(TutorialModule.basics), isFalse);
    });

    test('completing basics unlocks capturing', () async {
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(null),
          tutorialProgressServiceProvider.overrideWithValue(
            TutorialProgressService(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(tutorialProgressProvider.notifier);

      await notifier.completeModule(TutorialModule.basics);

      expect(notifier.isCompleted(TutorialModule.basics), isTrue);
      expect(notifier.isUnlocked(TutorialModule.capturing), isTrue);
      expect(notifier.isUnlocked(TutorialModule.chainReactions), isFalse);
      expect(notifier.isUnlocked(TutorialModule.edgesAndCorners), isFalse);
    });

    test('sequential progression through all modules using nextModule',
        () async {
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(null),
          tutorialProgressServiceProvider.overrideWithValue(
            TutorialProgressService(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(tutorialProgressProvider.notifier);

      // Verify sequence nextModule chaining
      expect(TutorialModule.basics.nextModule, equals(TutorialModule.capturing));
      expect(
        TutorialModule.capturing.nextModule,
        equals(TutorialModule.chainReactions),
      );
      expect(
        TutorialModule.chainReactions.nextModule,
        equals(TutorialModule.edgesAndCorners),
      );
      expect(TutorialModule.edgesAndCorners.nextModule, isNull);

      // Complete Module 1
      await notifier.completeModule(TutorialModule.basics);
      expect(notifier.isUnlocked(TutorialModule.capturing), isTrue);

      // Complete Module 2
      await notifier.completeModule(TutorialModule.capturing);
      expect(notifier.isUnlocked(TutorialModule.chainReactions), isTrue);

      // Complete Module 3
      await notifier.completeModule(TutorialModule.chainReactions);
      expect(notifier.isUnlocked(TutorialModule.edgesAndCorners), isTrue);

      // Complete Module 4
      await notifier.completeModule(TutorialModule.edgesAndCorners);
      expect(notifier.isCompleted(TutorialModule.edgesAndCorners), isTrue);
    });

    test('persists to SharedPreferences and reloads as TutorialModule',
        () async {
      SharedPreferences.setMockInitialValues({
        'splode_completed_tutorials': ['basics', 'capturing'],
      });

      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(null),
          tutorialProgressServiceProvider.overrideWithValue(
            TutorialProgressService(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(tutorialProgressProvider.notifier);
      // Wait for async _init
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(notifier.isCompleted(TutorialModule.basics), isTrue);
      expect(notifier.isCompleted(TutorialModule.capturing), isTrue);
      expect(notifier.isUnlocked(TutorialModule.chainReactions), isTrue);
      expect(notifier.isUnlocked(TutorialModule.edgesAndCorners), isFalse);
    });

    test(
        're-completing an already completed module is an idempotent no-op (no state or storage change)',
        () async {
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(null),
          tutorialProgressServiceProvider.overrideWithValue(
            TutorialProgressService(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(tutorialProgressProvider.notifier);
      await notifier.completeModule(TutorialModule.basics);
      expect(notifier.isCompleted(TutorialModule.basics), isTrue);

      final stateBefore = container.read(tutorialProgressProvider);

      // Attempt to re-complete the same module
      await notifier.completeModule(TutorialModule.basics);

      final stateAfter = container.read(tutorialProgressProvider);
      // State reference is completely untouched
      expect(identical(stateBefore, stateAfter), isTrue);
    });

    test('verifies BP reward distribution totals exactly 50 BP across modules',
        () {
      expect(TutorialModule.basics.bpReward, equals(10));
      expect(TutorialModule.capturing.bpReward, equals(10));
      expect(TutorialModule.chainReactions.bpReward, equals(15));
      expect(TutorialModule.edgesAndCorners.bpReward, equals(15));
      expect(TutorialModule.totalBounty, equals(50));
    });

    test(
        'new users start with 0 completed modules and do not inherit prior user progress',
        () async {
      final service = TutorialProgressService();

      // Simulate prior user who completed basics and capturing
      await service.saveLocalCompletedModules(
        {TutorialModule.basics, TutorialModule.capturing},
        'old-user-123',
      );

      // New user container
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(null),
          tutorialProgressServiceProvider.overrideWithValue(service),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(tutorialProgressProvider.notifier);

      // Verify new user has 0 completed modules
      expect(notifier.isCompleted(TutorialModule.basics), isFalse);
      expect(notifier.isCompleted(TutorialModule.capturing), isFalse);

      // Verify sequential access: only basics is unlocked
      expect(notifier.isUnlocked(TutorialModule.basics), isTrue);
      expect(notifier.isUnlocked(TutorialModule.capturing), isFalse);
    });
  });
}
