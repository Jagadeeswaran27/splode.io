import 'package:flutter/material.dart';

import 'package:client/presentation/core/utils/responsive_layout.dart';

/// Centers its child and constrains its maximum horizontal width.
///
/// Prevents UI elements (such as auth cards, module lists, and menus)
/// from stretching awkwardly across wide tablet and desktop viewports,
/// while maintaining standard mobile margin behavior.
class ResponsiveContentContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;

  const ResponsiveContentContainer({
    super.key,
    required this.child,
    this.maxWidth = SplodeBreakpoints.maxContentWidth,
    this.padding = EdgeInsets.zero,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

