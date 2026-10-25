import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Standard AppBar widget used across all Splode screens.
///
/// Features transparent background, centered uppercase title with
/// Outfit w900 typography, letterSpacing 4, fontSize 14, and
/// a clean white back button.
class SplodeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final bool showLeading;
  final Color? backgroundColor;
  final Color? borderColor;

  const SplodeAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.onBack,
    this.actions,
    this.showLeading = true,
    this.backgroundColor,
    this.borderColor,
  }) : assert(
          title != null || titleWidget != null,
          'Either title or titleWidget must be provided',
        );

  @override
  Widget build(BuildContext context) {
    Widget? leadingWidget = leading;
    if (leadingWidget == null && showLeading) {
      leadingWidget = IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: onBack ?? () => context.pop(),
      );
    }

    return AppBar(
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leading: leadingWidget,
      centerTitle: true,
      title: titleWidget ??
          Text(
            (title ?? '').toUpperCase(),
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              fontSize: 14,
            ),
          ),
      actions: actions,
      shape: borderColor != null
          ? Border(
              bottom: BorderSide(
                color: borderColor!,
                width: 1.0,
              ),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
