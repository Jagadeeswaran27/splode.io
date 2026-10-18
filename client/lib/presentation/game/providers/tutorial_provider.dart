import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/domain/models/tutorial_step.dart';
import 'package:client/presentation/game/providers/game_provider.dart';
import 'package:client/domain/models/cell.dart';

List<TutorialStep> getStepsForModule(String moduleId) {
  if (moduleId == 'chain_reactions') {
    return [
      const TutorialStep(
        message: "Chain reactions are the key to victory! First, build up your cell to capture the enemy ahead.",
        targetRow: 7,
        targetCol: 1,
        expectedPlayer: 'p1',
      ),
      const TutorialStep(
        message: "Trigger the explosion to take over their cell and build your path.",
        targetRow: 7,
        targetCol: 1,
        expectedPlayer: 'p1',
      ),
      const TutorialStep(
        message: "Perfect! Now explode this newly captured cell to advance further up the board.",
        targetRow: 6,
        targetCol: 1,
        expectedPlayer: 'p1',
      ),
      const TutorialStep(
        message: "The enemy has a massive, unstable cluster above. This is the moment—trigger the final explosion!",
        targetRow: 5,
        targetCol: 1,
        expectedPlayer: 'p1',
      ),
      const TutorialStep(
        message: "That was the S-Curve! Now let's try the Whirlpool. Build the fuse at the bottom left.",
        targetRow: 8,
        targetCol: 2,
        expectedPlayer: 'p1',
      ),
      const TutorialStep(
        message: "Capture the adjacent cell to complete the fuse.",
        targetRow: 8,
        targetCol: 2,
        expectedPlayer: 'p1',
      ),
      const TutorialStep(
        message: "Trigger it! Watch closely as the chain reaction coils all the way to the center.",
        targetRow: 8,
        targetCol: 1,
        expectedPlayer: 'p1',
      ),
    ];
  }

  if (moduleId == 'capturing') {
    return [
      const TutorialStep(
        message: "You're outnumbered! Start by building up your base to prepare an attack.",
        targetRow: 4,
        targetCol: 1,
        expectedPlayer: 'p1',
      ),
      const TutorialStep(
        message: "Critical mass reached! Tap it to explode and capture the adjacent enemy orb.",
        targetRow: 4,
        targetCol: 1,
        expectedPlayer: 'p1',
      ),
      const TutorialStep(
        message: "Great capture! Build up your new cell to continue the attack.",
        targetRow: 4,
        targetCol: 2,
        expectedPlayer: 'p1',
      ),
      const TutorialStep(
        message: "They are building up a strong defense! Explode your cell to push through.",
        targetRow: 4,
        targetCol: 2,
        expectedPlayer: 'p1',
      ),
      const TutorialStep(
        message: "Your newly captured cell is almost at critical mass. One tap will trigger it!",
        targetRow: 4,
        targetCol: 3,
        expectedPlayer: 'p1',
      ),
      const TutorialStep(
        message: "The enemy has heavy defenses ahead. Build up your front line cell.",
        targetRow: 4,
        targetCol: 4,
        expectedPlayer: 'p1',
      ),
      const TutorialStep(
        message: "This is it! One more tap will trigger a MASSIVE chain reaction and wipe them out.",
        targetRow: 4,
        targetCol: 4,
        expectedPlayer: 'p1',
      ),
    ];
  }
  
  // Default to basics
  return [
    // SECTION 1: CENTER CELL
    const TutorialStep(
      message: "Welcome to Splode! Let's learn about Critical Mass. Tap the highlighted center cell.",
      targetRow: 4,
      targetCol: 2,
      expectedPlayer: 'p1',
    ),
    const TutorialStep(
      message: 'Center cells have 4 neighbors, so they need 4 orbs to explode. Tap it again.',
      targetRow: 4,
      targetCol: 2,
      expectedPlayer: 'p1',
    ),
    const TutorialStep(
      message: 'Notice how the orb grows? Keep building it up.',
      targetRow: 4,
      targetCol: 2,
      expectedPlayer: 'p1',
    ),
    const TutorialStep(
      message: 'One more orb will cause an EXPLOSION! Watch it expand into adjacent cells.',
      targetRow: 4,
      targetCol: 2,
      expectedPlayer: 'p1',
    ),

    // SECTION 2: CORNER CELL
    const TutorialStep(
      message: "Awesome! Now let's look at corners. They only have 2 neighbors, so they explode at 2 orbs. Tap the corner.",
      targetRow: 0,
      targetCol: 0,
      expectedPlayer: 'p1',
    ),
    const TutorialStep(
      message: "Since it's a corner, the very next orb will cause an explosion! Try it.",
      targetRow: 0,
      targetCol: 0,
      expectedPlayer: 'p1',
    ),

    // SECTION 3: EDGE CELL
    const TutorialStep(
      message: 'Finally, edge cells have 3 neighbors, so they explode at 3 orbs. Tap the edge cell.',
      targetRow: 0,
      targetCol: 3,
      expectedPlayer: 'p1',
    ),
    const TutorialStep(
      message: 'Tap it again to build it up.',
      targetRow: 0,
      targetCol: 3,
      expectedPlayer: 'p1',
    ),
    const TutorialStep(
      message: 'One more orb will reach its critical mass! Make it explode.',
      targetRow: 0,
      targetCol: 3,
      expectedPlayer: 'p1',
    ),
  ];
}

