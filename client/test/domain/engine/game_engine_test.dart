import 'package:client/domain/engine/game_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameEngine', () {
    test('createInitialState creates a correct board', () {
      final state = GameEngine.createInitialState(9, 6, ['p1', 'p2']);
      expect(state.rows, 9);
      expect(state.cols, 6);
      expect(state.players, ['p1', 'p2']);
      expect(state.currentPlayerIndex, 0);
      expect(state.board.length, 9);
      expect(state.board[0].length, 6);
      expect(state.board[0][0].orbCount, 0);
      expect(state.board[0][0].ownerId, null);
    });

    test('getCriticalMass returns correct values', () {
      // Corner
      expect(GameEngine.getCriticalMass(0, 0, 9, 6), 2);
      expect(GameEngine.getCriticalMass(8, 5, 9, 6), 2);
      // Edge
      expect(GameEngine.getCriticalMass(0, 3, 9, 6), 3);
      expect(GameEngine.getCriticalMass(4, 0, 9, 6), 3);
      // Center
      expect(GameEngine.getCriticalMass(4, 3, 9, 6), 4);
    });

    test('processMove correctly places orb and switches turn', () {
      final initialState = GameEngine.createInitialState(9, 6, ['p1', 'p2']);

      final steps = GameEngine.processMove(initialState, 0, 0, 'p1');
      expect(steps.length, 1);

      final finalState = steps.last;
      expect(finalState.board[0][0].orbCount, 1);
      expect(finalState.board[0][0].ownerId, 'p1');
      expect(finalState.currentPlayerIndex, 1); // p2's turn
      expect(finalState.turnCount, 1);
    });

    test('processMove handles explosions properly', () {
      var state = GameEngine.createInitialState(9, 6, ['p1', 'p2']);
      // p1 plays 0,0
      state = GameEngine.processMove(state, 0, 0, 'p1').last;
      // p2 plays 8,5
      state = GameEngine.processMove(state, 8, 5, 'p2').last;
      // p1 plays 0,0 again. Critical mass is 2. It should explode!
      final steps = GameEngine.processMove(state, 0, 0, 'p1');

      expect(steps.length, 3); // 1. Initial placement (2 orbs). 2. In-flight. 3. Landed (neighbors receive orbs)
      final finalState = steps.last;

      // 0,0 should have 0 orbs and no owner
      expect(finalState.board[0][0].orbCount, 0);
      expect(finalState.board[0][0].ownerId, null);

      // Neighbors should have 1 orb and owned by p1
      expect(finalState.board[0][1].orbCount, 1);
      expect(finalState.board[0][1].ownerId, 'p1');

      expect(finalState.board[1][0].orbCount, 1);
      expect(finalState.board[1][0].ownerId, 'p1');
    });

    test('processMove detects win condition correctly', () {
      // 2x2 board to trigger win quickly
      var state = GameEngine.createInitialState(2, 2, ['p1', 'p2']);
      // Turn 1: p1
      state = GameEngine.processMove(state, 0, 0, 'p1').last;
      // Turn 2: p2
      state = GameEngine.processMove(state, 1, 1, 'p2').last;
      // Turn 3: p1
      state = GameEngine.processMove(state, 0, 1, 'p1').last;
      // Turn 4: p2 plays on 1,1 again. Explodes, captures 0,1.
      // 0,1 has 1 orb, becomes 2. Corner critical mass is 2. So 0,1 explodes.
      // Cascades to 0,0 which is p1.
      final steps = GameEngine.processMove(state, 1, 1, 'p2');

      final finalState = steps.last;
      expect(finalState.isGameOver, true);
      expect(finalState.winner, 'p2');
    });
  });
}
