import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:client/domain/models/game_state.dart';
import 'package:client/domain/models/match_config.dart';

final gamePersistenceServiceProvider = Provider(
  (ref) => GamePersistenceService(),
);

class GamePersistenceService {
  static const _gameStateKey = 'splode_saved_game_state';
  static const _matchConfigKey = 'splode_saved_match_config';

  Future<void> saveGame(GameState state, MatchConfig config) async {
    final prefs = await SharedPreferences.getInstance();

    // Don't save if game is over
    if (state.isGameOver) {
      await clearSavedGame();
      return;
    }

    final stateJson = jsonEncode(state.toJson());
    final configJson = jsonEncode(config.toJson());

    await prefs.setString(_gameStateKey, stateJson);
    await prefs.setString(_matchConfigKey, configJson);
  }

  Future<void> clearSavedGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_gameStateKey);
    await prefs.remove(_matchConfigKey);
  }

  Future<SavedGameData?> loadSavedGame() async {
    final prefs = await SharedPreferences.getInstance();
    final stateStr = prefs.getString(_gameStateKey);
    final configStr = prefs.getString(_matchConfigKey);

    if (stateStr != null && configStr != null) {
      try {
        final state = GameState.fromJson(
          jsonDecode(stateStr) as Map<String, dynamic>,
        );
        final config = MatchConfig.fromJson(
          jsonDecode(configStr) as Map<String, dynamic>,
        );
        return SavedGameData(state: state, config: config);
      } catch (e) {
        await clearSavedGame();
      }
    }
    return null;
  }
}

class SavedGameData {
  final GameState state;
  final MatchConfig config;

  SavedGameData({required this.state, required this.config});
}
