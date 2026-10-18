import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:client/presentation/auth/providers/auth_provider.dart';
import 'package:client/presentation/auth/providers/profile_provider.dart';
import 'package:client/presentation/core/providers/connectivity_provider.dart';
import 'package:client/presentation/game/services/bot_history_service.dart';

final botHistoryServiceProvider = Provider((ref) => BotHistoryService());

final botHistorySyncProvider = Provider<void>((ref) {
  // Listen to connectivity changes to trigger sync
  ref.listen<AsyncValue<bool>>(connectivityProvider, (previous, next) {
    if (next.value == true) {
      _syncOfflineMatches(ref);
    }
  });
});

Future<void> _syncOfflineMatches(Ref ref) async {
  final user = ref.read(currentUserProvider);
  if (user == null) {
    return; // Only sync for logged-in users (including guests)
  }

  final botHistoryService = ref.read(botHistoryServiceProvider);
  final records = await botHistoryService.getUnsyncedMatches();

  if (records.isEmpty) {
    return;
  }

  try {
    final List<Map<String, dynamic>> payload = records
        .map(
          (r) => {
            'user_id': user.id,
            'difficulty': r.difficulty,
            'result': r.result,
            'played_at': r.playedAt.toIso8601String(),
          },
        )
        .toList();

    await Supabase.instance.client.from('bot_match_history').insert(payload);

    // Clear local storage after successful sync
    await botHistoryService.clearSyncedMatches();
  } catch (e) {
    // Keep records locally if sync fails
  }
}

class BotHistoryManager {
  final Ref ref;

  BotHistoryManager(this.ref);

  Future<int> recordMatch(
    String difficulty,
    String result, {
    bool isRanked = false,
  }) async {
    final record = BotMatchRecord(
      difficulty: difficulty,
      result: result,
      playedAt: DateTime.now().toUtc(),
    );

    final isOnline = ref.read(connectivityProvider).value ?? false;
    final user = ref.read(currentUserProvider);

    int bpChange = 0;

    if (isOnline && user != null) {
      try {
        await Supabase.instance.client.from('bot_match_history').insert({
          'user_id': user.id,
          'difficulty': record.difficulty,
          'result': record.result,
          'played_at': record.playedAt.toIso8601String(),
        });

        if (isRanked) {
          if (difficulty == 'hard') {
            bpChange = result == 'win' ? 10 : -5;
          } else if (difficulty == 'expert') {
            bpChange = result == 'win' ? 20 : -5;
          }
        }

        if (bpChange != 0) {
          final profileResponse = await Supabase.instance.client
              .from('profiles')
              .select('blast_points')
              .eq('id', user.id)
              .single();
          final currentBp = profileResponse['blast_points'] as int? ?? 1200;

          final newBp = (currentBp + bpChange).clamp(0, 99999);

          await Supabase.instance.client
              .from('profiles')
              .update({'blast_points': newBp})
              .eq('id', user.id);

          ref.invalidate(userProfileProvider);
        }

        return bpChange;
      } catch (e) {
        // Fallback to local save if network drops mid-request
      }
    }

    // Save offline
    await ref.read(botHistoryServiceProvider).saveOfflineMatch(record);
    return 0;
  }
}

final botHistoryManagerProvider = Provider((ref) => BotHistoryManager(ref));

final botMatchHistoryProvider =
    FutureProvider.autoDispose<List<BotMatchRecord>>((ref) async {
      final user = ref.watch(currentUserProvider);
      final isOnline = ref.watch(connectivityProvider).value ?? false;

      final botHistoryService = ref.read(botHistoryServiceProvider);
      final localRecords = await botHistoryService.getUnsyncedMatches();

      if (!isOnline || user == null) {
        localRecords.sort((a, b) => b.playedAt.compareTo(a.playedAt));
        return localRecords;
      }

      try {
        final response = await Supabase.instance.client
            .from('bot_match_history')
            .select()
            .eq('user_id', user.id)
            .order('played_at', ascending: false)
            .limit(50);

        final onlineRecords = response
            .map((json) => BotMatchRecord.fromJson(json))
            .toList();

        final allRecords = [...onlineRecords, ...localRecords];
        allRecords.sort((a, b) => b.playedAt.compareTo(a.playedAt));

        return allRecords;
      } catch (e) {
        localRecords.sort((a, b) => b.playedAt.compareTo(a.playedAt));
        return localRecords;
      }
    });
