import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:client/presentation/core/providers/audio_provider.dart';
import 'package:client/presentation/core/providers/connectivity_provider.dart';
import 'package:client/presentation/core/utils/responsive_layout.dart';
import 'package:client/presentation/core/utils/splode_snackbar.dart';
import 'package:client/presentation/core/widgets/constellation_background.dart';
import 'package:client/presentation/core/widgets/responsive_content_container.dart';
import 'package:client/presentation/game/providers/bot_history_provider.dart';
import 'package:client/presentation/game/providers/game_provider.dart';
import 'package:client/presentation/game/providers/tutorial_progress_provider.dart';
import 'package:client/presentation/game/services/game_persistence_service.dart';
import 'package:client/presentation/game/widgets/hub_hero_bot_card.dart';
import 'package:client/presentation/game/widgets/hub_online_banner.dart';
import 'package:client/presentation/game/widgets/hub_profile_header.dart';
import 'package:client/presentation/game/widgets/hub_secondary_mode_tile.dart';
import 'package:client/presentation/game/widgets/resume_game_dialog.dart';

/// The central Tactical Command Hub screen for Splode.
///
/// Features:
/// - Top HUD profile bar with BP ranking, avatar, and audio settings.
/// - Hero combat tile for VS Bot (Ranked & Casual) with live BP incentive.
/// - 2-column secondary split tiles for Pass & Play and Training Academy.
/// - Bottom cyber-holographic banner for Online Multiplayer.
class LayoutSelectionScreen extends ConsumerStatefulWidget {
  const LayoutSelectionScreen({super.key});

  @override
  ConsumerState<LayoutSelectionScreen> createState() =>
      _LayoutSelectionScreenState();
}

class _LayoutSelectionScreenState extends ConsumerState<LayoutSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(audioProvider).playMenuMusic();
    });
  }

  Future<void> _handleGameModeSelection(bool isBotMatch) async {
    final persistenceService = ref.read(gamePersistenceServiceProvider);
    final savedGame = await persistenceService.loadSavedGame();

    if (savedGame != null) {
      final isSavedGameBot = savedGame.config.players.any((p) => p.isAi);
      if (isBotMatch == isSavedGameBot) {
        if (!mounted) return;
        final resume = await ResumeGameDialog.show(context);
        if (resume == true) {
          ref.read(matchConfigProvider.notifier).state = savedGame.config;
          ref.read(gameStateProvider.notifier).restoreState(savedGame.state);
          if (mounted) context.push('/local_match');
          return;
        } else {
          await persistenceService.clearSavedGame();
        }
      }
    }

    if (mounted) {
      if (isBotMatch) {
        context.push('/bot_setup');
      } else {
        context.push('/offline_setup');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(connectivityProvider).value ?? true;
    ref.watch(botHistorySyncProvider);

    final completedModules = ref.watch(tutorialProgressProvider);
    final earnedBp = completedModules.fold(0, (sum, m) => sum + m.bpReward);
    final isAcademyMastered = earnedBp >= 50;

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Animation
          const ConstellationBackground(),

          // Main Hub Cards — Vertically centered to the screen irrespective of other content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  20.0,
                  context.isShortScreen ? 64.0 : 16.0,
                  20.0,
                  16.0,
                ),
                child: ResponsiveContentContainer(
                  maxWidth: SplodeBreakpoints.maxMenuWidth,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Centered Game Title
                      Text(
                        'SPLODE.IO',
                        style: GoogleFonts.outfit(
                          fontSize: context.isShortScreen ? 28.0 : 34.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 8,
                        ),
                      ),

                      SizedBox(
                        height: context.isShortScreen ? 20.0 : 28.0,
                      ),

                      // 1. Online Multiplayer (Coming Soon)
                      HubOnlineBanner(
                        isOnline: isOnline,
                        onTap: () {
                          SplodeSnackbar.show(
                            context: context,
                            message: 'Online Multiplayer coming soon!',
                            type: SnackbarType.info,
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      // 2. Secondary Mode Row (Pass & Play + Academy)
                      Row(
                        children: [
                          // Left: Pass & Play
                          Expanded(
                            child: HubSecondaryModeTile(
                              icon: Icons.people_alt_rounded,
                              title: 'PASS & PLAY',
                              accentColor: Colors.white,
                              onTap: () =>
                                  _handleGameModeSelection(false),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Right: Academy (with 50 BP Bounty Tracking)
                          Expanded(
                            child: HubSecondaryModeTile(
                              icon: Icons.school_rounded,
                              badge: isAcademyMastered
                                  ? '✓ 50 BP'
                                  : (earnedBp > 0
                                      ? '$earnedBp/50 BP'
                                      : '+50 BP'),
                              title: 'ACADEMY',
                              accentColor: isAcademyMastered
                                  ? const Color(0xFFFFDF7D)
                                  : const Color(0xFFD4A44C),
                              onTap: () => context.push('/tutorial'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // 3. Play with Bot
                      HubHeroBotCard(
                        onTap: () => _handleGameModeSelection(true),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Top Floating Header & Warning Banner
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isOnline)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      color: const Color(0xFFD4A44C).withValues(alpha: 0.9),
                      child: Center(
                        child: Text(
                          'Offline Mode - Stats will sync when reconnected',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF111111),
                          ),
                        ),
                      ),
                    ),
                  const HubProfileHeader(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
