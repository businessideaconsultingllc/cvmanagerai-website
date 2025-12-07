import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/beautiful_components.dart';
import 'auth_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref
          .read(authControllerProvider.notifier)
          .requestPasswordReset(email: _emailController.text.trim());

      if (success && mounted) {
        setState(() {
          _emailSent = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.forgotPassword),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: _emailSent
                ? _buildSuccessView(context, l10n, theme)
                : _buildFormView(context, l10n, authState, theme),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessView(
      BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.accentEmerald.withValues(alpha: 0.2),
                AppTheme.accentCyan.withValues(alpha: 0.2),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mark_email_read_rounded,
            size: 80,
            color: AppTheme.accentEmerald,
          ),
        ).animate().scale(duration: 600.ms),
        const SizedBox(height: 32),
        Text(
          l10n.resetLinkSent,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 16),
        Text(
          l10n.checkYourEmail,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.accentEmerald.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.accentEmerald.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.accentEmerald),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Check your spam folder if you don\'t see the email',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.accentEmerald,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 32),
        AnimatedButton(
          text: l10n.backToLogin,
          icon: Icons.arrow_back_rounded,
          onPressed: () => context.go('/login'),
          backgroundColor: AppTheme.primaryIndigo,
          isFullWidth: true,
        ).animate().fadeIn(delay: 500.ms).scale(),
      ],
    );
  }

  Widget _buildFormView(BuildContext context, AppLocalizations l10n,
      AsyncValue<void> authState, ThemeData theme) {
    return Form(
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
                  AppTheme.primaryIndigo.withValues(alpha: 0.2),
                  AppTheme.primaryViolet.withValues(alpha: 0.2),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_reset_rounded,
              size: 80,
              color: AppTheme.primaryIndigo,
            ),
          ).animate().scale(duration: 600.ms),
          const SizedBox(height: 32),
          Text(
            l10n.resetPassword,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),
          Text(
            l10n.enterEmailToReset,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 32),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: l10n.email,
              hintText: 'your@email.com',
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.pleaseEnterEmail;
              }
              if (!value.contains('@')) {
                return l10n.pleaseEnterValidEmail;
              }
              return null;
            },
          ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2),
          const SizedBox(height: 32),
          AnimatedButton(
            text: l10n.sendResetLink,
            icon: Icons.send_rounded,
            onPressed: authState.isLoading ? () {} : _sendResetEmail,
            isLoading: authState.isLoading,
            backgroundColor: AppTheme.primaryIndigo,
            isFullWidth: true,
          ).animate().fadeIn(delay: 500.ms).scale(),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => context.go('/login'),
              child: Text(l10n.backToLogin),
            ),
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }
}
