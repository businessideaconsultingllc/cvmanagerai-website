import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../profile/presentation/profile_controller.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../cv/data/cv_repository.dart';
import '../../credits/presentation/credits_provider.dart';
import '../../admin/presentation/admin_controller.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/ads/banner_ad_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final isAdminAsync = ref.watch(isAdminProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(profileProvider);
          ref.invalidate(userCVsProvider);
          ref.invalidate(creditBalanceProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120.0,
              floating: true,
              pinned: true,
              backgroundColor: theme.scaffoldBackgroundColor,
              surfaceTintColor: theme.scaffoldBackgroundColor,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                title: Text(
                  l10n.appTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.05),
                        theme.scaffoldBackgroundColor,
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.language),
                  color: theme.colorScheme.onSurface,
                  onPressed: () => _showLanguageSelector(context, ref),
                ),
                IconButton(
                  icon: Icon(
                    theme.brightness == Brightness.dark
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    color: theme.colorScheme.onSurface,
                  ),
                  onPressed: () {
                    ref.read(themeProvider.notifier).toggleTheme();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.logout, color: theme.colorScheme.onSurface),
                  onPressed: () {
                    ref.read(authControllerProvider.notifier).signOut();
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Responsive.constrainWidth(
                context: context,
                child: Padding(
                  padding: EdgeInsets.all(Responsive.getPadding(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Welcome Message
                      profileAsync.when(
                        data: (profile) => Text(
                          '${l10n.welcomeBack}, ${profile?['first_name'] ?? 'User'}!',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ).animate().fadeIn().slideX(),
                        loading: () => const SizedBox(height: 24),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 16),

                      // Credits Card
                      _buildCreditsCard(context, ref, l10n),
                      const SizedBox(height: 32),

                      Text(
                        l10n.quickActions,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 16),

                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: Responsive.getGridColumns(context),
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.0,
                        ),
                        itemCount:
                            6 + (isAdminAsync.valueOrNull == true ? 1 : 0),
                        itemBuilder: (context, index) {
                          final cards = [
                            _ActionCard(
                              title: l10n.generateCV,
                              description: l10n.createFromScratch,
                              icon: Icons.add_circle_outline,
                              color: theme.colorScheme.primary,
                              onTap: () => context.push('/generate-cv'),
                              delay: 300,
                            ),
                            _ActionCard(
                              title: l10n.optimizeCV,
                              description: l10n.improveExisting,
                              icon: Icons.auto_fix_high_outlined,
                              color: Colors.purple,
                              onTap: () => context.push('/optimize-cv'),
                              delay: 400,
                            ),
                            _ActionCard(
                              title: l10n.tailorCV,
                              description: l10n.matchJobDesc,
                              icon: Icons.tune,
                              color: Colors.orange,
                              onTap: () => context.push('/tailor-cv'),
                              delay: 500,
                            ),
                            _ActionCard(
                              title: l10n.coverLetter,
                              description: l10n.writePerfectly,
                              icon: Icons.mail_outline,
                              color: Colors.teal,
                              onTap: () =>
                                  context.push('/generate-cover-letter'),
                              delay: 600,
                            ),
                            _ActionCard(
                              title: l10n.myFiles,
                              description: l10n.myFilesDescription,
                              icon: Icons.folder_outlined,
                              color: Colors.blue,
                              onTap: () => context.push('/my-files'),
                              delay: 700,
                            ),
                            _ActionCard(
                              title: l10n.profile,
                              description: l10n.profileDescription,
                              icon: Icons.person_outline,
                              color: Colors.indigo,
                              onTap: () => context.push('/profile'),
                              delay: 800,
                            ),
                          ];

                          if (isAdminAsync.valueOrNull == true && index == 6) {
                            return _ActionCard(
                              title: l10n.adminPanel,
                              description: l10n.adminPanelDescription,
                              icon: Icons.admin_panel_settings,
                              color: Colors.red,
                              onTap: () => context.push('/admin'),
                              delay: 900,
                            );
                          }

                          return cards[index];
                        },
                      ),

                      // Banner Ad
                      const SizedBox(height: 20),
                      const BannerAdWidget(),

                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.recentCVs,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.push('/my-files');
                            },
                            child: Text(l10n.viewAll),
                          ),
                        ],
                      ).animate().fadeIn(delay: 700.ms),
                      const SizedBox(height: 12),
                      _buildRecentCVs(context, ref, l10n),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCVs(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final cvsAsync = ref.watch(userCVsProvider);
    final theme = Theme.of(context);

    return cvsAsync.when(
      data: (cvs) {
        if (cvs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(Icons.description_outlined,
                      size: 48,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noCVsYet,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 800.ms);
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cvs.take(3).length, // Show only top 3
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final cv = cvs[index];
            return Card(
              elevation: 0,
              color: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.1)),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.description,
                    color: theme.colorScheme.primary,
                  ),
                ),
                title: Text(
                  cv.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${l10n.created}: ${cv.createdAt.toString().split(' ')[0]}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                onTap: () {
                  context.push('/cv-preview', extra: cv);
                },
              ),
            ).animate().fadeIn(delay: (800 + (index * 100)).ms).slideX();
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${l10n.error}: $e')),
    );
  }

  Widget _buildCreditsCard(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final balanceAsync = ref.watch(creditBalanceProvider);
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/credit-history'),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.bolt,
                              color: Colors.yellow, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            l10n.proPlan,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.history,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.availableCredits,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                balanceAsync.when(
                  data: (balance) => Text(
                    '$balance',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                  loading: () => const SizedBox(
                    height: 40,
                    width: 40,
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  error: (_, __) => Text(l10n.error,
                      style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.tapToViewHistory,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  void _showLanguageSelector(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.read(localeProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.selectLanguage,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: LocaleNotifier.supportedLocales.length,
                itemBuilder: (context, index) {
                  final localeOption = LocaleNotifier.supportedLocales[index];
                  return ListTile(
                    leading: Text(
                      localeOption.flag,
                      style: const TextStyle(fontSize: 28),
                    ),
                    title: Text(
                      localeOption.nativeName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: currentLocale == localeOption.locale
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      localeOption.name,
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: currentLocale == localeOption.locale
                        ? Icon(Icons.check, color: theme.colorScheme.primary)
                        : null,
                    onTap: () {
                      ref
                          .read(localeProvider.notifier)
                          .setLocale(localeOption.locale);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int delay;

  const _ActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 28, color: color),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.2, end: 0);
  }
}
