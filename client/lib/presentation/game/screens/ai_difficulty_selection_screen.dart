import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:client/domain/models/ai_difficulty.dart';
import 'package:client/domain/models/match_config.dart';
import 'package:client/presentation/core/providers/connectivity_provider.dart';
import 'package:client/presentation/core/widgets/auth_button.dart';
import 'package:client/presentation/core/widgets/constellation_background.dart';
import 'package:client/presentation/game/providers/game_provider.dart';
import 'package:client/presentation/game/screens/offline_match_setup_screen.dart';

class AiDifficultySelectionScreen extends ConsumerStatefulWidget {
  const AiDifficultySelectionScreen({super.key});

  @override
  ConsumerState<AiDifficultySelectionScreen> createState() =>
      _AiDifficultySelectionScreenState();
}

class _AiDifficultySelectionScreenState
    extends ConsumerState<AiDifficultySelectionScreen> {
  late final PageController _pageController;
  int _currentIndex = 1; // Default to Medium
  GridSizeOption _selectedGridSize = GridSizeOption.medium;
  bool _isRankedModeEnabled = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.7,
      initialPage: _currentIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startBotMatch() {
    final difficulty = AiDifficulty.values[_currentIndex];
    final data = _difficulties[difficulty]!;

    final config = MatchConfig(
      rows: _selectedGridSize.rows,
      cols: _selectedGridSize.cols,
      players: [
        const PlayerConfig(
          id: 'p1',
          name: 'Player 1',
          color: Color(0xFFD4A44C),
        ),
        PlayerConfig(
          id: 'p2',
          name: data.botName,
          color: data.color,
          isAi: true,
          aiDifficulty: difficulty,
        ),
      ],
      isRanked:
          _isRankedModeEnabled &&
          (difficulty == AiDifficulty.hard ||
              difficulty == AiDifficulty.expert),
    );

    ref.read(matchConfigProvider.notifier).state = config;
    ref.read(gameStateProvider.notifier).initialize(config);

    context.pushReplacement('/local_match');
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(connectivityProvider).value ?? false;
    final selectedDifficulty = AiDifficulty.values[_currentIndex];
    final isHardOrExpert =
        selectedDifficulty == AiDifficulty.hard ||
        selectedDifficulty == AiDifficulty.expert;

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
          'SELECT OPPONENT',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            fontSize: 14,
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

                // Section title
                _buildSectionTitle('SLIDE TO CHANGE DIFFICULTY'),

                const SizedBox(height: 16),

                // Carousel
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (idx) {
                      setState(() {
                        _currentIndex = idx;
                      });
                    },
                    itemCount: AiDifficulty.values.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, _) {
                          double distance = 0.0;
                          if (_pageController.position.haveDimensions) {
                            distance = (_pageController.page! - index).abs();
                          } else {
                            distance = index == _currentIndex ? 0.0 : 1.0;
                          }
                          distance = distance.clamp(0.0, 1.0);

                          final interpolation = 1.0 - distance;
                          final scale = 0.75 + (0.25 * interpolation);

                          return Center(
                            child: SizedBox(
                              height:
                                  Curves.easeOutCubic.transform(scale) * 460,
                              child: _buildCarouselCard(
                                AiDifficulty.values[index],
                                interpolation,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                // Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(AiDifficulty.values.length, (index) {
                    final isSelected = index == _currentIndex;
                    final difficulty = AiDifficulty.values[index];
                    final color = _difficulties[difficulty]!.color;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: isSelected ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color
                            : Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.5),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 16),

                // Ranked Toggle
                _buildRankedToggle(isOnline, isHardOrExpert),

                const SizedBox(height: 16),

                // Start Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: AuthButton(
                    text: 'START MATCH',
                    icon: const Icon(Icons.play_arrow_rounded),
                    style: AuthButtonStyle.primary,
                    onPressed: _startBotMatch,
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankedToggle(bool isOnline, bool isHardOrExpert) {
    if (!isHardOrExpert) {
      return const SizedBox(height: 72); // Keep height consistent when hidden
    }

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events_rounded,
                color: isOnline ? const Color(0xFFD4A44C) : Colors.white24,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'RANKED MODE (EARN BP)',
                style: GoogleFonts.outfit(
                  color: isOnline ? Colors.white : Colors.white38,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 16),
              Switch(
                value: _isRankedModeEnabled && isOnline,
                onChanged: isOnline
                    ? (val) => setState(() => _isRankedModeEnabled = val)
                    : null,
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFFD4A44C),
                inactiveThumbColor: Colors.white24,
                inactiveTrackColor: Colors.white10,
              ),
            ],
          ),
          if (!isOnline)
            Text(
              'Go online to earn BP',
              style: GoogleFonts.inter(
                color: Colors.redAccent.withValues(alpha: 0.8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
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
                letterSpacing: 4,
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
        ),
      ),
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
              onTap: () => setState(() => _selectedGridSize = option),
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

  Widget _buildCarouselCard(AiDifficulty difficulty, double interpolation) {
    final data = _difficulties[difficulty]!;

    final bgColor = Color.lerp(
      Colors.white.withValues(alpha: 0.03),
      data.color.withValues(alpha: 0.12),
      interpolation,
    )!;
    final borderColor = Color.lerp(
      Colors.white.withValues(alpha: 0.08),
      data.color.withValues(alpha: 0.5),
      interpolation,
    )!;
    final borderWidth = lerpDouble(1.0, 2.0, interpolation)!;
    final shadowColor = Color.lerp(
      Colors.transparent,
      data.color.withValues(alpha: 0.2),
      interpolation,
    )!;

    return GestureDetector(
      onTap: () {
        if (interpolation < 1.0) {
          final index = AiDifficulty.values.indexOf(difficulty);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: [
            BoxShadow(color: shadowColor, blurRadius: 40, spreadRadius: -10),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Danger Level Equalizer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) {
                      final isFilled = i < data.dangerLevel;
                      final dotColor = isFilled
                          ? Color.lerp(
                              Colors.white38,
                              data.color,
                              interpolation,
                            )
                          : Colors.white.withValues(alpha: 0.1);
                      final dotShadow = isFilled
                          ? Color.lerp(
                              Colors.transparent,
                              data.color,
                              interpolation,
                            )
                          : Colors.transparent;
                      return Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: dotColor,
                          boxShadow: [
                            BoxShadow(color: dotShadow!, blurRadius: 8),
                          ],
                        ),
                      );
                    }),
                  ),

                  const Spacer(),

                  // Bot Icon & Name
                  Transform.scale(
                    scale: lerpDouble(0.8, 1.0, interpolation)!,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: data.color.withValues(alpha: 0.1),
                        border: Border.all(
                          color: data.color.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Icon(
                        Icons.smart_toy_rounded,
                        size: 64,
                        color: Color.lerp(
                          Colors.white54,
                          data.color,
                          interpolation,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    data.botName.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color.lerp(
                        Colors.white60,
                        data.color,
                        interpolation,
                      ),
                      letterSpacing: 4,
                    ),
                  ),

                  const Spacer(),

                  // Shiny BP Badge if applicable
                  if (difficulty == AiDifficulty.hard ||
                      difficulty == AiDifficulty.expert) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: data.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: data.color.withValues(alpha: 0.5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: data.color.withValues(alpha: 0.3),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_fire_department_rounded,
                            color: data.color,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            difficulty == AiDifficulty.expert
                                ? '+20 BP'
                                : '+10 BP',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Difficulty Label & Subtitle
                  Text(
                    data.label,
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data.subtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DifficultyData {
  final String label;
  final String botName;
  final String subtitle;
  final Color color;
  final int dangerLevel;

  const _DifficultyData({
    required this.label,
    required this.botName,
    required this.subtitle,
    required this.color,
    required this.dangerLevel,
  });
}

const _difficulties = <AiDifficulty, _DifficultyData>{
  AiDifficulty.easy: _DifficultyData(
    label: 'EASY',
    botName: 'Chaos Bot',
    subtitle: 'Plays randomly.\nHighly unpredictable.',
    color: Color(0xFF3B82F6),
    dangerLevel: 1,
  ),
  AiDifficulty.medium: _DifficultyData(
    label: 'MEDIUM',
    botName: 'Greedy Bot',
    subtitle: 'Looks 1 move ahead.\nPrioritizes immediate gain.',
    color: Color(0xFF14B8A6),
    dangerLevel: 2,
  ),
  AiDifficulty.hard: _DifficultyData(
    label: 'HARD',
    botName: 'Tactician Bot',
    subtitle: 'Thinks 3 moves ahead.\nExploits tactical weaknesses.',
    color: Color(0xFF8B5CF6),
    dangerLevel: 3,
  ),
  AiDifficulty.expert: _DifficultyData(
    label: 'EXPERT',
    botName: 'Grandmaster Bot',
    subtitle: 'Evaluates thousands of futures.\nUtterly unforgiving.',
    color: Color(0xFFF43F5E),
    dangerLevel: 4,
  ),
};
