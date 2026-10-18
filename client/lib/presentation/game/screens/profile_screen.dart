import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:client/presentation/auth/providers/auth_provider.dart';
import 'package:client/presentation/auth/providers/profile_provider.dart';
import 'package:client/presentation/core/widgets/constellation_background.dart';
import 'package:client/presentation/game/providers/bot_history_provider.dart';
import 'package:client/presentation/game/services/bot_history_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(botMatchHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: Stack(
        children: [
          const ConstellationBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, ref),
                _buildProfileSection(context, ref),
                Padding(
                  padding: const EdgeInsets.only(left: 32, top: 24, bottom: 8),
                  child: Text(
                    'BATTLE LOG',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.5),
                      letterSpacing: 4,
                    ),
                  ),
                ),
                Expanded(
                  child: historyAsync.when(
                    data: (records) {
                      if (records.isEmpty) {
                        return _buildEmptyState();
                      }
                      return _buildTimeline(records);
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFD4A44C),
                      ),
                    ),
                    error: (err, stack) => Center(
                      child: Text(
                        'Failed to load history',
                        style: GoogleFonts.inter(color: Colors.white54),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Text(
            'PROFILE',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFD4A44C),
              letterSpacing: 8,
            ),
          ),
          const Spacer(),
          Consumer(
            builder: (context, ref, child) {
              final profileAsync = ref.watch(userProfileProvider);
              final isGuest = profileAsync.valueOrNull?.isGuest ?? false;

              return IconButton(
                icon: const Icon(
                  Icons.logout_rounded,
                  color: Colors.white70,
                ),
                onPressed: () async {
                  if (isGuest) {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: const Color(0xFF1A1A1A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: Colors.red.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          title: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Warning',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          content: Text(
                            'You are playing as a Guest. Logging out will permanently delete your progress. Are you sure you want to log out?',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => context.pop(false),
                              child: Text(
                                'CANCEL',
                                style: GoogleFonts.outfit(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.pop(true),
                              child: Text(
                                'LOGOUT',
                                style: GoogleFonts.outfit(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                    if (confirm != true) return;
                  }

                  await ref.read(authLogicProvider).signOut();
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      data: (profile) {
        if (profile == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(
                    0xFFD4A44C,
                  ).withValues(alpha: 0.15),
                  child: Icon(
                    profile.isGuest
                        ? Icons.person_outline_rounded
                        : Icons.person_rounded,
                    size: 40,
                    color: const Color(0xFFD4A44C),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  profile.username,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStat(
                      context,
                      'WINS',
                      profile.totalWins.toString(),
                      const Color(0xFFD4A44C),
                    ),
                    _buildStat(
                      context,
                      'LOSSES',
                      profile.totalLosses.toString(),
                      Colors.redAccent.withValues(alpha: 0.8),
                    ),
                    _buildStat(
                      context,
                      'BP',
                      profile.blastPoints.toString(),
                      Colors.blueAccent.withValues(alpha: 0.8),
                      onTap: () => _showBPInfoDialog(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFFD4A44C)),
      ),
      error: (e, s) => const SizedBox.shrink(),
    );
  }

  Widget _buildStat(
    BuildContext context,
    String label,
    String value,
    Color color, {
    VoidCallback? onTap,
  }) {
    Widget stat = Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white.withValues(alpha: 0.5),
                letterSpacing: 2,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ],
          ],
        ),
      ],
    );

    if (onTap != null) {
      stat = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: stat,
      );
    }

    return stat;
  }

  void _showBPInfoDialog(BuildContext context) {
    showDialog(
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
          title: Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                color: Color(0xFFD4A44C),
              ),
              const SizedBox(width: 12),
              Text(
                'Blast Points',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Blast Points (BP) are your competitive rating. Earn BP by winning matches against Hard or Expert bots.\n\nClimb the ranks and prove you are the ultimate Splode strategist!',
            style: GoogleFonts.inter(color: Colors.white70, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'GOT IT',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFD4A44C),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 64,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Text(
            'NO BATTLES RECORDED YET',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.4),
              letterSpacing: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(List<BotMatchRecord> records) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        final isWin = record.result == 'win';
        final nodeColor = isWin
            ? const Color(0xFFD4A44C)
            : Colors.redAccent.withValues(alpha: 0.6);

        final diffStr = record.difficulty
            .split('_')
            .map((e) => e[0].toUpperCase() + e.substring(1))
            .join(' ');

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline line and node
            Column(
              children: [
                Container(
                  width: 2,
                  height: 32,
                  color: index == 0
                      ? Colors.transparent
                      : Colors.white.withValues(alpha: 0.1),
                ),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: nodeColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: nodeColor.withValues(alpha: 0.5),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 2,
                  height: 80, // Approximate height to reach next item
                  color: index == records.length - 1
                      ? Colors.transparent
                      : Colors.white.withValues(alpha: 0.1),
                ),
              ],
            ),
            const SizedBox(width: 24),
            // Match Card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: nodeColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VS $diffStr Bot',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat(
                                'MMM d, h:mm a',
                              ).format(record.playedAt.toLocal()),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        isWin ? 'W' : 'L',
                        style: GoogleFonts.outfit(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: nodeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
