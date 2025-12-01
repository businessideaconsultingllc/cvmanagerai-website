import 'package:flutter/material.dart';

/// Responsive utility class to detect screen sizes and provide adaptive layouts
class Responsive {
  /// Check if current screen is mobile size (< 768px)
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  /// Check if current screen is tablet size (768px - 1024px)
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768 &&
        MediaQuery.of(context).size.width < 1024;
  }

  /// Check if current screen is desktop size (>= 1024px)
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  /// Get appropriate padding for current screen size
  static double getPadding(BuildContext context) {
    if (isDesktop(context)) return 24.0;
    if (isTablet(context)) return 20.0;
    return 16.0;
  }

  /// Get max content width for desktop (prevents excessive stretching)
  static double getMaxWidth(BuildContext context) {
    if (isDesktop(context)) return 1200;
    return double.infinity;
  }

  /// Get number of columns for grid layouts
  static int getGridColumns(BuildContext context) {
    if (isDesktop(context)) return 3;
    if (isTablet(context)) return 2;
    return 1;
  }

  /// Wrap content with max-width container for desktop
  static Widget constrainWidth({
    required BuildContext context,
    required Widget child,
    double? maxWidth,
  }) {
    if (!isDesktop(context)) return child;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? getMaxWidth(context),
        ),
        child: child,
      ),
    );
  }

  /// Build responsive value based on screen size
  static T value<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }
}

/// Widget that adapts its layout based on screen size
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) mobile;
  final Widget Function(BuildContext context)? tablet;
  final Widget Function(BuildContext context)? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (Responsive.isDesktop(context) && desktop != null) {
      return desktop!(context);
    }
    if (Responsive.isTablet(context) && tablet != null) {
      return tablet!(context);
    }
    return mobile(context);
  }
}
