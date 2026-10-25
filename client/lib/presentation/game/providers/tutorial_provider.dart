import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:client/domain/models/cell.dart';
import 'package:client/domain/models/tutorial_step.dart';
import 'package:client/presentation/game/providers/game_provider.dart';

List<TutorialStep> getStepsForModule(String moduleId) {
  if (moduleId == 'edges_and_corners') {
    return [
      // Phase 1: The Corner Fortress (Steps 0-2)
      const TutorialStep(
        headline: "Strike first from the corner!",
        message: "Corners explode at only 2 orbs. Detonate before their adjacent edge reaches critical mass.",
        targetRow: 0,
        targetCol: 0,
        expectedPlayer: 'p1',
      ),
      const TutorialStep(
        headline: "Fortify your left flank.",
        message: "Your counter-blast re-armed the corner and captured the edge. Now fortify the side edge.",
        targetRow: 1,
        targetCol: 0,
        expectedPlayer: 'p1',
      ),
      const TutorialStep(
        headline: "Detonate into the center!",
        message: "Center cells take 4 orbs to burst—far too slow against your primed perimeter flank.",
        targetRow: 1,
        targetCol: 0,
        expectedPlayer: 'p1',
      ),
      // Phase 2: The Perimeter Highway (Steps 3-5)
      const TutorialStep(
        headline: "Prime the Perimeter Highway.",
        message: "Never attack center defenses head-on. Edges burst at 3 orbs. Prime the top route.",
        targetRow: 0,
        targetCol: 1,
        expectedPlayer: 'p1',
      ),
      const TutorialStep(
        headline: "Extend the highway.",
        message: "Prime the next edge along the perimeter to connect your route straight to their corner.",
        targetRow: 0,
        targetCol: 4,
        expectedPlayer: 'p1',
      ),
      const TutorialStep(
        headline: "Unleash the perimeter wave!",
        message: "Detonate your corner to trigger a massive cascade and sweep their defenses from behind.",
        targetRow: 0,
        targetCol: 0,
        expectedPlayer: 'p1',
      ),
    ];
  }

  if (moduleId == 'chain_reactions') {
    return [
      const TutorialStep(
        headline: "Build your launchpad.",
        message: "Chain reactions win matches. Add an orb to prepare an attack on the enemy ahead.",
        targetRow: 7,
        targetCol: 1,
        expectedPlayer: 'p1',
      ),
      const TutorialStep(
        headline: "Trigger the first blast.",
        message: "Explode your cell to convert the enemy orb and open your path forward.",
        targetRow: 7,
        targetCol: 1,
        expectedPlayer: 'p1',
      ),
      const TutorialStep(
        headline: "Advance up the board.",
        message: "Detonate your newly captured cell to push deeper into their territory.",
        targetRow: 6,
        targetCol: 1,
        expectedPlayer: 'p1',
      ),
      const TutorialStep(
        headline: "Trigger critical mass!",
        message: "The enemy has an unstable cluster above. Ignite it with one final explosion.",
        targetRow: 5,
        targetCol: 1,
        expectedPlayer: 'p1',
      ),
      const TutorialStep(
        headline: "The Whirlpool: Build fuse.",
        message: "Add an orb to the bottom-left cell to start building an inward spiral.",
        targetRow: 8,
        targetCol: 2,
        expectedPlayer: 'p1',
      ),
      const TutorialStep(
        headline: "Arm the adjacent cell.",
        message: "Capture the neighboring cell to complete the domino fuse.",
        targetRow: 8,
        targetCol: 2,
        expectedPlayer: 'p1',
      ),
      const TutorialStep(
        headline: "Detonate the Whirlpool!",
        message: "Watch the chain reaction coil inward and detonate all the way to the center.",
        targetRow: 8,
        targetCol: 1,
        expectedPlayer: 'p1',
      ),
    ];
  }

  if (moduleId == 'capturing') {
    return [
      const TutorialStep(
        headline: "Prepare your attack.",
        message: "You're outnumbered! Place an orb in your base to build toward critical mass.",
        targetRow: 4,
        targetCol: 1,
        expectedPlayer: 'p1',
      ),
      const TutorialStep(
        headline: "Capture adjacent orb.",
        message: "Critical mass reached! Tap to explode and convert the enemy orb to your team.",
        targetRow: 4,
        targetCol: 1,
        expectedPlayer: 'p1',
      ),
      const TutorialStep(
        headline: "Reinforce captured cell.",
        message: "Great capture! Build up your new cell to continue driving forward.",
        targetRow: 4,
        targetCol: 2,
        expectedPlayer: 'p1',
      ),
      const TutorialStep(
        headline: "Push through defense.",
        message: "They are fortifying nearby. Detonate your cell to break through their line.",
        targetRow: 4,
        targetCol: 2,
        expectedPlayer: 'p1',
      ),
      const TutorialStep(
        headline: "Ignite frontline cell.",
        message: "Your new cell is at critical mass. One tap will trigger the next explosion.",
        targetRow: 4,
        targetCol: 3,
        expectedPlayer: 'p1',
      ),
      const TutorialStep(
        headline: "Fortify the frontline.",
        message: "Enemy defenses are heavy ahead. Place an orb to arm your forward post.",
        targetRow: 4,
        targetCol: 4,
        expectedPlayer: 'p1',
      ),
      const TutorialStep(
        headline: "Trigger final wipeout!",
        message: "One more tap will ignite a massive wave and clear the board.",
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
      headline: "Tap the center cell.",
      message: "Welcome to Splode! Learn critical mass by tapping the highlighted center cell.",
      targetRow: 4,
      targetCol: 2,
      expectedPlayer: 'p1',
    ),
    const TutorialStep(
      headline: "Build to 4 orbs.",
      message: "Center cells have 4 neighbors, so they require 4 orbs to explode. Tap again.",
      targetRow: 4,
      targetCol: 2,
      expectedPlayer: 'p1',
    ),
    const TutorialStep(
      headline: "Watch the orb charge.",
      message: "Notice how the orb vibrates and grows as it gets closer to bursting.",
      targetRow: 4,
      targetCol: 2,
      expectedPlayer: 'p1',
    ),
    const TutorialStep(
      headline: "Trigger the explosion!",
      message: "One more orb causes an explosion that bursts into all 4 adjacent cells.",
      targetRow: 4,
      targetCol: 2,
      expectedPlayer: 'p1',
    ),

    // SECTION 2: CORNER CELL
    const TutorialStep(
      headline: "Corners need only 2 orbs.",
      message: "Corners have only 2 neighbors, making them the fastest detonators. Tap the corner.",
      targetRow: 0,
      targetCol: 0,
      expectedPlayer: 'p1',
    ),
    const TutorialStep(
      headline: "Explode the corner!",
      message: "Tap once more to trigger an instant 2-way explosion along the outer borders.",
      targetRow: 0,
      targetCol: 0,
      expectedPlayer: 'p1',
    ),

    // SECTION 3: EDGE CELL
    const TutorialStep(
      headline: "Edges need 3 orbs.",
      message: "Edges have 3 neighbors. Tap the highlighted edge to start building it up.",
      targetRow: 0,
      targetCol: 3,
      expectedPlayer: 'p1',
    ),
    const TutorialStep(
      headline: "Charge the edge.",
      message: "Add another orb to bring this edge cell to critical mass.",
      targetRow: 0,
      targetCol: 3,
      expectedPlayer: 'p1',
    ),
    const TutorialStep(
      headline: "Detonate the 3-way burst!",
      message: "One more orb triggers a 3-directional shockwave into surrounding cells.",
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
    } else if (moduleId == 'edges_and_corners') {
      _setupEdgesAndCornersBoard();
    }
  }

  void _setupWhirlpoolBoard() {
    final gameStateNotifier = _ref.read(gameStateProvider.notifier);
    final currentState = gameStateNotifier.state;
    
    // Create a fresh empty board
    final newBoard = List.generate(9, (_) => List.generate(6, (_) => const Cell()));

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

  void _setupEdgesAndCornersBoard() {
    final gameStateNotifier = _ref.read(gameStateProvider.notifier);
    final currentState = gameStateNotifier.state;
    final newBoard = List.generate(
      9,
      (_) => List.generate(6, (_) => const Cell()),
    );

    // Player holds corner [0][0] armed with 1 orb
    newBoard[0][0] = const Cell(ownerId: 'p1', orbCount: 1);

    // Enemy edge cell threatens the corner with 2 orbs
    newBoard[0][1] = const Cell(ownerId: 'p2', orbCount: 2);

    // Enemy center presence
    newBoard[1][1] = const Cell(ownerId: 'p2', orbCount: 1);
    newBoard[1][2] = const Cell(ownerId: 'p2', orbCount: 1);
    newBoard[2][2] = const Cell(ownerId: 'p2', orbCount: 1);

    gameStateNotifier.state = currentState.copyWith(
      board: newBoard,
      currentPlayerIndex: 0,
      isGameOver: false,
      winner: () => null,
      turnCount: 0,
      lastMove: () => null,
    );
  }

  void _setupPerimeterSweepBoard() {
    final gameStateNotifier = _ref.read(gameStateProvider.notifier);
    final currentState = gameStateNotifier.state;
    final newBoard = List.generate(
      9,
      (_) => List.generate(6, (_) => const Cell()),
    );

    // Player's top row highway:
    // [0][0] corner detonator (1 orb)
    newBoard[0][0] = const Cell(ownerId: 'p1', orbCount: 1);
    // [0][1] western fuse (needs 1 orb from player to reach 2)
    newBoard[0][1] = const Cell(ownerId: 'p1', orbCount: 1);
    newBoard[0][2] = const Cell(ownerId: 'p1', orbCount: 2);
    newBoard[0][3] = const Cell(ownerId: 'p1', orbCount: 2);
    // [0][4] eastern bridgehead (needs 1 orb from player to reach 2)
    newBoard[0][4] = const Cell(ownerId: 'p1', orbCount: 1);

    // Enemy corner — swept by the cascade
    newBoard[0][5] = const Cell(ownerId: 'p2', orbCount: 1);

    // Enemy edge highway down the right side
    newBoard[1][5] = const Cell(ownerId: 'p2', orbCount: 2);
    newBoard[2][5] = const Cell(ownerId: 'p2', orbCount: 2);
    newBoard[3][5] = const Cell(ownerId: 'p2', orbCount: 2);
    newBoard[4][5] = const Cell(ownerId: 'p2', orbCount: 2);

    // Enemy center stronghold
    newBoard[1][2] = const Cell(ownerId: 'p2', orbCount: 1);
    newBoard[1][3] = const Cell(ownerId: 'p2', orbCount: 1);
    newBoard[2][2] = const Cell(ownerId: 'p2', orbCount: 1);
    newBoard[2][3] = const Cell(ownerId: 'p2', orbCount: 1);

    gameStateNotifier.state = currentState.copyWith(
      board: newBoard,
      currentPlayerIndex: 0,
      isGameOver: false,
      winner: () => null,
      turnCount: 0,
      lastMove: () => null,
    );
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

    // If advancing to phase 2, reset the board
    if (state.moduleId == 'chain_reactions' && state.stepIndex == 4) {
      _setupWhirlpoolBoard();
    } else if (state.moduleId == 'edges_and_corners' && state.stepIndex == 3) {
      _setupPerimeterSweepBoard();
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

    if (state.moduleId == 'edges_and_corners') {
      // Phase 1: bot builds center presence, demonstrating slow 4-neighbor buildup
      // Phase 2: bot reinforces center while perimeter highway is armed
      if (stepIdx == 1 || stepIdx == 2 || stepIdx == 4 || stepIdx == 5) {
        setProcessing(true);
        await Future.delayed(const Duration(milliseconds: 1000));
        if (stepIdx == 1) {
          await _ref.read(gameStateProvider.notifier).processMove(1, 2);
        } else if (stepIdx == 2) {
          await _ref.read(gameStateProvider.notifier).processMove(2, 2);
        } else if (stepIdx == 4) {
          await _ref.read(gameStateProvider.notifier).processMove(2, 2);
        } else if (stepIdx == 5) {
          await _ref.read(gameStateProvider.notifier).processMove(2, 3);
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
