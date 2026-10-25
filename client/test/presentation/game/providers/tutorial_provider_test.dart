import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:client/domain/engine/game_engine.dart';
import 'package:client/domain/models/cell.dart';
import 'package:client/domain/models/game_state.dart';
import 'package:client/presentation/game/providers/game_provider.dart';
import 'package:client/presentation/game/providers/tutorial_provider.dart';

void main() {
  group('Edges & Corners Tutorial (Revamped)', () {
    test('getStepsForModule returns 6 steps with distinct, purposeful targets', () {
      final steps = getStepsForModule('edges_and_corners');
      expect(steps.length, 6);

      // Phase 1: The Corner Fortress
      expect(steps[0].targetRow, 0);
      expect(steps[0].targetCol, 0);
      expect(steps[0].expectedPlayer, 'p1');

      expect(steps[1].targetRow, 1);
      expect(steps[1].targetCol, 0);
      expect(steps[1].expectedPlayer, 'p1');

      expect(steps[2].targetRow, 1);
      expect(steps[2].targetCol, 0);
      expect(steps[2].expectedPlayer, 'p1');

      // Phase 2: The Perimeter Highway
      expect(steps[3].targetRow, 0);
      expect(steps[3].targetCol, 1);
      expect(steps[3].expectedPlayer, 'p1');

      expect(steps[4].targetRow, 0);
      expect(steps[4].targetCol, 4);
      expect(steps[4].expectedPlayer, 'p1');

      expect(steps[5].targetRow, 0);
      expect(steps[5].targetCol, 0);
      expect(steps[5].expectedPlayer, 'p1');
    });

    test('Initializes edges_and_corners module with armed corner and threatening edge', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(tutorialProvider.notifier);
      notifier.loadModule('edges_and_corners');

      final tutorialState = container.read(tutorialProvider);
      expect(tutorialState.moduleId, 'edges_and_corners');
      expect(tutorialState.stepIndex, 0);
      expect(tutorialState.totalSteps, 6);

      final gameState = container.read(gameStateProvider);
      // Player's corner is armed (1 orb, crit mass = 2)
      expect(gameState.board[0][0].ownerId, 'p1');
      expect(gameState.board[0][0].orbCount, 1);

      // Enemy edge threatens with 2 orbs (crit mass = 3)
      expect(gameState.board[0][1].ownerId, 'p2');
      expect(gameState.board[0][1].orbCount, 2);

      // Enemy center cells
      expect(gameState.board[1][1].ownerId, 'p2');
      expect(gameState.board[1][2].ownerId, 'p2');
      expect(gameState.board[2][2].ownerId, 'p2');
    });

    test('Phase 2 resets board with Perimeter Highway configuration at step index 3', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(tutorialProvider.notifier);
      notifier.loadModule('edges_and_corners');

      // Advance through Phase 1 steps
      notifier.advanceStep(); // index 1
      notifier.advanceStep(); // index 2
      notifier.advanceStep(); // index 3 -> triggers _setupPerimeterSweepBoard()

      final tutorialState = container.read(tutorialProvider);
      expect(tutorialState.stepIndex, 3);

      final gameState = container.read(gameStateProvider);
      // Corner detonator
      expect(gameState.board[0][0].ownerId, 'p1');
      expect(gameState.board[0][0].orbCount, 1);

      // Western fuse (to be primed by player)
      expect(gameState.board[0][1].ownerId, 'p1');
      expect(gameState.board[0][1].orbCount, 1);

      // Pre-primed highway
      expect(gameState.board[0][2].ownerId, 'p1');
      expect(gameState.board[0][2].orbCount, 2);
      expect(gameState.board[0][3].ownerId, 'p1');
      expect(gameState.board[0][3].orbCount, 2);

      // Eastern bridgehead (to be primed by player)
      expect(gameState.board[0][4].ownerId, 'p1');
      expect(gameState.board[0][4].orbCount, 1);

      // Enemy corner and edge flank
      expect(gameState.board[0][5].ownerId, 'p2');
      expect(gameState.board[0][5].orbCount, 1);
      expect(gameState.board[1][5].ownerId, 'p2');
      expect(gameState.board[1][5].orbCount, 2);
    });

    test('Phase 1 tactical flow: corner counter-attack and flank fortification', () {
      final board = List.generate(
        9,
        (_) => List.generate(6, (_) => const Cell()),
      );
      board[0][0] = const Cell(ownerId: 'p1', orbCount: 1);
      board[0][1] = const Cell(ownerId: 'p2', orbCount: 2);
      board[1][1] = const Cell(ownerId: 'p2', orbCount: 1);
      board[1][2] = const Cell(ownerId: 'p2', orbCount: 1);
      board[2][2] = const Cell(ownerId: 'p2', orbCount: 1);

      var state = GameState(
        rows: 9,
        cols: 6,
        players: const ['p1', 'p2'],
        currentPlayerIndex: 0,
        board: board,
      );

      // Step 0: Detonate corner [0][0]
      var steps = GameEngine.processMove(state, 0, 0, 'p1');
      state = steps.last;
      // Corner re-armed, flank occupied, enemy edge converted
      expect(state.board[0][0].ownerId, 'p1');
      expect(state.board[0][0].orbCount, 1);
      expect(state.board[1][0].ownerId, 'p1');
      expect(state.board[1][1].ownerId, 'p1');

      // Bot plays [1][2]
      steps = GameEngine.processMove(state, 1, 2, 'p2');
      state = steps.last;

      // Step 1: Reinforce flank [1][0]
      steps = GameEngine.processMove(state, 1, 0, 'p1');
      state = steps.last;
      expect(state.board[1][0].orbCount, 2);

      // Bot plays [2][2]
      steps = GameEngine.processMove(state, 2, 2, 'p2');
      state = steps.last;

      // Step 2: Detonate flank [1][0] into center
      steps = GameEngine.processMove(state, 1, 0, 'p1');
      expect(steps.length > 2, true);
    });

    test('Phase 2 tactical flow: perimeter priming and grand finale sweep', () {
      final board = List.generate(
        9,
        (_) => List.generate(6, (_) => const Cell()),
      );
      board[0][0] = const Cell(ownerId: 'p1', orbCount: 1);
      board[0][1] = const Cell(ownerId: 'p1', orbCount: 1);
      board[0][2] = const Cell(ownerId: 'p1', orbCount: 2);
      board[0][3] = const Cell(ownerId: 'p1', orbCount: 2);
      board[0][4] = const Cell(ownerId: 'p1', orbCount: 1);
      board[0][5] = const Cell(ownerId: 'p2', orbCount: 1);
      board[1][5] = const Cell(ownerId: 'p2', orbCount: 2);
      board[2][5] = const Cell(ownerId: 'p2', orbCount: 2);
      board[3][5] = const Cell(ownerId: 'p2', orbCount: 2);
      board[4][5] = const Cell(ownerId: 'p2', orbCount: 2);

      board[1][2] = const Cell(ownerId: 'p2', orbCount: 1);
      board[1][3] = const Cell(ownerId: 'p2', orbCount: 1);
      board[2][2] = const Cell(ownerId: 'p2', orbCount: 1);
      board[2][3] = const Cell(ownerId: 'p2', orbCount: 1);

      var state = GameState(
        rows: 9,
        cols: 6,
        players: const ['p1', 'p2'],
        currentPlayerIndex: 0,
        board: board,
      );

      // Step 3: Prime [0][1]
      var steps = GameEngine.processMove(state, 0, 1, 'p1');
      state = steps.last;
      expect(state.board[0][1].orbCount, 2);

      // Bot plays [2][2]
      steps = GameEngine.processMove(state, 2, 2, 'p2');
      state = steps.last;

      // Step 4: Prime [0][4]
      steps = GameEngine.processMove(state, 0, 4, 'p1');
      state = steps.last;
      expect(state.board[0][4].orbCount, 2);

      // Bot plays [2][3]
      steps = GameEngine.processMove(state, 2, 3, 'p2');
      state = steps.last;

      // Step 5: Detonate [0][0]
      steps = GameEngine.processMove(state, 0, 0, 'p1');
      expect(steps.length > 5, true);
      state = steps.last;

      // Entire perimeter converted to p1
      expect(state.board[0][5].ownerId, 'p1');
      expect(state.board[1][5].ownerId, 'p1');
      expect(state.board[2][5].ownerId, 'p1');
      expect(state.board[3][5].ownerId, 'p1');
    });
  });
}
