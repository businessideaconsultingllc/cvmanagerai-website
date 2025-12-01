import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'profile_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditMode = false;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      // Split full name into first and last name
      final nameParts = _fullNameController.text.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      try {
        await ref.read(profileControllerProvider.notifier).updateProfile(
              firstName: firstName,
              lastName: lastName,
              phone: _phoneController.text,
              address: _addressController.text,
            );

        if (mounted) {
          setState(() {
            _isEditMode = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  AppLocalizations.of(context)!.profileUpdatedSuccessfully),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          ref.invalidate(profileProvider);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppLocalizations.of(context)!.error}: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        actions: [
          if (!_isEditMode)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEditMode,
              tooltip: l10n.editProfile,
            ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return Center(
              child: Text(l10n.errorLoadingProfile),
            );
          }

          // Initialize controllers with current data when not in edit mode
          if (!_isEditMode) {
            _fullNameController.text = profile['full_name'] ?? '';
            _phoneController.text = profile['phone'] ?? '';
            _addressController.text = profile['address'] ?? '';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Avatar
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(profile['full_name'] ?? 'User'),
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ).animate().scale(duration: 400.ms),
                  const SizedBox(height: 32),

                  // Personal Information Section
                  Text(
                    l10n.personalInformation,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 16),

                  // Full Name
                  _buildField(
                    label: l10n.fullName,
                    controller: _fullNameController,
                    icon: Icons.person,
                    enabled: _isEditMode,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.required;
                      }
                      return null;
                    },
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 16),

                  // Email (read-only)
                  _buildField(
                    label: l10n.email,
                    initialValue: profile['email'] ?? '',
                    icon: Icons.email,
                    enabled: false,
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 16),

                  // Phone
                  _buildField(
                    label: l10n.phoneNumber,
                    controller: _phoneController,
                    icon: Icons.phone,
                    enabled: _isEditMode,
                    keyboardType: TextInputType.phone,
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 16),

                  // Address
                  _buildField(
                    label: l10n.address,
                    controller: _addressController,
                    icon: Icons.location_on,
                    enabled: _isEditMode,
                    maxLines: 3,
                  ).animate().fadeIn(delay: 500.ms),

                  if (_isEditMode) ...[
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _isEditMode = false;
                              });
                            },
                            child: Text(l10n.cancel),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveChanges,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(l10n.saveChanges),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 600.ms),
                  ],
                ],
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Text('${l10n.error}: $error'),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    TextEditingController? controller,
    String? initialValue,
    required IconData icon,
    required bool enabled,
    int? maxLines,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey.withValues(alpha: 0.1),
      ),
      enabled: enabled,
      maxLines: maxLines ?? 1,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}
