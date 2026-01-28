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
import '../../features/ats/presentation/ats_check_screen.dart';
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
import '../../features/cover_letter/presentation/edit_cover_letter_screen.dart';
import '../../features/cover_letter/domain/cover_letter_model.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/splash/presentation/language_selection_splash_screen.dart';
import '../../features/splash/presentation/features_intro_screen.dart';
import '../../features/files/presentation/my_files_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../core/providers/first_launch_provider.dart';
import '../../features/admin/presentation/admin_panel_screen.dart';
import '../../features/admin/presentation/user_management_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
// import '../../features/subscription/presentation/buy_credits_screen.dart';
import '../../core/widgets/main_layout.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  /// STABLE - DO NOT MODIFY
  /// This router configuration handles Auth Guards, Splash logic, and Redirects.
  /// It has been stabilized to work with Supabase Auth, Google Sign In, and Password Reset.
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(
        ref.watch(authRepositoryProvider).authStateChanges),
    redirect: (context, state) async {
      // CRITICAL: Wait for auth state to load from storage before making routing decisions
      // This prevents routing issues when session hasn't loaded yet on page refresh
      // Only wait if we have NO value yet - if we have a value (even if loading/refreshing), use it
      if (authState.isLoading && !authState.hasValue) {
        return null; // Stay on current route while auth state loads
      }

      // Check Uri.base for OAuth/auth parameters (these appear before the hash in web URLs)
      final uriBase = Uri.base;

      // Check authentication status - now safe because we waited for loading
      final isLoggedIn = authState.valueOrNull?.session != null;

      // Detect OAuth callback - Google/Supabase OAuth includes 'code' or 'access_token' in URL
      // CRITICAL: Only treat as OAuth callback if user is NOT already authenticated
      // If user is already logged in, the OAuth code is stale and should be ignored
      final hasOAuthCode = uriBase.queryParameters.containsKey('code');
      final hasAccessToken =
          uriBase.queryParameters.containsKey('access_token');
      final isOAuthCallback = !isLoggedIn && (hasOAuthCode || hasAccessToken);

      // Check for password recovery specifically (has type=recovery parameter)
      final isPasswordRecovery =
          (uriBase.queryParameters['type'] == 'recovery') ||
              (uriBase.fragment.contains('type=recovery'));

      // Check if this is the first launch
      final firstLaunchAsync = ref.read(firstLaunchProvider);
      final isFirstLaunch = firstLaunchAsync.value ?? true;

      // CRITICAL: If this is an OAuth callback or password recovery, bypass splash screens
      // OAuth/recovery flows should complete even if it's first launch
      if (!isOAuthCallback && !isPasswordRecovery) {
        // Allow splash screens and auth screens to be accessed directly
        // (but NOT if we're in an OAuth callback - those should proceed to completion)
        if (state.uri.path == '/language-selection' ||
            state.uri.path == '/features-intro' ||
            state.uri.path == '/login' ||
            state.uri.path == '/signup' ||
            state.uri.path == '/forgot-password' ||
            state.uri.path == '/reset-password' ||
            state.uri.path == '/onboarding') {
          return null;
        }
      }

      // isLoggedIn already defined above

      // Redirect to language selection on first launch ONLY if:
      // - Not authenticated
      // - Not in OAuth callback
      // - Not in password recovery
      if (isFirstLaunch &&
          !isLoggedIn &&
          !isOAuthCallback &&
          !isPasswordRecovery) {
        return '/language-selection';
      }
      final isLoggingIn = state.uri.path == '/login' ||
          state.uri.path == '/signup' ||
          state.uri.path == '/forgot-password' ||
          state.uri.path == '/reset-password';
      final isOnboarding = state.uri.path == '/onboarding';

      // Additional check for password reset errors
      // (password recovery type is already checked at the top with isPasswordRecovery)
      // (password recovery type is already checked at the top with isPasswordRecovery)

      // REMOVED: Strict redirect to /reset-password.
      // We rely on AuthRecoveryListener to handle the navigation when the event fires.
      // Keeping this block caused conflicts with the listener and malformed URLs.

      if (!isLoggedIn) {
        // Allow access to login, signup, forgot-password, reset-password, and onboarding
        if (isLoggingIn || isOnboarding) {
          return null;
        }
        // Default to login for non-logged-in users (changed from onboarding based on user feedback)
        // UNLESS they're in an OAuth callback - let that flow proceed
        if (!isOAuthCallback && !isPasswordRecovery) {
          return '/login';
        }
      }

      // REMOVED: Code parameter check that was causing Google OAuth redirects to fail
      // Google OAuth also uses 'code' parameter, so checking for it causes conflicts
      // Password recovery is now detected solely by type=recovery parameter above

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
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/profile-completion',
        builder: (context, state) => const ProfileCompletionScreen(),
      ),

      // Main Application Shell
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(state: state, child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/generate-cv',
            builder: (context, state) => const GenerateCVScreen(),
          ),
          GoRoute(
            path: '/check-ats-score',
            builder: (context, state) => const ATSCheckScreen(),
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
            builder: (context, state) {
              final initialNotes = state.extra as String?;
              return OptimizeCVScreen(initialNotes: initialNotes);
            },
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
            path: '/edit-cover-letter',
            builder: (context, state) {
              final coverLetter = state.extra as CoverLetterModel;
              return EditCoverLetterScreen(coverLetter: coverLetter);
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
          // GoRoute(
          //   path: '/buy-credits',
          //   builder: (context, state) => const BuyCreditsScreen(),
          // ),
        ],
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
