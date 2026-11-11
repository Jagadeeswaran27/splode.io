import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:client/domain/models/tutorial_module.dart';

final tutorialProgressServiceProvider = Provider(
  (ref) => TutorialProgressService(),
);

/// Service handling user-scoped local (SharedPreferences) and cloud (Supabase)
/// persistence for training module completion and unlock progress.
class TutorialProgressService {
  static const String _storageKey = 'splode_completed_tutorials';
  static const String _metadataKey = 'completed_tutorials';

  String _getStorageKey(String? userId) =>
      userId != null ? '${_storageKey}_$userId' : '${_storageKey}_guest';

  /// Retrieves the set of completed [TutorialModule]s from local storage for [userId].
  Future<Set<TutorialModule>> getLocalCompletedModules([String? userId]) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getStorageKey(userId);
    var list = prefs.getStringList(key);

    // Fallback to legacy unscoped key only for unauthenticated guest
    if (list == null && userId == null) {
      list = prefs.getStringList(_storageKey);
    }

    return list
            ?.map((e) => TutorialModule.tryFromId(e))
            .whereType<TutorialModule>()
            .toSet() ??
        <TutorialModule>{};
  }

  /// Persists the set of completed [TutorialModule]s to local storage for [userId].
  Future<void> saveLocalCompletedModules(
    Set<TutorialModule> modules, [
    String? userId,
  ]) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getStorageKey(userId);
    await prefs.setStringList(
      key,
      modules.map((m) => m.id).toList(),
    );
  }

  /// Clears local storage of completed modules for [userId].
  Future<void> clearCompletedModules([String? userId]) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getStorageKey(userId);
    await prefs.remove(key);
    // Also cleanup legacy unscoped key if present
    await prefs.remove(_storageKey);
  }

  /// Fetches completed [TutorialModule]s from Supabase user metadata.
  Future<Set<TutorialModule>> getCloudCompletedModules(User user) async {
    try {
      final raw = user.userMetadata?[_metadataKey];
      if (raw is List) {
        return raw
            .map((e) => TutorialModule.tryFromId(e?.toString()))
            .whereType<TutorialModule>()
            .toSet();
      }
    } catch (_) {
      // Gracefully fallback to empty set if metadata parsing fails
    }
    return <TutorialModule>{};
  }

  /// Saves completed [TutorialModule]s to Supabase user metadata.
  Future<void> saveCloudCompletedModules(
    User user,
    Set<TutorialModule> modules,
  ) async {
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          data: {
            _metadataKey: modules.map((m) => m.id).toList(),
          },
        ),
      );
    } catch (_) {
      // Offline or network error - local storage remains source of truth
    }
  }

  /// Syncs local and cloud completed modules for [user], returning the merged set.
  Future<Set<TutorialModule>> syncCompletedModules(User? user) async {
    if (user == null) {
      return getLocalCompletedModules(null);
    }

    final localModules = await getLocalCompletedModules(user.id);
    final cloudModules = await getCloudCompletedModules(user);
    final merged = {...localModules, ...cloudModules};

    if (merged.length != localModules.length) {
      await saveLocalCompletedModules(merged, user.id);
    }
    if (merged.length != cloudModules.length) {
      await saveCloudCompletedModules(user, merged);
    }

    return merged;
  }

  /// Awards [bpAmount] Blast Points to the user's profile in Supabase.
  Future<int?> awardModuleBp(User user, int bpAmount) async {
    if (bpAmount <= 0) return null;
    try {
      final profileResponse = await Supabase.instance.client
          .from('profiles')
          .select('blast_points')
          .eq('id', user.id)
          .single();
      final currentBp = profileResponse['blast_points'] as int? ?? 1200;
      final newBp = (currentBp + bpAmount).clamp(0, 99999);

      await Supabase.instance.client
          .from('profiles')
          .update({'blast_points': newBp})
          .eq('id', user.id);

      return newBp;
    } catch (_) {
      // Offline or network error - profile update will proceed gracefully
      return null;
    }
  }
}
