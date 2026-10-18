import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:client/presentation/game/providers/game_provider.dart';

class MoveHistoryBottomSheet extends ConsumerWidget {
  const MoveHistoryBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(gameHistoryProvider);
    final viewIndex = ref.watch(viewIndexProvider);
    final matchConfig = ref.watch(matchConfigProvider);

    if (history.isEmpty) {
      return const SizedBox.shrink();
    }

    // Skip the initial state which has no move
    final moves = history.skip(1).toList();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'MOVE HISTORY',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white54),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          // Move List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: moves.length,
              itemBuilder: (context, index) {
                final state = moves[index];
                final move = state.lastMove;
                if (move == null) return const SizedBox.shrink();

                final player = matchConfig.players.firstWhere(
                  (p) => p.id == move.playerId,
                  orElse: () => matchConfig.players.first,
                );

                // History state index is offset by 1 because history[0] is the start state.
                final historyIndex = index + 1;
                final isSelected = historyIndex == viewIndex;

                return Material(
                  color: isSelected
                      ? player.color.withValues(alpha: 0.15)
                      : Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      ref.read(viewIndexProvider.notifier).state = historyIndex;
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: player.color.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: player.color.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${move.turnNumber}',
                              style: GoogleFonts.outfit(
                                color: player.color,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              '${player.name} to ${move.toAlgebraic()}',
                              style: GoogleFonts.inter(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white70,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.visibility_rounded,
                              color: player.color,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
