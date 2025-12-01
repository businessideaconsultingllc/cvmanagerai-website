import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/profile/presentation/profile_completion_screen.dart';
import '../../features/profile/presentation/profile_controller.dart';
import '../../features/cv/presentation/generate_cv_screen.dart';
import '../../features/cv/presentation/cv_preview_screen.dart';
import '../../features/cv/presentation/optimize_cv_screen.dart';
import '../../features/cv/presentation/tailor_cv_screen.dart';
import '../../features/cv/presentation/edit_cv_screen.dart';
import '../../features/cv/domain/cv_model.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/credits/presentation/credit_history_screen.dart';
import '../../features/cover_letter/presentation/generate_cover_letter_screen.dart';
import '../../features/cover_letter/presentation/cover_letter_preview_screen.dart';
import '../../features/cover_letter/domain/cover_letter_model.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/splash/presentation/language_selection_splash_screen.dart';
import '../../features/splash/presentation/features_intro_screen.dart';
import '../../features/files/presentation/my_files_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../core/providers/first_launch_provider.dart';
import '../../features/admin/presentation/admin_panel_screen.dart';
import '../../features/admin/presentation/user_management_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(
        ref.watch(authRepositoryProvider).authStateChanges),
    redirect: (context, state) async {
      // Check if this is the first launch
      final firstLaunchAsync = ref.watch(firstLaunchProvider);
      final isFirstLaunch = firstLaunchAsync.value ?? true;

      // Allow splash screens to be accessed directly
      if (state.uri.path == '/language-selection' ||
          state.uri.path == '/features-intro') {
        return null;
      }

      // Redirect to language selection on first launch
      if (isFirstLaunch) {
        return '/language-selection';
      }

      final isLoggedIn = authState.valueOrNull?.session != null;
      final isLoggingIn =
          state.uri.path == '/login' || state.uri.path == '/signup';
      final isOnboarding = state.uri.path == '/onboarding';

      if (!isLoggedIn) {
        // Allow access to login, signup, and onboarding
        if (isLoggingIn || isOnboarding) {
          return null;
        }
        // Default to onboarding for non-logged-in users
        return '/onboarding';
      }

      // Check if profile is complete
      if (isLoggedIn) {
        final profileAsync = ref.watch(profileProvider);

        // Only redirect if we have data and it's incomplete
        if (!profileAsync.isLoading &&
            !profileAsync.hasError &&
            profileAsync.hasValue) {
          final profile = profileAsync.value;
          // If profile is null (fetch failed or no profile), we might want to handle it.
          // Assuming profile exists if user is logged in (trigger creates it).

          if (profile != null) {
            final firstName = profile['first_name'] as String?;
            final isProfileIncomplete = firstName == null || firstName.isEmpty;

            if (isProfileIncomplete) {
              if (state.uri.path != '/profile-completion') {
                return '/profile-completion';
              }
            } else {
              // Profile is complete
              if (state.uri.path == '/profile-completion' ||
                  state.uri.path == '/onboarding' ||
                  state.uri.path == '/login' ||
                  state.uri.path == '/signup') {
                return '/';
              }
            }
          }
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/language-selection',
        builder: (context, state) => const LanguageSelectionSplashScreen(),
      ),
      GoRoute(
        path: '/features-intro',
        builder: (context, state) => const FeaturesIntroScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/profile-completion',
        builder: (context, state) => const ProfileCompletionScreen(),
      ),
      GoRoute(
        path: '/generate-cv',
        builder: (context, state) => const GenerateCVScreen(),
      ),
      GoRoute(
        path: '/cv-preview',
        builder: (context, state) {
          final cvModel = state.extra as CVModel;
          return CVPreviewScreen(cvModel: cvModel);
        },
      ),
      GoRoute(
        path: '/optimize-cv',
        builder: (context, state) => const OptimizeCVScreen(),
      ),
      GoRoute(
        path: '/tailor-cv',
        builder: (context, state) => const TailorCVScreen(),
      ),
      GoRoute(
        path: '/edit-cv',
        builder: (context, state) {
          final cvModel = state.extra as CVModel;
          return EditCVScreen(cvModel: cvModel);
        },
      ),
      GoRoute(
        path: '/credit-history',
        builder: (context, state) => const CreditHistoryScreen(),
      ),
      GoRoute(
        path: '/generate-cover-letter',
        builder: (context, state) => const GenerateCoverLetterScreen(),
      ),
      GoRoute(
        path: '/cover-letter-preview',
        builder: (context, state) {
          final coverLetter = state.extra as CoverLetterModel;
          return CoverLetterPreviewScreen(coverLetter: coverLetter);
        },
      ),
      GoRoute(
        path: '/my-files',
        builder: (context, state) => const MyFilesScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminPanelScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const UserManagementScreen(),
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
