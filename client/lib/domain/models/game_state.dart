import 'package:equatable/equatable.dart';
import 'cell.dart';
import 'move_record.dart';

class GameState extends Equatable {
  final List<List<Cell>> board;
  final int rows;
  final int cols;
  final List<String> players;
  final int currentPlayerIndex;
  final bool isGameOver;
  final String? winner;
  final int turnCount;
  final MoveRecord? lastMove;

  final bool isTutorial;

  const GameState({
    required this.board,
    required this.rows,
    required this.cols,
    required this.players,
    required this.currentPlayerIndex,
    this.isGameOver = false,
    this.winner,
    this.turnCount = 0,
    this.lastMove,
    this.isTutorial = false,
  });

  String get currentPlayer => players[currentPlayerIndex];

  GameState copyWith({
    List<List<Cell>>? board,
    int? currentPlayerIndex,
    bool? isGameOver,
    String? Function()? winner,
    int? turnCount,
    MoveRecord? Function()? lastMove,
    bool? isTutorial,
  }) {
    return GameState(
      board: board ?? this.board,
      rows: rows,
      cols: cols,
      players: players,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      isGameOver: isGameOver ?? this.isGameOver,
      winner: winner != null ? winner() : this.winner,
      turnCount: turnCount ?? this.turnCount,
      lastMove: lastMove != null ? lastMove() : this.lastMove,
      isTutorial: isTutorial ?? this.isTutorial,
    );
  }

  List<List<Cell>> cloneBoard() {
    return board.map((row) => List<Cell>.from(row)).toList();
  }

  @override
  List<Object?> get props => [
    board,
    rows,
    cols,
    players,
    currentPlayerIndex,
    isGameOver,
    winner,
    turnCount,
    lastMove,
    isTutorial,
  ];

  Map<String, dynamic> toJson() => {
    'board': board
        .map((row) => row.map((cell) => cell.toJson()).toList())
        .toList(),
    'rows': rows,
    'cols': cols,
    'players': players,
    'currentPlayerIndex': currentPlayerIndex,
    'isGameOver': isGameOver,
    'winner': winner,
    'turnCount': turnCount,
    'lastMove': lastMove?.toJson(),
  };

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      board: (json['board'] as List)
          .map(
            (row) => (row as List)
                .map((cell) => Cell.fromJson(cell as Map<String, dynamic>))
                .toList(),
          )
          .toList(),
      rows: json['rows'] as int,
      cols: json['cols'] as int,
      players: (json['players'] as List).cast<String>(),
      currentPlayerIndex: json['currentPlayerIndex'] as int,
      isGameOver: json['isGameOver'] as bool? ?? false,
      winner: json['winner'] as String?,
      turnCount: json['turnCount'] as int? ?? 0,
      lastMove: json['lastMove'] != null
          ? MoveRecord.fromJson(json['lastMove'] as Map<String, dynamic>)
          : null,
    );
  }
}