class TutorialState {
  final String moduleId;
  final int stepIndex;
  final int totalSteps;
  final bool isTutorialComplete;
  final bool isProcessingMove;
  final String? feedbackMessage;

  const TutorialState({
    required this.moduleId,
    required this.stepIndex,
    required this.totalSteps,
    required this.isTutorialComplete,
    this.isProcessingMove = false,
    this.feedbackMessage,
  });

  TutorialStep? get currentStep {
    final steps = getStepsForModule(moduleId);
    if (stepIndex >= steps.length) return null;
    final baseStep = steps[stepIndex];

    return TutorialStep(
      message: feedbackMessage ?? baseStep.message,
      targetRow: isProcessingMove || feedbackMessage != null
          ? -1
          : baseStep.targetRow,
      targetCol: isProcessingMove || feedbackMessage != null
          ? -1
          : baseStep.targetCol,
      expectedPlayer: baseStep.expectedPlayer,
    );
  }
}

class TutorialNotifier extends StateNotifier<TutorialState> {
  final Ref _ref;

  TutorialNotifier(this._ref)
    : super(const TutorialState(moduleId: 'basics', stepIndex: 0, totalSteps: 1, isTutorialComplete: false));

  void loadModule(String moduleId) {
    final steps = getStepsForModule(moduleId);
    state = TutorialState(
      moduleId: moduleId,
      stepIndex: 0,
      totalSteps: steps.length,
      isTutorialComplete: false,
    );
    
    // Set up board state if necessary
    if (moduleId == 'capturing') {
      _setupCapturingBoard();
    } else if (moduleId == 'chain_reactions') {
      _setupChainReactionBoard();
    }
  }

