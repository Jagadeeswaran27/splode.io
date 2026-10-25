import 'package:equatable/equatable.dart';

class TutorialStep extends Equatable {
  final String? headline;
  final String message;
  final int targetRow;
  final int targetCol;

  /// The player ID who is expected to make the move (e.g. 'p1').
  /// If it is the bot's turn, we might just have a message and no target,
  /// but we can control that via logic in the provider.
  final String expectedPlayer;

  const TutorialStep({
    this.headline,
    required this.message,
    required this.targetRow,
    required this.targetCol,
    required this.expectedPlayer,
  });

  @override
  List<Object?> get props => [
        headline,
        message,
        targetRow,
        targetCol,
        expectedPlayer,
      ];
}
