import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BotMatchRecord {
  final String difficulty;
  final String result; // 'win', 'loss', 'draw'
  final DateTime playedAt;

  BotMatchRecord({
    required this.difficulty,
    required this.result,
    required this.playedAt,
  });

  Map<String, dynamic> toJson() => {
    'difficulty': difficulty,
    'result': result,
    'played_at': playedAt.toIso8601String(),
  };

  factory BotMatchRecord.fromJson(Map<String, dynamic> json) => BotMatchRecord(
    difficulty: json['difficulty'],
    result: json['result'],
    playedAt: DateTime.parse(json['played_at']),
  );
}

class BotHistoryService {
  static const String _key = 'offline_bot_matches';

  Future<void> saveOfflineMatch(BotMatchRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await getUnsyncedMatches();
    records.add(record);

    final String jsonString = jsonEncode(
      records.map((r) => r.toJson()).toList(),
    );
    await prefs.setString(_key, jsonString);
  }

  Future<List<BotMatchRecord>> getUnsyncedMatches() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => BotMatchRecord.fromJson(json)).toList();
  }

  Future<void> clearSyncedMatches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
