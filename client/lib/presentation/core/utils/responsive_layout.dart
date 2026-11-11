import 'package:flutter/material.dart';

/// Semantic viewport size breakpoints used throughout Splode.
enum ResponsiveBreakpoint {
  /// Mobile phones in portrait mode (width < 600dp).
  compact,

  /// Tablets in portrait, foldables, or phones in landscape (600dp <= width < 900dp).
  medium,

  /// Desktop monitors or tablets in landscape (width >= 900dp).
  expanded;

  bool get isCompact => this == ResponsiveBreakpoint.compact;
  bool get isMedium => this == ResponsiveBreakpoint.medium;
  bool get isExpanded => this == ResponsiveBreakpoint.expanded;
}

/// Core breakpoint dimension thresholds.
abstract final class SplodeBreakpoints {
  static const double compact = 600.0;
  static const double expanded = 900.0;
  static const double shortScreenHeight = 560.0;

  // Maximum content widths to prevent unnatural stretching on wide viewports
  static const double maxFormWidth = 420.0;
  static const double maxMenuWidth = 380.0;
  static const double maxContentWidth = 640.0;
  static const double maxArenaWidth = 1100.0;
}

/// Convenience extensions on [BuildContext] for responsive layout decisions.
extension ResponsiveContext on BuildContext {
  /// Dimensions of the app window.
  Size get windowSize => MediaQuery.sizeOf(this);

  /// Width of the app window.
  double get screenWidth => windowSize.width;

  /// Height of the app window.
  double get screenHeight => windowSize.height;

  /// The active [ResponsiveBreakpoint] based on available width.
  ResponsiveBreakpoint get breakpoint {
    final width = screenWidth;
    if (width < SplodeBreakpoints.compact) return ResponsiveBreakpoint.compact;
    if (width < SplodeBreakpoints.expanded) return ResponsiveBreakpoint.medium;
    return ResponsiveBreakpoint.expanded;
  }

  /// Whether the current screen is in a compact (mobile portrait) form factor.
  bool get isCompact => breakpoint.isCompact;

  /// Whether the current screen is in a medium (tablet/large phone) form factor.
  bool get isMedium => breakpoint.isMedium;

  /// Whether the current screen is in an expanded (desktop/large tablet) form factor.
  bool get isExpanded => breakpoint.isExpanded;

  /// Whether the screen has a wide (medium or expanded) form factor.
  bool get isTabletOrDesktop => !isCompact;

  /// Whether the screen has limited vertical height (e.g. landscape phone or small display).
  bool get isShortScreen => screenHeight < SplodeBreakpoints.shortScreenHeight;

  /// Whether the viewport is wider than it is tall.
  bool get isLandscape => screenWidth > screenHeight;

  /// Selects a responsive value based on the active breakpoint.
  T responsiveValue<T>({
    required T compact,
    T? medium,
    T? expanded,
  }) {
    if (isExpanded && expanded != null) return expanded;
    if (isMedium && medium != null) return medium;
    return compact;
  }
}