  void _setupWhirlpoolBoard() {
    final gameStateNotifier = _ref.read(gameStateProvider.notifier);
    final currentState = gameStateNotifier.state;
    
    // Create a fresh empty board
    final newBoard = List.generate(9, (_) => List.generate(6, (_) => const Cell(ownerId: '', orbCount: 0)));

    // The Fuse (Player 1)
    newBoard[8][2] = const Cell(ownerId: 'p1', orbCount: 2);
    newBoard[8][1] = const Cell(ownerId: 'p2', orbCount: 1); // User will capture this

    // 1. Up Col 0
    newBoard[8][0] = const Cell(ownerId: 'p2', orbCount: 1); // Corner
    newBoard[7][0] = const Cell(ownerId: 'p2', orbCount: 2);
    newBoard[6][0] = const Cell(ownerId: 'p2', orbCount: 2);
    newBoard[5][0] = const Cell(ownerId: 'p2', orbCount: 2);
    newBoard[4][0] = const Cell(ownerId: 'p2', orbCount: 2);
    newBoard[3][0] = const Cell(ownerId: 'p2', orbCount: 2);
    newBoard[2][0] = const Cell(ownerId: 'p2', orbCount: 2);
    newBoard[1][0] = const Cell(ownerId: 'p2', orbCount: 2);

    // 2. Across Row 0
    newBoard[0][0] = const Cell(ownerId: 'p2', orbCount: 1); // Corner
    newBoard[0][1] = const Cell(ownerId: 'p2', orbCount: 2);
    newBoard[0][2] = const Cell(ownerId: 'p2', orbCount: 2);
    newBoard[0][3] = const Cell(ownerId: 'p2', orbCount: 2);
    newBoard[0][4] = const Cell(ownerId: 'p2', orbCount: 2);
    
    // 3. Down Col 5
    newBoard[0][5] = const Cell(ownerId: 'p2', orbCount: 1); // Corner
    newBoard[1][5] = const Cell(ownerId: 'p2', orbCount: 2);
    newBoard[2][5] = const Cell(ownerId: 'p2', orbCount: 2);
    newBoard[3][5] = const Cell(ownerId: 'p2', orbCount: 2);
    newBoard[4][5] = const Cell(ownerId: 'p2', orbCount: 2);
    newBoard[5][5] = const Cell(ownerId: 'p2', orbCount: 2);
    newBoard[6][5] = const Cell(ownerId: 'p2', orbCount: 2);
    newBoard[7][5] = const Cell(ownerId: 'p2', orbCount: 2);
    
    // 4. Across Row 8
    newBoard[8][5] = const Cell(ownerId: 'p2', orbCount: 1); // Corner
    newBoard[8][4] = const Cell(ownerId: 'p2', orbCount: 2);

    // 5. Up Col 4 (receives cross-talk from Col 5, starts at 2)
    newBoard[7][4] = const Cell(ownerId: 'p2', orbCount: 2);
    newBoard[6][4] = const Cell(ownerId: 'p2', orbCount: 2);
    newBoard[5][4] = const Cell(ownerId: 'p2', orbCount: 2);
    newBoard[4][4] = const Cell(ownerId: 'p2', orbCount: 2);
    newBoard[3][4] = const Cell(ownerId: 'p2', orbCount: 2);
    newBoard[2][4] = const Cell(ownerId: 'p2', orbCount: 2);

    // 6. Across Row 2 (no cross talk, inner cells start at 3)
    newBoard[2][3] = const Cell(ownerId: 'p2', orbCount: 3);
    newBoard[2][2] = const Cell(ownerId: 'p2', orbCount: 3);

    // 7. Down Col 1 (receives cross-talk from Col 0, starts at 2)
    newBoard[2][1] = const Cell(ownerId: 'p2', orbCount: 2);
    newBoard[3][1] = const Cell(ownerId: 'p2', orbCount: 2);
    newBoard[4][1] = const Cell(ownerId: 'p2', orbCount: 2);
    newBoard[5][1] = const Cell(ownerId: 'p2', orbCount: 2);
    newBoard[6][1] = const Cell(ownerId: 'p2', orbCount: 2);

    // 8. Across Row 6 (no cross talk, starts at 3)
    newBoard[6][2] = const Cell(ownerId: 'p2', orbCount: 3);

    // 9. Up Col 3 (receives cross-talk from Col 4, starts at 2)
    newBoard[6][3] = const Cell(ownerId: 'p2', orbCount: 2);
    newBoard[5][3] = const Cell(ownerId: 'p2', orbCount: 2);
    newBoard[4][3] = const Cell(ownerId: 'p2', orbCount: 2);

    // 10. Center Finale! Starts with 1 orb, bot plays there -> 2.
    // Cross-talk from (4,1) -> 3. Hit by (4,3) -> 4 (EXPLODES)
    newBoard[4][2] = const Cell(ownerId: 'p2', orbCount: 1);

    gameStateNotifier.state = currentState.copyWith(
      board: newBoard,
      currentPlayerIndex: 0,
      isGameOver: false,
      winner: () => null,
      turnCount: 0,
      lastMove: () => null,
    );
  }

  void _setupCapturingBoard() {
    final gameStateNotifier = _ref.read(gameStateProvider.notifier);
    final currentState = gameStateNotifier.state;
    
    // Create a new board with a pre-configured situation
    final newBoard = currentState.cloneBoard();
    
    // Player 1 has 2 orbs in the center, needs to build up
    newBoard[4][1] = const Cell(ownerId: 'p1', orbCount: 2);
    
    // Player 2 defense line
    newBoard[4][2] = const Cell(ownerId: 'p2', orbCount: 1); 
    newBoard[4][3] = const Cell(ownerId: 'p2', orbCount: 2); 
    newBoard[4][4] = const Cell(ownerId: 'p2', orbCount: 1);
    
    // Player 2 heavy flanks for chain reaction finale
    newBoard[3][4] = const Cell(ownerId: 'p2', orbCount: 3);
    newBoard[5][4] = const Cell(ownerId: 'p2', orbCount: 3);

    gameStateNotifier.state = currentState.copyWith(board: newBoard);
  }

