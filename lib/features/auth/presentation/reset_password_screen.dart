import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/beautiful_components.dart';
import '../../../core/utils/web_navigation/web_navigation.dart';

/// Screen for resetting the password.
///
/// CRITICAL: The logic in this screen, especially `_resetPassword` and `initState` recovery,
/// has been carefully tuned to handle redirect loops, double-slash URLs, and session race conditions.
/// DO NOT MODIFY the navigation or session recovery logic without extensive regression testing.
/// The current "Clean URL" + "JIT Recovery" + "SignOut-driven Redirect" flow is proven to work.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordStrength);

    // Verify recovery session and check for errors
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final uri = Uri.base;

      // First check for error parameters in the URL
      if (uri.queryParameters.containsKey('error_description')) {
        final errorDesc = uri.queryParameters['error_description'] ?? '';
        final decodedError = Uri.decodeComponent(errorDesc);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(decodedError.isEmpty
                  ? 'The password reset link has expired or is invalid. Please request a new one.'
                  : decodedError),
              backgroundColor: AppTheme.errorRed,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Request New Link',
                textColor: Colors.white,
                onPressed: () {
                  context.go('/forgot-password');
                },
              ),
            ),
          );
        }
        return;
      }

      // RELAXED VALIDATION & RECOVERY:
      final session = Supabase.instance.client.auth.currentSession;
      final authCode = uri.queryParameters['code'];

      // If we have an auth code but no session, try to exchange it manually
      if (session == null && authCode != null) {
        try {
          setState(() => _isLoading = true);
          await Supabase.instance.client.auth.exchangeCodeForSession(authCode);
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                    'Session restored successfully. You can now reset your password.'),
                backgroundColor: AppTheme.accentEmerald,
              ),
            );
            // Clean URL immediately after recovery
            if (kIsWeb) removeUrlParams();
          }
        } catch (e) {
          if (mounted) {
            setState(() => _isLoading = false);
            // SHOW ERROR TO USER
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Session recovery failed: $e'),
                backgroundColor: AppTheme.errorRed,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      } else if (session != null) {
        // If session already exists, just clean the URL
        if (kIsWeb) removeUrlParams();
      }
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    final password = _passwordController.text;
    double strength = 0.0;
    String text = 'Weak';
    Color color = AppTheme.errorRed;

    if (password.length >= 6) strength += 0.2;
    if (password.length >= 8) strength += 0.2;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2;

    if (strength >= 0.8) {
      text = 'Strong';
      color = AppTheme.accentEmerald;
    } else if (strength >= 0.5) {
      text = 'Medium';
      color = AppTheme.accentAmber;
    }

    setState(() {
      _passwordStrength = strength;
      _passwordStrengthText = text;
      _passwordStrengthColor = color;
    });
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // JUST-IN-TIME RECOVERY
        // If session is missing (e.g. page refresh), try to recover using the URL code one last time.
        final currentSession = Supabase.instance.client.auth.currentSession;
        if (currentSession == null) {
          final authCode = Uri.base.queryParameters['code'];
          if (authCode != null) {
            await Supabase.instance.client.auth
                .exchangeCodeForSession(authCode);
            // If successful, we can proceed. If not, the catch block will handle it.
          } else {
            throw AuthSessionMissingException(
                'No session and no recovery code found.');
          }
        }

        final response = await Supabase.instance.client.auth.updateUser(
          UserAttributes(password: _passwordController.text.trim()),
        );

        if (mounted) {
          setState(() => _isLoading = false);

          if (response.user != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Password updated successfully!'),
                backgroundColor: AppTheme.accentEmerald,
              ),
            );

            // Sign out to force user to login with new password
            try {
              await Supabase.instance.client.auth.signOut();
            } catch (e) {
              debugPrint('Sign out failed: $e');
            }

            // Route to login
            if (mounted) context.go('/login');
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.resetPassword),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryViolet.withValues(alpha: 0.2),
                          AppTheme.primaryPink.withValues(alpha: 0.2),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_reset_rounded,
                      size: 80,
                      color: AppTheme.primaryViolet,
                    ),
                  ).animate().scale(duration: 600.ms),
                  const SizedBox(height: 32),
                  Text(
                    'Set New Password',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 16),
                  Text(
                    'Please enter your new password',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: l10n.password,
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.pleaseEnterPassword;
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2),

                  // Password Strength Indicator
                  if (_passwordController.text.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: _passwordStrength,
                                backgroundColor:
                                    theme.colorScheme.outlineVariant,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _passwordStrengthColor,
                                ),
                                minHeight: 4,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _passwordStrengthText,
                              style: TextStyle(
                                color: _passwordStrengthColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Use 8+ characters, uppercase, numbers & symbols',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() => _obscureConfirmPassword =
                              !_obscureConfirmPassword);
                        },
                      ),
                    ),
                    obscureText: _obscureConfirmPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2),
                  const SizedBox(height: 32),
                  AnimatedButton(
                    text: 'Update Password',
                    icon: Icons.check_rounded,
                    onPressed: _isLoading ? () {} : _resetPassword,
                    isLoading: _isLoading,
                    backgroundColor: AppTheme.primaryViolet,
                    isFullWidth: true,
                  ).animate().fadeIn(delay: 600.ms).scale(),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(l10n.backToLogin),
                    ),
                  ).animate().fadeIn(delay: 700.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
