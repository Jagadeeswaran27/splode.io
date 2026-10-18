import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';


import 'package:client/presentation/auth/providers/profile_provider.dart';
import 'package:client/presentation/core/providers/audio_provider.dart';
import 'package:client/presentation/core/providers/connectivity_provider.dart';
import 'package:client/presentation/game/providers/bot_history_provider.dart';
import 'package:client/presentation/core/utils/splode_snackbar.dart';
import 'package:client/presentation/core/widgets/auth_button.dart';
import 'package:client/presentation/core/widgets/constellation_background.dart';
import 'package:client/presentation/game/providers/game_provider.dart';
import 'package:client/presentation/game/services/game_persistence_service.dart';

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

    // Start background music when the screen loads (if not already playing)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioProvider).playMenuMusic();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handleGameModeSelection(bool isBotMatch) async {
    final persistenceService = ref.read(gamePersistenceServiceProvider);
    final savedGame = await persistenceService.loadSavedGame();

    if (savedGame != null) {
      final isSavedGameBot = savedGame.config.players.any((p) => p.isAi);
      if (isBotMatch == isSavedGameBot) {
        if (!mounted) return;
        final resume = await _showResumeDialog(context);
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

  Future<bool?> _showResumeDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: const Color(0xFFD4A44C).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          title: Text(
            'Resume Game?',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          content: Text(
            'You have an unfinished game in progress. Would you like to resume it?',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'New Game',
                style: GoogleFonts.inter(
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Resume',
                style: GoogleFonts.inter(
                  color: const Color(0xFFD4A44C),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch connectivity and initialize sync listener
    final isOnline = ref.watch(connectivityProvider).value ?? true;
    ref.watch(botHistorySyncProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Animation
          const ConstellationBackground(),

          // Foreground UI
          SafeArea(
            child: Column(
              children: [
                // Offline Banner
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
                // Top Header: Minimal Profile & Audio
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Profile Badge (Minimal)
                      Consumer(
                        builder: (context, ref, child) {
                          final profileAsync = ref.watch(userProfileProvider);
                          return profileAsync.when(
                            data: (profile) {
                              if (profile == null) {
                                return const SizedBox.shrink();
                              }
                              return GestureDetector(
                                onTap: () => context.push('/profile'),
                                behavior: HitTestBehavior.opaque,
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: const Color(
                                        0xFFD4A44C,
                                      ).withValues(alpha: 0.15),
                                      child: Icon(
                                        profile.isGuest
                                            ? Icons.person_outline_rounded
                                            : Icons.person_rounded,
                                        color: const Color(0xFFD4A44C),
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          profile.username,
                                          style: GoogleFonts.outfit(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              '${profile.blastPoints} BP',
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFFD4A44C),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(
                                              Icons.info_outline_rounded,
                                              size: 12,
                                              color: Colors.white38,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                            loading: () => const _SkeletonProfile(),
                            error: (error, stack) => const SizedBox.shrink(),
                          );
                        },
                      ),

                      // Actions (Audio & Logout)
                      Row(
                        children: [
                          Consumer(
                            builder: (context, ref, child) {
                              final audioCtrl = ref.watch(audioProvider);
                              return IconButton(
                                icon: Icon(
                                  audioCtrl.isMuted
                                      ? Icons.volume_off_rounded
                                      : Icons.volume_up_rounded,
                                  color: Colors.white70,
                                ),
                                onPressed: () {
                                  ref.read(audioProvider.notifier).toggleMute();
                                },
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.school_rounded,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              context.push('/tutorial');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Centered Logo / Title
                Text(
                  'SPLODE.IO',
                  style: GoogleFonts.outfit(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 10,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'SELECT COMBAT MODE',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFD4A44C),
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 64),

                // Minimal Game Mode Buttons
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: AuthButton(
                    text: 'Offline',
                    icon: const Icon(Icons.people_alt_rounded),
                    style: AuthButtonStyle.secondary,
                    onPressed: () {
                      _handleGameModeSelection(false);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Opacity(
                  opacity: isOnline ? 1.0 : 0.4,
                  child: IgnorePointer(
                    ignoring: !isOnline,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: AuthButton(
                        text: 'Online Multiplayer',
                        icon: Icon(
                          isOnline
                              ? Icons.public_rounded
                              : Icons.wifi_off_rounded,
                        ),
                        style: AuthButtonStyle.primary,
                        onPressed: () {
                          SplodeSnackbar.show(
                            context: context,
                            message: 'Coming Soon!',
                            type: SnackbarType.info,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: AuthButton(
                    text: 'Play with Bot',
                    icon: const Icon(Icons.smart_toy_rounded),
                    style: AuthButtonStyle.outline,
                    onPressed: () {
                      _handleGameModeSelection(true);
                    },
                  ),
                ),


                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonProfile extends StatefulWidget {
  const _SkeletonProfile();

  @override
  State<_SkeletonProfile> createState() => _SkeletonProfileState();
}

class _SkeletonProfileState extends State<_SkeletonProfile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.3,
        end: 0.7,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 40,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
