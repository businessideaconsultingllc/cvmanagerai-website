import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../utils/responsive.dart';
import '../../features/admin/presentation/admin_controller.dart';
import '../../features/feedback/presentation/feedback_dialog.dart';

/// Navigation item data class
class NavigationItem {
  final String label;
  final IconData icon;
  final String route;

  const NavigationItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}

/// Responsive navigation bar that adapts to mobile and web
class AppNavigationBar extends ConsumerWidget {
  final String currentRoute;

  const AppNavigationBar({
    super.key,
    required this.currentRoute,
  });

  List<NavigationItem> _getNavigationItems(
    AppLocalizations l10n,
    bool isAdmin,
  ) {
    final items = [
      NavigationItem(
        label: l10n.home,
        icon: Icons.home_outlined,
        route: '/',
      ),
      NavigationItem(
        label: l10n.generateCV,
        icon: Icons.auto_awesome_outlined,
        route: '/generate-cv',
      ),
      NavigationItem(
        label: l10n.optimizeCV,
        icon: Icons.analytics_outlined,
        route: '/optimize-cv',
      ),
      NavigationItem(
        label: l10n.checkATSScore,
        icon: Icons.speed_outlined,
        route: '/check-ats-score',
      ),
      NavigationItem(
        label: l10n.tailorCV,
        icon: Icons.tune_outlined,
        route: '/tailor-cv',
      ),
      NavigationItem(
        label: l10n.coverLetter,
        icon: Icons.mail_outline,
        route: '/generate-cover-letter',
      ),
      NavigationItem(
        label: l10n.myFiles,
        icon: Icons.folder_outlined,
        route: '/my-files',
      ),
      NavigationItem(
        label: l10n.profile,
        icon: Icons.person_outline,
        route: '/profile',
      ),
      NavigationItem(
        label: l10n.creditHistory,
        icon: Icons.history,
        route: '/credit-history',
      ),
    ];

    if (isAdmin) {
      items.add(
        NavigationItem(
          label: l10n.adminPanel,
          icon: Icons.admin_panel_settings,
          route: '/admin',
        ),
      );
    }

    return items;
  }

  int _getSelectedIndex(List<NavigationItem> items) {
    for (int i = 0; i < items.length; i++) {
      if (currentRoute == items[i].route) {
        return i;
      }
    }
    return 0; // Default to home
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isAdminAsync = ref.watch(isAdminProvider);
    final isAdmin = isAdminAsync.valueOrNull ?? false;
    final items = _getNavigationItems(l10n, isAdmin);
    final selectedIndex = _getSelectedIndex(items);

    // Return null for mobile - we'll use a drawer instead
    if (Responsive.isMobile(context)) {
      return buildDrawer(context, items, selectedIndex);
    }

    // Return NavigationRail for tablet and desktop
    return buildNavigationRail(context, items, selectedIndex);
  }

  /// Build drawer for mobile
  Widget buildDrawer(
    BuildContext context,
    List<NavigationItem> items,
    int selectedIndex,
  ) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // App Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.description,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.appTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 32),
            // Navigation items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = index == selectedIndex;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Material(
                      color: Colors.transparent,
                      child: ListTile(
                        leading: Icon(
                          item.icon,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                        ),
                        title: Text(
                          item.label,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        selectedTileColor:
                            theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onTap: () {
                          Navigator.pop(context); // Close drawer
                          context.go(item.route);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.rate_review_outlined),
              title: const Text('Send Feedback'),
              onTap: () {
                Navigator.pop(context);
                showFeedbackDialog(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Build navigation rail for tablet and desktop
  Widget buildNavigationRail(
    BuildContext context,
    List<NavigationItem> items,
    int selectedIndex,
  ) {
    final theme = Theme.of(context);

    return NavigationRail(
      backgroundColor: theme.scaffoldBackgroundColor,
      selectedIndex: selectedIndex,
      labelType: NavigationRailLabelType.all,
      leading: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 32),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.description,
            color: theme.colorScheme.primary,
            size: 32,
          ),
        ),
      ),
      destinations: items.map((item) {
        return NavigationRailDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.icon),
          label: Text(item.label),
        );
      }).toList(),
      onDestinationSelected: (index) {
        context.go(items[index].route);
      },
      selectedIconTheme: IconThemeData(
        color: theme.colorScheme.primary,
        size: 28,
      ),
      unselectedIconTheme: IconThemeData(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        size: 24,
      ),
      selectedLabelTextStyle: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelTextStyle: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.15),
    );
  }
}
