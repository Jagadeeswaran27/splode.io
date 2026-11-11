import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:client/domain/models/tutorial_module.dart';
import 'package:client/presentation/core/utils/responsive_layout.dart';
import 'package:client/presentation/core/widgets/auth_button.dart';
import 'package:client/presentation/game/widgets/module_art_badge.dart';
import 'package:client/presentation/game/widgets/tutorial_card_affordance.dart';
import 'package:client/presentation/game/widgets/tutorial_card_pill.dart';
import 'package:client/presentation/game/widgets/tutorial_locked_banner.dart';

/// Expandable training module card for Splode.
///
/// In collapsed state, displays the module badge, index pill, step counter,
/// title, and expand/lock affordance (without description).
/// Tapping the card expands it to reveal the tactical description and action:
/// - Unlocked: Main CTA [AuthButton] with primary styling.
/// - Locked: Informative [TutorialLockedBanner] requirement banner.
class TutorialCard extends StatefulWidget {
  final TutorialModule module;
  final String? title;
  final String? description;
  final bool isUnlocked;
  final bool isCompleted;
  final bool? isExpanded;
  final ValueChanged<bool>? onExpansionChanged;
  final VoidCallback? onStart;
  final VoidCallback? onTap;

  const TutorialCard({
    super.key,
    required this.module,
    this.title,
    this.description,
    required this.isUnlocked,
    this.isCompleted = false,
    this.isExpanded,
    this.onExpansionChanged,
    this.onStart,
    this.onTap,
  });

  /// Factory constructor for backward compatibility with string [moduleId].
  factory TutorialCard.fromModuleId({
    Key? key,
    required String moduleId,
    String? moduleNumber,
    String? category,
    int? stepCount,
    String? title,
    String? description,
    required bool isUnlocked,
    bool isCompleted = false,
    bool? isExpanded,
    ValueChanged<bool>? onExpansionChanged,
    VoidCallback? onStart,
    VoidCallback? onTap,
  }) {
    return TutorialCard(
      key: key,
      module: TutorialModule.fromId(moduleId),
      title: title,
      description: description,
      isUnlocked: isUnlocked,
      isCompleted: isCompleted,
      isExpanded: isExpanded,
      onExpansionChanged: onExpansionChanged,
      onStart: onStart,
      onTap: onTap,
    );
  }

  String get effectiveModuleId => module.id;
  String get effectiveModuleNumber => module.moduleNumber;
  String get effectiveCategory => module.category;
  int get effectiveStepCount => module.stepCount;
  String get effectiveTitle => title ?? module.title;
  String get effectiveDescription => description ?? module.description;
  VoidCallback? get effectiveOnStart => onStart ?? onTap;

  @override
  State<TutorialCard> createState() => _TutorialCardState();
}

class _TutorialCardState extends State<TutorialCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _expandController;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _rotationAnimation;

  bool _internalExpanded = false;

  bool get _isExpanded => widget.isExpanded ?? _internalExpanded;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: (widget.isExpanded ?? false) ? 1.0 : 0.0,
    );

    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.fastOutSlowIn,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _expandController,
      curve: const Interval(0.25, 1.0, curve: Curves.easeOut),
      reverseCurve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.fastOutSlowIn),
    );
  }

  @override
  void didUpdateWidget(TutorialCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != null &&
        widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded!) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    final nextState = !_isExpanded;
    if (widget.onExpansionChanged != null) {
      widget.onExpansionChanged!(nextState);
    } else {
      setState(() {
        _internalExpanded = nextState;
      });
      if (nextState) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const amberGold = Color(0xFFD4A44C);

    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        final progress = _expandAnimation.value;
        return Container(
          decoration: _buildDecoration(amberGold, progress),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleTap,
              splashColor: widget.isUnlocked
                  ? amberGold.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.03),
              highlightColor: widget.isUnlocked
                  ? amberGold.withValues(alpha: 0.04)
                  : Colors.white.withValues(alpha: 0.02),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeaderRow(progress),
                    SizeTransition(
                      sizeFactor: _expandAnimation,
                      alignment: Alignment.topCenter,
                      child: _expandAnimation.isDismissed
                          ? const SizedBox.shrink()
                          : FadeTransition(
                              opacity: _fadeAnimation,
                              child: _buildExpandedContent(amberGold),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderRow(double progress) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ModuleArtBadge(
          moduleId: widget.effectiveModuleId,
          isUnlocked: widget.isUnlocked,
          size: 48,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TutorialCardPill(
                moduleNumber: widget.effectiveModuleNumber,
                stepCount: widget.effectiveStepCount,
                isUnlocked: widget.isUnlocked,
                bpReward: widget.module.bpReward,
                isCompleted: widget.isCompleted,
              ),
              const SizedBox(height: 5),
              Text(
                widget.effectiveTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: widget.isUnlocked ? Colors.white : Colors.white54,
                  letterSpacing: 0.25,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        TutorialCardAffordance(
          isUnlocked: widget.isUnlocked,
          isExpanded: _isExpanded,
          progress: progress,
          rotationAnimation: _rotationAnimation,
        ),
      ],
    );
  }

  Widget _buildExpandedContent(Color amberGold) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 1,
          margin: const EdgeInsets.only(top: 14, bottom: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.isUnlocked
                    ? amberGold.withValues(alpha: 0.28)
                    : Colors.white.withValues(alpha: 0.08),
                Colors.transparent,
              ],
            ),
          ),
        ),
        Text(
          widget.effectiveDescription,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
            color: widget.isUnlocked
                ? Colors.white.withValues(alpha: 0.85)
                : Colors.white38,
            height: 1.45,
            letterSpacing: 0.15,
          ),
        ),
        const SizedBox(height: 14),
        if (widget.isUnlocked)
          AuthButton(
            text: widget.isCompleted ? 'Replay Module' : 'Start Module',
            icon: Icon(
              widget.isCompleted
                  ? Icons.replay_rounded
                  : Icons.play_arrow_rounded,
            ),
            style: AuthButtonStyle.primary,
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: context.isShortScreen ? 9.0 : 11.5,
            ),
            fontSize: context.isShortScreen ? 14.0 : 14.5,
            iconSize: context.isShortScreen ? 18.0 : 20.0,
            onPressed: () {
              widget.effectiveOnStart?.call();
            },
          )
        else
          TutorialLockedBanner(
            previousModuleName:
                widget.module.previousModule?.title ?? 'previous module',
          ),
      ],
    );
  }

  BoxDecoration _buildDecoration(Color amberGold, double progress) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: widget.isUnlocked
            ? [
                const Color(0xFF1B1B26),
                Color.lerp(
                  const Color(0xFF13131B),
                  const Color(0xFF151520),
                  progress,
                )!,
              ]
            : [
                const Color(0xFF16161E).withValues(alpha: 0.65),
                const Color(0xFF101014).withValues(alpha: 0.65),
              ],
      ),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: widget.isUnlocked
            ? amberGold.withValues(alpha: 0.24 + 0.18 * progress)
            : Colors.white.withValues(alpha: 0.06),
        width: 1.2,
      ),
      boxShadow: widget.isUnlocked
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: amberGold.withValues(alpha: 0.06 + 0.06 * progress),
                blurRadius: 16,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
    );
  }
}
