import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:client/domain/models/ai_difficulty.dart';
import 'package:client/domain/models/match_config.dart';
import 'package:client/presentation/core/utils/splode_snackbar.dart';
import 'package:client/presentation/core/widgets/auth_button.dart';
import 'package:client/presentation/core/widgets/constellation_background.dart';
import 'package:client/presentation/game/providers/game_provider.dart';

const List<Color> kPlayerColors = [
  Color(0xFFD4A44C), // Amber
  Color(0xFFF5F0E8), // Cream
  Color(0xFF14B8A6), // Teal
  Color(0xFFF43F5E), // Rose
];

enum GridSizeOption {
  small(6, 4, 'Small (6x4)'),
  medium(9, 6, 'Medium (9x6)'),
  large(12, 8, 'Large (12x8)');

  final int rows;
  final int cols;
  final String label;

  const GridSizeOption(this.rows, this.cols, this.label);
}

class OfflineMatchSetupScreen extends ConsumerStatefulWidget {
  const OfflineMatchSetupScreen({super.key});

  @override
  ConsumerState<OfflineMatchSetupScreen> createState() =>
      _OfflineMatchSetupScreenState();
}

class _OfflineMatchSetupScreenState
    extends ConsumerState<OfflineMatchSetupScreen> {
  int _playerCount = 2;
  GridSizeOption _selectedGridSize = GridSizeOption.medium;

  // State for players
  late List<TextEditingController> _nameControllers;
  late List<Color> _selectedColors;
  late List<bool> _isAi;
  late List<AiDifficulty> _aiDifficulties;

  @override
  void initState() {
    super.initState();
    _initPlayers(2);
  }

  void _initPlayers(int count) {
    _nameControllers = List.generate(
      count,
      (i) => TextEditingController(text: 'Player ${i + 1}'),
    );
    _selectedColors = List.generate(
      count,
      (i) => kPlayerColors[i % kPlayerColors.length],
    );
    _isAi = List.generate(count, (i) => false);
    _aiDifficulties = List.generate(count, (i) => AiDifficulty.medium);
  }

  void _addPlayer() {
    if (_playerCount >= 4) return;
    setState(() {
      _nameControllers.add(
        TextEditingController(text: 'Player ${_playerCount + 1}'),
      );
      // Pick first available unused color
      final usedColors = _selectedColors.toSet();
      final availableColor = kPlayerColors.firstWhere(
        (c) => !usedColors.contains(c),
        orElse: () => kPlayerColors[_playerCount % kPlayerColors.length],
      );
      _selectedColors.add(availableColor);
      _isAi.add(false);
      _aiDifficulties.add(AiDifficulty.medium);
      _playerCount++;
    });
  }

  void _removePlayer(int index) {
    if (_playerCount <= 2) return;
    setState(() {
      _nameControllers[index].dispose();
      _nameControllers.removeAt(index);
      _selectedColors.removeAt(index);
      _isAi.removeAt(index);
      _aiDifficulties.removeAt(index);
      _playerCount--;
    });
  }

  @override
  void dispose() {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startMatch() {
    // Validate uniqueness of colors
    final uniqueColors = _selectedColors.toSet();
    if (uniqueColors.length != _playerCount) {
      SplodeSnackbar.show(
        context: context,
        message: 'Each player must have a unique color.',
        type: SnackbarType.error,
      );
      return;
    }

    final players = List.generate(
      _playerCount,
      (i) => PlayerConfig(
        id: 'p${i + 1}',
        name: _nameControllers[i].text.trim().isEmpty
            ? (_isAi[i] ? 'Bot ${i + 1}' : 'Player ${i + 1}')
            : _nameControllers[i].text.trim(),
        color: _selectedColors[i],
        isAi: _isAi[i],
        aiDifficulty: _isAi[i] ? _aiDifficulties[i] : null,
      ),
    );

    final config = MatchConfig(
      rows: _selectedGridSize.rows,
      cols: _selectedGridSize.cols,
      players: players,
    );

    ref.read(matchConfigProvider.notifier).state = config;
    ref.read(gameStateProvider.notifier).initialize(config);

    context.pushReplacement('/local_match');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Match Setup',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const ConstellationBackground(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildSectionTitle('GRID SIZE'),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: _buildGridSizeSelector(),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('LOBBY'),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.95,
                        ),
                    itemCount: _selectedGridSize == GridSizeOption.small
                        ? 2
                        : 4,
                    itemBuilder: (context, index) {
                      if (index < _playerCount) {
                        return _buildActivePlayerCard(index);
                      }
                      return _buildAddPlayerCard();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: AuthButton(
                    text: 'START MATCH',
                    icon: const Icon(Icons.play_arrow_rounded),
                    style: AuthButtonStyle.primary,
                    onPressed: _startMatch,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                const Color(0xFFD4A44C).withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFD4A44C),
            letterSpacing: 6,
          ),
        ),
        const SizedBox(width: 16),
        Container(
          width: 48,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFD4A44C).withValues(alpha: 0.8),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridSizeSelector() {
    return Row(
      children: GridSizeOption.values.map((option) {
        final isSelected = _selectedGridSize == option;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedGridSize = option;
                  if (option == GridSizeOption.small) {
                    while (_playerCount > 2) {
                      final lastIndex = _playerCount - 1;
                      _nameControllers[lastIndex].dispose();
                      _nameControllers.removeAt(lastIndex);
                      _selectedColors.removeAt(lastIndex);
                      _isAi.removeAt(lastIndex);
                      _aiDifficulties.removeAt(lastIndex);
                      _playerCount--;
                    }
                  }
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFD4A44C).withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.05),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFD4A44C)
                            : Colors.white.withValues(alpha: 0.15),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      option.label,
                      style: GoogleFonts.outfit(
                        color: isSelected
                            ? const Color(0xFFD4A44C)
                            : Colors.white70,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActivePlayerCard(int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _selectedColors[index].withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _selectedColors[index],
                      boxShadow: [
                        BoxShadow(
                          color: _selectedColors[index].withValues(alpha: 0.6),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                  if (index >= 2)
                    GestureDetector(
                      onTap: () => _removePlayer(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameControllers[index],
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: _isAi[index]
                      ? 'Bot ${index + 1}'
                      : 'Player ${index + 1}',
                  hintStyle: GoogleFonts.outfit(color: Colors.white38),
                ),
              ),
              if (index != 0) ...[
                const SizedBox(height: 8),
                PopupMenuButton<String>(
                  color: const Color(0xFF1A1A1A),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  onSelected: (val) {
                    setState(() {
                      if (val == 'human') {
                        _isAi[index] = false;
                        if (_nameControllers[index].text ==
                            'Bot ${index + 1}') {
                          _nameControllers[index].text = 'Player ${index + 1}';
                        }
                      } else {
                        _isAi[index] = true;
                        _aiDifficulties[index] = AiDifficulty.values.firstWhere(
                          (d) => d.name == val,
                        );
                        if (_nameControllers[index].text ==
                            'Player ${index + 1}') {
                          _nameControllers[index].text = 'Bot ${index + 1}';
                        }
                      }
                    });
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'human',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person_rounded,
                            size: 16,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Human',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    ...AiDifficulty.values.map((diff) {
                      final isSelected =
                          _isAi[index] && _aiDifficulties[index] == diff;
                      return PopupMenuItem(
                        value: diff.name,
                        child: Row(
                          children: [
                            Icon(
                              Icons.smart_toy_rounded,
                              size: 16,
                              color: isSelected
                                  ? const Color(0xFFD4A44C)
                                  : Colors.white54,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Bot: ${diff.name.toUpperCase()}',
                              style: GoogleFonts.inter(
                                color: isSelected
                                    ? const Color(0xFFD4A44C)
                                    : Colors.white70,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _isAi[index]
                          ? _selectedColors[index].withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isAi[index]
                                ? Icons.smart_toy_rounded
                                : Icons.person_rounded,
                            size: 14,
                            color: _isAi[index]
                                ? _selectedColors[index]
                                : Colors.white70,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isAi[index]
                                ? 'Bot: ${_aiDifficulties[index].name}'
                                : 'Human',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              color: _isAi[index]
                                  ? _selectedColors[index]
                                  : Colors.white70,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 14,
                            color: _isAi[index]
                                ? _selectedColors[index]
                                : Colors.white70,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: kPlayerColors.map((color) {
                  final isSelected = _selectedColors[index] == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColors[index] = color;
                      });
                    },
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.6),
                                  blurRadius: 8,
                                ),
                              ]
                            : [],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddPlayerCard() {
    final isDisabled =
        _selectedGridSize == GridSizeOption.small && _playerCount >= 2;
    return InkWell(
      onTap: isDisabled
          ? () {
              SplodeSnackbar.show(
                context: context,
                message: 'Small grids only support up to 2 players.',
                type: SnackbarType.info,
              );
            }
          : _addPlayer,
      borderRadius: BorderRadius.circular(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white54,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Add Player',
                  style: GoogleFonts.outfit(
                    color: Colors.white54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
