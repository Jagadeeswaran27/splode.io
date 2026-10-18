import 'package:equatable/equatable.dart';

class MoveRecord extends Equatable {
  final String playerId;
  final int row;
  final int col;
  final int turnNumber;
  final bool causedExplosion;

  const MoveRecord({
    required this.playerId,
    required this.row,
    required this.col,
    required this.turnNumber,
    required this.causedExplosion,
  });

  /// Converts coordinates to algebraic notation (e.g. 0,0 -> "A1")
  String toAlgebraic() {
    final columnLetter = String.fromCharCode('A'.codeUnitAt(0) + col);
    final rowNumber = row + 1;
    final suffix = causedExplosion ? '💥' : '';
    return '$columnLetter$rowNumber$suffix';
  }

  MoveRecord copyWith({
    String? playerId,
    int? row,
    int? col,
    int? turnNumber,
    bool? causedExplosion,
  }) {
    return MoveRecord(
      playerId: playerId ?? this.playerId,
      row: row ?? this.row,
      col: col ?? this.col,
      turnNumber: turnNumber ?? this.turnNumber,
      causedExplosion: causedExplosion ?? this.causedExplosion,
    );
  }

  Map<String, dynamic> toJson() => {
    'playerId': playerId,
    'row': row,
    'col': col,
    'turnNumber': turnNumber,
    'causedExplosion': causedExplosion,
  };

  factory MoveRecord.fromJson(Map<String, dynamic> json) {
    return MoveRecord(
      playerId: json['playerId'] as String,
      row: json['row'] as int,
      col: json['col'] as int,
      turnNumber: json['turnNumber'] as int,
      causedExplosion: json['causedExplosion'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [playerId, row, col, turnNumber, causedExplosion];
}
