import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/responsive.dart';
import 'app_navigation_bar.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;
  final GoRouterState state;

  const MainLayout({
    super.key,
    required this.child,
    required this.state,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = Responsive.isMobile(context);
    final currentRoute = state.uri.path;

    if (!isMobile) {
      return Row(
        children: [
          AppNavigationBar(currentRoute: currentRoute),
          Expanded(child: child),
        ],
      );
    }

    // On mobile, we just return the child.
    // The child screens (Scaffolds) should define their own Drawers if needed,
    // or we can wrap them here.
    // Ideally, we'd wrap them in a Scaffold with a Drawer, but handling the AppBar leading icon
    // for inner Scaffolds is complex without modifying each screen.
    // For now, we fix the Desktop Sidebar persistence.
    return child;
  }
}
