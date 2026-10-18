/// Defines the difficulty levels for the AI opponent.
enum AiDifficulty {
  /// Random/Chaos bot. No lookahead.
  easy,

  /// Greedy bot. Looks 1 move ahead.
  medium,

  /// Tactician bot. Minimax, looks 3 moves ahead.
  hard,

  /// Grandmaster bot. Iterative Deepening with strict time limit.
  expert,
}
