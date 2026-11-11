import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:client/presentation/auth/providers/profile_provider.dart';
import 'package:client/presentation/core/providers/audio_provider.dart';

/// Top HUD bar on the main hub displaying the player's profile, BP ranking,
/// and quick actions (audio mute toggle).
class HubProfileHeader extends ConsumerWidget {
  const HubProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const amberGold = Color(0xFFD4A44C);
    final profileAsync = ref.watch(userProfileProvider);
    final audioCtrl = ref.watch(audioProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Profile Badge
          profileAsync.when(
            data: (profile) {
              if (profile == null) return const SizedBox.shrink();

              return Flexible(
                child: GestureDetector(
                  onTap: () => context.push('/profile'),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: amberGold.withValues(alpha: 0.15),
                        child: Icon(
                          profile.isGuest
                              ? Icons.person_outline_rounded
                              : Icons.person_rounded,
                          color: amberGold,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              profile.username,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${profile.blastPoints} BP',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: amberGold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const _SkeletonProfile(),
            error: (error, stack) => const SizedBox.shrink(),
          ),

          // Right: Audio Toggle
          IconButton(
            icon: Icon(
              audioCtrl.isMuted
                  ? Icons.volume_off_rounded
                  : Icons.volume_up_rounded,
              color: Colors.white70,
            ),
            onPressed: () {
              ref.read(audioProvider.notifier).toggleMute();
            },
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
        mainAxisSize: MainAxisSize.min,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: 44,
                height: 10,
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