  void _setupChainReactionBoard() {
    final gameStateNotifier = _ref.read(gameStateProvider.notifier);
    final currentState = gameStateNotifier.state;
    final newBoard = currentState.cloneBoard();

    // Player 1 fuse start
    newBoard[7][1] = const Cell(ownerId: 'p1', orbCount: 2);

    // Player 2 fuse cells
    newBoard[6][1] = const Cell(ownerId: 'p2', orbCount: 1);
    newBoard[5][1] = const Cell(ownerId: 'p2', orbCount: 1);

    // 1. Upward path (Column 1)
    newBoard[4][1] = const Cell(ownerId: 'p2', orbCount: 3);
    newBoard[3][1] = const Cell(ownerId: 'p2', orbCount: 3);
    newBoard[2][1] = const Cell(ownerId: 'p2', orbCount: 3);
    newBoard[1][1] = const Cell(ownerId: 'p2', orbCount: 3);

    // 2. The first turn (Row 0)
    newBoard[0][1] = const Cell(ownerId: 'p2', orbCount: 2); // Edge
    newBoard[0][2] = const Cell(ownerId: 'p2', orbCount: 2); // Edge
    newBoard[0][3] = const Cell(ownerId: 'p2', orbCount: 2); // Edge

    // 3. The reverse downward path (Column 3)
    newBoard[1][3] = const Cell(ownerId: 'p2', orbCount: 3);
    newBoard[2][3] = const Cell(ownerId: 'p2', orbCount: 3);
    newBoard[3][3] = const Cell(ownerId: 'p2', orbCount: 3);
    newBoard[4][3] = const Cell(ownerId: 'p2', orbCount: 3);
    newBoard[5][3] = const Cell(ownerId: 'p2', orbCount: 3);
    newBoard[6][3] = const Cell(ownerId: 'p2', orbCount: 3);
    newBoard[7][3] = const Cell(ownerId: 'p2', orbCount: 3);

    // 4. The second turn (Row 8)
    newBoard[8][3] = const Cell(ownerId: 'p2', orbCount: 2); // Edge
    newBoard[8][4] = const Cell(ownerId: 'p2', orbCount: 2); // Edge
    newBoard[8][5] = const Cell(ownerId: 'p2', orbCount: 1); // Corner

    // 5. The final upward path (Column 5)
    newBoard[7][5] = const Cell(ownerId: 'p2', orbCount: 2); // Edge
    newBoard[6][5] = const Cell(ownerId: 'p2', orbCount: 2); // Edge
    newBoard[5][5] = const Cell(ownerId: 'p2', orbCount: 2); // Edge
    newBoard[4][5] = const Cell(ownerId: 'p2', orbCount: 2); // Edge
    newBoard[3][5] = const Cell(ownerId: 'p2', orbCount: 2); // Edge
    newBoard[2][5] = const Cell(ownerId: 'p2', orbCount: 2); // Edge
    newBoard[1][5] = const Cell(ownerId: 'p2', orbCount: 2); // Edge
    // [0][5] is left empty for the bot to play into and get destroyed

    gameStateNotifier.state = currentState.copyWith(board: newBoard);
  }

  void setProcessing(bool processing) {
    state = TutorialState(
      moduleId: state.moduleId,
      stepIndex: state.stepIndex,
      totalSteps: state.totalSteps,
      isTutorialComplete: state.isTutorialComplete,
      isProcessingMove: processing,
      feedbackMessage: state.feedbackMessage,
    );
  }

  void setFeedback(String? message) {
    state = TutorialState(
      moduleId: state.moduleId,
      stepIndex: state.stepIndex,
      totalSteps: state.totalSteps,
      isTutorialComplete: state.isTutorialComplete,
      isProcessingMove: state.isProcessingMove,
      feedbackMessage: message,
    );
  }

