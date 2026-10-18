import 'package:flutter/material.dart';
import 'package:client/domain/models/ai_difficulty.dart';

class PlayerConfig {
  final String id;
  final String name;
  final Color color;
  final bool isAi;
  final AiDifficulty? aiDifficulty;

  const PlayerConfig({
    required this.id,
    required this.name,
    required this.color,
    this.isAi = false,
    this.aiDifficulty,
  });

  PlayerConfig copyWith({
    String? id,
    String? name,
    Color? color,
    bool? isAi,
    AiDifficulty? aiDifficulty,
  }) {
    return PlayerConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      isAi: isAi ?? this.isAi,
      aiDifficulty: aiDifficulty ?? this.aiDifficulty,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'color': color.toARGB32(),
    'isAi': isAi,
    'aiDifficulty': aiDifficulty?.name,
  };

  factory PlayerConfig.fromJson(Map<String, dynamic> json) => PlayerConfig(
    id: json['id'] as String,
    name: json['name'] as String,
    color: Color(json['color'] as int),
    isAi: json['isAi'] as bool? ?? false,
    aiDifficulty: json['aiDifficulty'] != null
        ? AiDifficulty.values.byName(json['aiDifficulty'] as String)
        : null,
  );
}

class MatchConfig {
  final int rows;
  final int cols;
  final List<PlayerConfig> players;
  final bool isRanked;
  final bool isTutorial;

  const MatchConfig({
    required this.rows,
    required this.cols,
    required this.players,
    this.isRanked = false,
    this.isTutorial = false,
  });

  MatchConfig copyWith({
    int? rows,
    int? cols,
    List<PlayerConfig>? players,
    bool? isRanked,
    bool? isTutorial,
  }) {
    return MatchConfig(
      rows: rows ?? this.rows,
      cols: cols ?? this.cols,
      players: players ?? this.players,
      isRanked: isRanked ?? this.isRanked,
      isTutorial: isTutorial ?? this.isTutorial,
    );
  }

  Map<String, dynamic> toJson() => {
    'rows': rows,
    'cols': cols,
    'players': players.map((p) => p.toJson()).toList(),
    'isRanked': isRanked,
    'isTutorial': isTutorial,
  };

  factory MatchConfig.fromJson(Map<String, dynamic> json) => MatchConfig(
    rows: json['rows'] as int,
    cols: json['cols'] as int,
    players: (json['players'] as List)
        .map((p) => PlayerConfig.fromJson(p as Map<String, dynamic>))
        .toList(),
    isRanked: json['isRanked'] as bool? ?? false,
    isTutorial: json['isTutorial'] as bool? ?? false,
  );
}
