import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../core/constants/languages.dart';
import '../../profile/presentation/profile_controller.dart';
import 'cv_controller.dart';

class GenerateCVScreen extends ConsumerStatefulWidget {
  const GenerateCVScreen({super.key});

  @override
  ConsumerState<GenerateCVScreen> createState() => _GenerateCVScreenState();
}

class _GenerateCVScreenState extends ConsumerState<GenerateCVScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jobTitleController = TextEditingController();

  @override
  void dispose() {
    _jobTitleController.dispose();
    super.dispose();
  }

  String _selectedLanguage = 'en';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(profileProvider);
    final cvState = ref.watch(cvControllerProvider);

    ref.listen(cvControllerProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        // Navigate to preview
        context.push('/cv-preview', extra: next.value);
      } else if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${next.error}')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.generateCV)),
      body: cvState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.createYourCV,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.generateCVDescription,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    // Profile Summary Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: profileAsync.when(
                          data: (profile) {
                            if (profile == null) {
                              return Text(l10n.errorLoadingProfile);
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.person_outline),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${profile['first_name']} ${profile['last_name']}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('${l10n.email}: ${profile['email']}'),
                                Text('${l10n.phone}: ${profile['phone']}'),
                                Text('${l10n.address}: ${profile['address']}'),
                              ],
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Text('Error: $e'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _jobTitleController,
                      decoration: InputDecoration(
                        labelText: l10n.targetJobTitle,
                        hintText: l10n.jobTitleHint,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.work_outline),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? l10n.required : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedLanguage,
                      decoration: InputDecoration(
                        labelText: l10n.targetLanguage,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.language),
                      ),
                      items: AppLanguages.supportedLanguages.entries
                          .map((entry) => DropdownMenuItem(
                                value: entry.key,
                                child: Text(entry.value),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedLanguage = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _generateCV,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(l10n.generateCVButton),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _generateCV() async {
    if (_formKey.currentState!.validate()) {
      final l10n = AppLocalizations.of(context)!;

      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.confirmGeneration),
          content: Text(l10n.confirmGenerationMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.generateCV),
            ),
          ],
        ),
      );

      // If confirmed, proceed with generation
      if (confirmed == true && mounted) {
        ref.read(cvControllerProvider.notifier).generateCV(
              jobTitle: _jobTitleController.text.trim(),
              targetLanguage: _selectedLanguage,
            );
      }
    }
  }
}
