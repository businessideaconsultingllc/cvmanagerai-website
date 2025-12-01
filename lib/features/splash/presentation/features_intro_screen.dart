import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/first_launch_provider.dart';
import '../../../core/theme/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FeaturesIntroScreen extends ConsumerStatefulWidget {
  const FeaturesIntroScreen({super.key});

  @override
  ConsumerState<FeaturesIntroScreen> createState() =>
      _FeaturesIntroScreenState();
}

class _FeaturesIntroScreenState extends ConsumerState<FeaturesIntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeIntro();
    }
  }

  void _skipIntro() {
    _completeIntro();
  }

  void _completeIntro() async {
    // Mark first launch as complete
    await ref.read(firstLaunchProvider.notifier).markFirstLaunchComplete();

    // Navigate to onboarding
    if (mounted) {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final features = [
      _FeatureData(
        icon: Icons.auto_awesome,
        title: l10n.featureTitle1,
        description: l10n.featureDesc1,
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
        ),
      ),
      _FeatureData(
        icon: Icons.trending_up,
        title: l10n.featureTitle2,
        description: l10n.featureDesc2,
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.purple.shade400],
        ),
      ),
      _FeatureData(
        icon: Icons.description,
        title: l10n.featureTitle3,
        description: l10n.featureDesc3,
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.pink.shade400],
        ),
      ),
      _FeatureData(
        icon: Icons.language,
        title: l10n.featureTitle4,
        description: l10n.featureDesc4,
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.teal.shade400],
        ),
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F9FA),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton(
                    onPressed: _skipIntro,
                    child: Text(
                      l10n.skip,
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: features.length,
                  itemBuilder: (context, index) {
                    return _FeaturePage(
                      feature: features[index],
                      pageIndex: index,
                    );
                  },
                ),
              ),

              // Page indicators
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    features.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 32 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppTheme.primaryColor
                            : AppTheme.primaryColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),

              // Next/Get Started button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.secondaryColor,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _currentPage == 3 ? l10n.letsGetStarted : l10n.next,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String title;
  final String description;
  final Gradient gradient;

  _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });
}

class _FeaturePage extends StatelessWidget {
  final _FeatureData feature;
  final int pageIndex;

  const _FeaturePage({
    required this.feature,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with gradient background
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: feature.gradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              feature.icon,
              size: 80,
              color: Colors.white,
            ),
          )
              .animate(delay: Duration(milliseconds: 100 * pageIndex))
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1, 1),
                duration: 600.ms,
                curve: Curves.elasticOut,
              )
              .fadeIn(),

          const SizedBox(height: 48),

          // Title
          Text(
            feature.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
            textAlign: TextAlign.center,
          )
              .animate(delay: Duration(milliseconds: 100 * pageIndex + 200))
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.3, end: 0),

          const SizedBox(height: 16),

          // Description
          Text(
            feature.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF718096),
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          )
              .animate(delay: Duration(milliseconds: 100 * pageIndex + 400))
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }
}
