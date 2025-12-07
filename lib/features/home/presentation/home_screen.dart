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
import '../../../core/theme/app_theme.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/ads/banner_ad_widget.dart';
import '../../../core/widgets/app_navigation_bar.dart';
import '../../../core/widgets/beautiful_components.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final isAdminAsync = ref.watch(isAdminProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isMobile = Responsive.isMobile(context);

    final scaffold = Scaffold(
      drawer: isMobile ? const AppNavigationBar(currentRoute: '/') : null,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(profileProvider);
          ref.invalidate(userCVsProvider);
          ref.invalidate(creditBalanceProvider);
        },
        child: CustomScrollView(
          slivers: [
            // ✨ Beautiful App Bar with Gradient
            SliverAppBar(
              expandedHeight: isMobile ? 140.0 : 160.0,
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: isMobile,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.only(
                  left: isMobile ? 56 : 24,
                  bottom: 16,
                ),
                title: ShaderMask(
                  shaderCallback: (bounds) =>
                      AppTheme.heroGradient.createShader(bounds),
                  child: Text(
                    l10n.appTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.1),
                        theme.colorScheme.secondary.withOpacity(0.05),
                        theme.scaffoldBackgroundColor,
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                // Language Selector
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.language),
                    tooltip: l10n.selectLanguage,
                    onPressed: () => _showLanguageSelector(context, ref),
                  ),
                ),
                // Theme Toggle
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      theme.brightness == Brightness.dark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                    ),
                    tooltip: 'Toggle theme',
                    onPressed: () {
                      ref.read(themeProvider.notifier).toggleTheme();
                    },
                  ),
                ),
                // Logout
                Container(
                  margin: EdgeInsets.only(right: isMobile ? 8 : 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.logout_rounded),
                    tooltip: 'Logout',
                    onPressed: () {
                      ref.read(authControllerProvider.notifier).signOut();
                    },
                  ),
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
                      // 👋 Welcome Section with Avatar
                      _buildWelcomeSection(context, ref, l10n, profileAsync),
                      const SizedBox(height: 24),

                      // 💳 Premium Credits Card
                      _buildPremiumCreditsCard(context, ref, l10n),
                      const SizedBox(height: 32),

                      // 📊 Quick Stats Row
                      _buildQuickStats(context, ref, l10n),
                      const SizedBox(height: 40),

                      // 🎯 Quick Actions Title
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l10n.quickActions,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                      const SizedBox(height: 20),

                      // 🎴 Action Cards Grid - BEAUTIFUL!
                      _buildActionCardsGrid(context, ref, l10n, isAdminAsync),

                      // Banner Ad
                      const SizedBox(height: 32),
                      const BannerAdWidget(),

                      const SizedBox(height: 40),

                      // 📄 Recent CVs Section
                      _buildRecentCVsSection(context, ref, l10n),
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

    // Wrap with navigation for desktop
    if (!isMobile) {
      return Row(
        children: [
          const AppNavigationBar(currentRoute: '/'),
          Expanded(child: scaffold),
        ],
      );
    }

    return scaffold;
  }

  /// 👋 Beautiful Welcome Section
  Widget _buildWelcomeSection(BuildContext context, WidgetRef ref,
      AppLocalizations l10n, AsyncValue<Map<String, dynamic>?> profileAsync) {
    final theme = Theme.of(context);

    return profileAsync.when(
      data: (profile) {
        if (profile == null) return const SizedBox.shrink();

        final firstName = profile['first_name'] ?? 'User';
        final email = profile['email'] ?? '';

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.surface,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar with gradient border
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  gradient: AppTheme.heroGradient,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: Text(
                      firstName[0].toUpperCase(),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.welcomeBack},',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      firstName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: 0.2);
      },
      loading: () => const SizedBox(height: 100),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// 💳 Premium Credits Card with Shine Effect
  Widget _buildPremiumCreditsCard(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final balanceAsync = ref.watch(creditBalanceProvider);
    final theme = Theme.of(context);

    return GradientCard(
      gradient: AppTheme.heroGradient,
      padding: const EdgeInsets.all(28),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt_rounded,
                            color: Colors.amber, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          l10n.proPlan,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.history_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                l10n.availableCredits,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              balanceAsync.when(
                data: (balance) => Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$balance',
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'credits',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
                loading: () => const SizedBox(
                  height: 50,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
                error: (_, __) => Text(
                  l10n.error,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: Colors.white70, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    l10n.tapToViewHistory,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      onTap: () => context.push('/credit-history'),
    ).animate().fadeIn(delay: 100.ms).scale(
          duration: 400.ms,
          curve: Curves.easeOutBack,
        );
  }

  /// 📊 Quick Stats Row
  Widget _buildQuickStats(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final cvsAsync = ref.watch(userCVsProvider);
    final isMobile = Responsive.isMobile(context);

    return cvsAsync.when(
      data: (cvs) {
        final totalCVs = cvs.length;
        final thisMonth = cvs.where((cv) {
          final now = DateTime.now();
          return cv.createdAt.month == now.month &&
              cv.createdAt.year == now.year;
        }).length;

        if (isMobile) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      '${totalCVs}',
                      'Total CVs',
                      Icons.description_rounded,
                      AppTheme.primaryIndigo,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      '$thisMonth',
                      'This Month',
                      Icons.calendar_today_rounded,
                      AppTheme.accentEmerald,
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                '$totalCVs',
                'Total CVs Created',
                Icons.description_rounded,
                AppTheme.primaryIndigo,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                context,
                '$thisMonth',
                'Created This Month',
                Icons.calendar_today_rounded,
                AppTheme.accentEmerald,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                context,
                '98%',
                'Success Rate',
                Icons.trending_up_rounded,
                AppTheme.accentCyan,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2);
      },
      loading: () => const SizedBox(height: 100),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return StatCard(
      value: value,
      label: label,
      icon: icon,
      color: color,
    );
  }

  /// 🎴 Action Cards Grid - The Star of the Show!
  Widget _buildActionCardsGrid(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    AsyncValue<bool> isAdminAsync,
  ) {
    final actionCards = [
      _ActionCardData(
        title: l10n.generateCV,
        description: l10n.createFromScratch,
        icon: Icons.add_circle_outline_rounded,
        color: AppTheme.primaryIndigo,
        route: '/generate-cv',
      ),
      _ActionCardData(
        title: l10n.optimizeCV,
        description: l10n.improveExisting,
        icon: Icons.auto_fix_high_rounded,
        color: AppTheme.primaryViolet,
        route: '/optimize-cv',
      ),
      _ActionCardData(
        title: l10n.tailorCV,
        description: l10n.matchJobDesc,
        icon: Icons.tune_rounded,
        color: AppTheme.accentCyan,
        route: '/tailor-cv',
      ),
      _ActionCardData(
        title: l10n.coverLetter,
        description: l10n.writePerfectly,
        icon: Icons.mail_outline_rounded,
        color: AppTheme.accentEmerald,
        route: '/generate-cover-letter',
      ),
      _ActionCardData(
        title: l10n.myFiles,
        description: l10n.myFilesDescription,
        icon: Icons.folder_open_rounded,
        color: AppTheme.primaryPink,
        route: '/my-files',
      ),
      _ActionCardData(
        title: l10n.profile,
        description: l10n.profileDescription,
        icon: Icons.person_outline_rounded,
        color: AppTheme.accentAmber,
        route: '/profile',
      ),
    ];

    if (isAdminAsync.valueOrNull == true) {
      actionCards.add(
        _ActionCardData(
          title: l10n.adminPanel,
          description: l10n.adminPanelDescription,
          icon: Icons.admin_panel_settings_rounded,
          color: AppTheme.errorRed,
          route: '/admin',
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.getGridColumns(context),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: actionCards.length,
      itemBuilder: (context, index) {
        final card = actionCards[index];
        return ActionCard(
          title: card.title,
          description: card.description,
          icon: card.icon,
          color: card.color,
          onTap: () => context.push(card.route),
        )
            .animate()
            .fadeIn(delay: (300 + (index * 50)).ms)
            .slideY(begin: 0.3, end: 0);
      },
    );
  }

  /// 📄 Recent CVs Section
  Widget _buildRecentCVsSection(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.recentCVs,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () => context.push('/my-files'),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(l10n.viewAll),
            ),
          ],
        ).animate().fadeIn(delay: 700.ms),
        const SizedBox(height: 16),
        _buildRecentCVsList(context, ref, l10n),
      ],
    );
  }

  Widget _buildRecentCVsList(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final cvsAsync = ref.watch(userCVsProvider);
    final theme = Theme.of(context);

    return cvsAsync.when(
      data: (cvs) {
        if (cvs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.noCVsYet,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your first CV to get started',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 800.ms);
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cvs.take(3).length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final cv = cvs[index];
            return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryIndigo.withOpacity(0.2),
                        AppTheme.primaryViolet.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.description_rounded,
                    color: AppTheme.primaryIndigo,
                    size: 24,
                  ),
                ),
                title: Text(
                  cv.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${l10n.created}: ${cv.createdAt.toString().split(' ')[0]}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
                onTap: () => context.push('/cv-preview', extra: cv),
              ),
            )
                .animate()
                .fadeIn(delay: (800 + (index * 100)).ms)
                .slideX(begin: 0.2);
          },
        );
      },
      loading: () => Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ShimmerLoading(
              width: double.infinity,
              height: 80,
              borderRadius: 20,
            ),
          ),
        ),
      ),
      error: (e, _) => Text('${l10n.error}: $e'),
    );
  }

  void _showLanguageSelector(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.read(localeProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.selectLanguage,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: LocaleNotifier.supportedLocales.length,
                itemBuilder: (context, index) {
                  final localeOption = LocaleNotifier.supportedLocales[index];
                  final isSelected = currentLocale == localeOption.locale;

                  return ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withOpacity(0.1)
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        localeOption.flag,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    title: Text(
                      localeOption.nativeName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      localeOption.name,
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: isSelected
                        ? Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          )
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

class _ActionCardData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;

  _ActionCardData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });
}
