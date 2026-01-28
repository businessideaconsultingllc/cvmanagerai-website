import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/pwa_service.dart';
import '../theme/app_theme.dart';

class PWAInstallPrompt extends ConsumerStatefulWidget {
  const PWAInstallPrompt({super.key});

  @override
  ConsumerState<PWAInstallPrompt> createState() => _PWAInstallPromptState();
}

class _PWAInstallPromptState extends ConsumerState<PWAInstallPrompt> {
  bool _isVisible = false;
  bool _isTimerStarted = false;
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    final pwaService = ref.watch(pwaServiceProvider);

    // If not eligible or already dismissed, show nothing
    if (_dismissed || !pwaService.canInstall) {
      return const SizedBox.shrink();
    }

    // Start a 1.5-second timer before showing the prompt to be less intrusive
    if (!_isVisible && !_isTimerStarted) {
      _isTimerStarted = true;
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted && !_dismissed) {
          setState(() => _isVisible = true);
        }
      });
    }

    if (!_isVisible) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppTheme.mediumShadow,
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.install_mobile_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.installApp,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          l10n.installAppDesc,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _dismissed = true),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (pwaService.isIOS) ...[
                _buildStep(context, l10n.iosInstallStep1, Icons.ios_share),
                const SizedBox(height: 12),
                _buildStep(
                    context, l10n.iosInstallStep2, Icons.add_box_outlined),
                const SizedBox(height: 12),
                _buildStep(context, l10n.iosInstallStep3, Icons.add),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      pwaService.showInstallPrompt();
                      setState(() => _dismissed = true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l10n.installApp),
                  ),
                ),
              ],
            ],
          ),
        ),
      ).animate().fadeIn().slideY(begin: 0.5, curve: Curves.easeOutBack),
    );
  }

  Widget _buildStep(BuildContext context, String text, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