  void advanceStep() async {
    final steps = getStepsForModule(state.moduleId);
    if (state.stepIndex >= steps.length - 1) {
      state = TutorialState(
        moduleId: state.moduleId,
        stepIndex: state.stepIndex,
        totalSteps: state.totalSteps,
        isTutorialComplete: true,
      );
      return;
    }

    state = TutorialState(
      moduleId: state.moduleId,
      stepIndex: state.stepIndex + 1,
      totalSteps: state.totalSteps,
      isTutorialComplete: false,
    );

    // If advancing to phase 2 of chain reactions, reset the board
    if (state.moduleId == 'chain_reactions' && state.stepIndex == 4) {
      _setupWhirlpoolBoard();
    }

    // After player advances step, simulate bot turn based on module
    _simulateOpponentTurn();
  }

  Future<void> _simulateOpponentTurn() async {
    final stepIdx = state.stepIndex;
    final steps = getStepsForModule(state.moduleId);
    
    if (state.moduleId == 'chain_reactions') {
      if (stepIdx > 0 && stepIdx < 4) {
        setProcessing(true);
        await Future.delayed(const Duration(milliseconds: 1000));
        if (stepIdx == 1) {
          await _ref.read(gameStateProvider.notifier).processMove(6, 1);
        } else if (stepIdx == 2) {
          await _ref.read(gameStateProvider.notifier).processMove(5, 1);
        } else if (stepIdx == 3) {
          await _ref.read(gameStateProvider.notifier).processMove(0, 5); // Safe spot that gets destroyed at the very end
        }
        setProcessing(false);
      } else if (stepIdx > 4 && stepIdx < 7) {
        setProcessing(true);
        await Future.delayed(const Duration(milliseconds: 1000));
        if (stepIdx == 5) {
          await _ref.read(gameStateProvider.notifier).processMove(4, 2);
        } else if (stepIdx == 6) {
          await _ref.read(gameStateProvider.notifier).processMove(3, 2);
        }
        setProcessing(false);
      }
      return;
    }

    if (state.moduleId == 'capturing') {
      if (stepIdx > 0 && stepIdx < 7) {
        setProcessing(true);
        await Future.delayed(const Duration(milliseconds: 1000));
        
        if (stepIdx == 1) {
          await _ref.read(gameStateProvider.notifier).processMove(3, 5);
        } else if (stepIdx == 2) {
          await _ref.read(gameStateProvider.notifier).processMove(3, 5);
        } else if (stepIdx == 3) {
          await _ref.read(gameStateProvider.notifier).processMove(5, 5);
        } else if (stepIdx == 4) {
          await _ref.read(gameStateProvider.notifier).processMove(5, 5);
        } else if (stepIdx == 5) {
          await _ref.read(gameStateProvider.notifier).processMove(2, 4);
        } else if (stepIdx == 6) {
          await _ref.read(gameStateProvider.notifier).processMove(6, 4);
        }
        setProcessing(false);
      }
      return;
    }

    // For basics module, random safe moves
    if (stepIdx > 0 && stepIdx < steps.length) {
      setProcessing(true);
      await Future.delayed(const Duration(milliseconds: 350));
      
      final gameState = _ref.read(gameStateProvider);
      final random = math.Random();
      int row = -1;
      int col = -1;
      int attempts = 0;
      
      while (attempts < 50) {
        final r = 6 + random.nextInt(3); // Rows 6, 7, 8
        final c = random.nextInt(6);     // Cols 0 to 5
        final cell = gameState.board[r][c];
        
        if ((cell.ownerId == null || cell.ownerId == 'p2') && cell.orbCount < 2) {
          row = r;
          col = c;
          break;
        }
        attempts++;
      }
      
      if (row == -1 || col == -1) {
        row = 8;
        col = 5;
      }

      await _ref.read(gameStateProvider.notifier).processMove(row, col);
      setProcessing(false);
    }
  }

  void completeTutorial() {
    state = TutorialState(
      moduleId: state.moduleId,
      stepIndex: state.stepIndex,
      totalSteps: state.totalSteps,
      isTutorialComplete: true,
    );
  }

  void reset() {
    state = const TutorialState(moduleId: 'basics', stepIndex: 0, totalSteps: 1, isTutorialComplete: false);
  }
}

final tutorialProvider = StateNotifierProvider<TutorialNotifier, TutorialState>(
  (ref) {
    return TutorialNotifier(ref);
  },
);
