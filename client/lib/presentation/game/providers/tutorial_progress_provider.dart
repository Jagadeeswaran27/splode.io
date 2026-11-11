import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:client/domain/models/tutorial_module.dart';
import 'package:client/presentation/auth/providers/auth_provider.dart';
import 'package:client/presentation/auth/providers/profile_provider.dart';
import 'package:client/presentation/core/providers/connectivity_provider.dart';
import 'package:client/presentation/game/services/tutorial_progress_service.dart';

/// Notifier managing completed training modules with local & cloud synchronization
/// using strongly typed [TutorialModule] enum.
class TutorialProgressNotifier extends StateNotifier<Set<TutorialModule>> {
  final Ref _ref;
  final TutorialProgressService _service;

  TutorialProgressNotifier(this._ref, this._service)
      : super(<TutorialModule>{}) {
    _init();

    // Re-sync when user connects to internet
    _ref.listen<AsyncValue<bool>>(connectivityProvider, (previous, next) {
      if (next.value == true) {
        sync();
      }
    });

    // Re-sync when auth state changes (e.g. login, logout, or account switch)
    _ref.listen(currentUserProvider, (previous, next) {
      if (next?.id != previous?.id) {
        _onAuthChanged(next);
      }
    });
  }

  Future<void> _init() async {
    final user = _ref.read(currentUserProvider);
    final modules = await _service.syncCompletedModules(user);
    state = modules;
  }

  Future<void> _onAuthChanged(User? newUser) async {
    if (newUser == null) {
      state = <TutorialModule>{};
    } else {
      final modules = await _service.syncCompletedModules(newUser);
      state = modules;
    }
  }

  /// Determines whether a given [TutorialModule] is currently unlocked.
  ///
  /// Module 1 ([TutorialModule.basics]) is always unlocked for play.
  /// Each subsequent module unlocks only when its immediate predecessor
  /// has actually been completed.
  bool isUnlocked(TutorialModule module) {
    if (module == TutorialModule.basics) {
      return true;
    }

    final index = TutorialModule.values.indexOf(module);
    if (index <= 0) {
      return true;
    }

    final previousModule = TutorialModule.values[index - 1];
    return state.contains(previousModule);
  }

  /// Convenience helper to check unlock status by string [moduleId].
  bool isUnlockedById(String moduleId) {
    return isUnlocked(TutorialModule.fromId(moduleId));
  }

  /// Checks if a [TutorialModule] is already completed.
  bool isCompleted(TutorialModule module) {
    return state.contains(module);
  }

  /// Marks a [TutorialModule] as completed, persists locally, and syncs to cloud.
  Future<void> completeModule(TutorialModule module) async {
    if (state.contains(module)) {
      return;
    }

    final updated = {...state, module};
    state = updated;

    final user = _ref.read(currentUserProvider);
    await _service.saveLocalCompletedModules(updated, user?.id);

    if (user != null) {
      await _service.saveCloudCompletedModules(user, updated);
      await _service.awardModuleBp(user, module.bpReward);
      _ref.invalidate(userProfileProvider);
    }
  }

  /// Convenience helper to complete by string [moduleId].
  Future<void> completeModuleById(String moduleId) {
    return completeModule(TutorialModule.fromId(moduleId));
  }

  /// Manually triggers a two-way sync between local storage and cloud metadata.
  Future<void> sync() async {
    final user = _ref.read(currentUserProvider);
    final merged = await _service.syncCompletedModules(user);
    state = merged;
  }

  /// Resets tutorial progress for testing or resetting user data.
  Future<void> resetProgress() async {
    state = <TutorialModule>{};
    final user = _ref.read(currentUserProvider);
    await _service.clearCompletedModules(user?.id);
    if (user != null) {
      await _service.saveCloudCompletedModules(user, <TutorialModule>{});
    }
  }
}

/// Provider exposing the current set of completed [TutorialModule]s.
final tutorialProgressProvider =
    StateNotifierProvider<TutorialProgressNotifier, Set<TutorialModule>>((ref) {
  final service = ref.watch(tutorialProgressServiceProvider);
  return TutorialProgressNotifier(ref, service);
});
