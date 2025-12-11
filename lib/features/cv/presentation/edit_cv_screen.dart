import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/cv_model.dart';
import 'cv_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../core/constants/languages.dart';

class EditCVScreen extends ConsumerStatefulWidget {
  final CVModel cvModel;

  const EditCVScreen({super.key, required this.cvModel});

  @override
  ConsumerState<EditCVScreen> createState() => _EditCVScreenState();
}

class _EditCVScreenState extends ConsumerState<EditCVScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _summaryController;
  late TextEditingController _skillsController;
  late TextEditingController _languagesController;

  // We'll keep experience, education, and certificates as lists and edit them in dialogs or separate screens
  late List<Experience> _experience;
  late List<Education> _education;
  late List<Certificate> _certificates;

  @override
  void initState() {
    super.initState();
    final data = widget.cvModel.data;
    _firstNameController =
        TextEditingController(text: data.personalInfo.firstName);
    _lastNameController =
        TextEditingController(text: data.personalInfo.lastName);
    _emailController = TextEditingController(text: data.personalInfo.email);
    _phoneController = TextEditingController(text: data.personalInfo.phone);
    _addressController = TextEditingController(text: data.personalInfo.address);
    _summaryController = TextEditingController(text: data.summary);
    _skillsController = TextEditingController(text: data.skills.join(', '));
    _languagesController =
        TextEditingController(text: data.languages.join(', '));
    _experience = List.from(data.experience);
    _education = List.from(data.education);
    _certificates = List.from(data.certificates);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _summaryController.dispose();
    _skillsController.dispose();
    _languagesController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final updatedData = widget.cvModel.data.copyWith(
        personalInfo: widget.cvModel.data.personalInfo.copyWith(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
        ),
        summary: _summaryController.text.trim(),
        skills: _skillsController.text.split(',').map((e) => e.trim()).toList(),
        languages:
            _languagesController.text.split(',').map((e) => e.trim()).toList(),
        experience: _experience,
        education: _education,
        certificates: _certificates,
      );

      final updatedCV = widget.cvModel.copyWith(data: updatedData);

      ref.read(cvControllerProvider.notifier).updateCV(updatedCV);
      context.pop(); // Return to preview
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(cvControllerProvider).isLoading;
    final l10n = AppLocalizations.of(context)!;

    final isRtl = AppLanguages.isRtl(widget.cvModel.language);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editCV),
        actions: [
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _save,
            ),
        ],
      ),
      body: Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSectionCard(
                title: l10n.personalInfo,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstNameController,
                          decoration:
                              InputDecoration(labelText: l10n.firstName),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(labelText: l10n.lastName),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: l10n.email),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(labelText: l10n.phone),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(labelText: l10n.address),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: l10n.professionalSummary,
                children: [
                  TextFormField(
                    controller: _summaryController,
                    decoration: InputDecoration(
                      hintText: l10n.professionalSummaryHint,
                      alignLabelWithHint: true,
                    ),
                    maxLines: 5,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: l10n.skillsLabel,
                children: [
                  TextFormField(
                    controller: _skillsController,
                    decoration: InputDecoration(
                      labelText: l10n.skillsLabel,
                      hintText: l10n.skillsHint,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: l10n.languagesLabel,
                children: [
                  TextFormField(
                    controller: _languagesController,
                    decoration: InputDecoration(
                      labelText: l10n.languagesLabel,
                      hintText: l10n.languagesHint,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildListSection(
                title: l10n.experience,
                items: _experience,
                onAdd: _addExperience,
                onEdit: _editExperience,
                onDelete: (index) {
                  setState(() {
                    _experience.removeAt(index);
                  });
                },
                itemBuilder: (context, exp) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(exp.jobTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      '${exp.company} • ${exp.startDate} - ${exp.endDate}'),
                ),
              ),
              const SizedBox(height: 16),
              _buildListSection(
                title: l10n.education,
                items: _education,
                onAdd: _addEducation,
                onEdit: _editEducation,
                onDelete: (index) {
                  setState(() {
                    _education.removeAt(index);
                  });
                },
                itemBuilder: (context, edu) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(edu.degree,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle:
                      Text('${edu.school} • ${edu.startDate} - ${edu.endDate}'),
                ),
              ),
              const SizedBox(height: 16),
              _buildListSection(
                title: 'Certificates', // Temporary until we add localization
                items: _certificates,
                onAdd: _addCertificate,
                onEdit: _editCertificate,
                onDelete: (index) {
                  setState(() {
                    _certificates.removeAt(index);
                  });
                },
                itemBuilder: (context, cert) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(cert.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${cert.issuer} • ${cert.date}'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
      {required String title, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildListSection<T>({
    required String title,
    required List<T> items,
    required VoidCallback onAdd,
    required Function(int) onEdit,
    required Function(int) onDelete,
    required Widget Function(BuildContext, T) itemBuilder,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                IconButton(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_circle_outline),
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  l10n.noItemsAdded(title),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => onEdit(index),
                          child: itemBuilder(context, item),
                        ),
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => onDelete(index),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _editExperience(int index) async {
    final exp = _experience[index];
    final result = await _showExperienceDialog(exp);
    if (result != null) {
      setState(() {
        _experience[index] = result;
      });
    }
  }

  void _addExperience() async {
    final result = await _showExperienceDialog(null);
    if (result != null) {
      setState(() {
        _experience.add(result);
      });
    }
  }

  void _editEducation(int index) async {
    final edu = _education[index];
    final result = await _showEducationDialog(edu);
    if (result != null) {
      setState(() {
        _education[index] = result;
      });
    }
  }

  void _addEducation() async {
    final result = await _showEducationDialog(null);
    if (result != null) {
      setState(() {
        _education.add(result);
      });
    }
  }

  void _editCertificate(int index) async {
    final cert = _certificates[index];
    final result = await _showCertificateDialog(cert);
    if (result != null) {
      setState(() {
        _certificates[index] = result;
      });
    }
  }

  void _addCertificate() async {
    final result = await _showCertificateDialog(null);
    if (result != null) {
      setState(() {
        _certificates.add(result);
      });
    }
  }

  Future<Experience?> _showExperienceDialog(Experience? experience) {
    final titleController = TextEditingController(text: experience?.jobTitle);
    final companyController = TextEditingController(text: experience?.company);
    final startController = TextEditingController(text: experience?.startDate);
    final endController = TextEditingController(text: experience?.endDate);
    final descController = TextEditingController(text: experience?.description);

    return showDialog<Experience>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(
              experience == null ? l10n.addExperience : l10n.editExperience),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: l10n.jobTitle)),
                TextField(
                    controller: companyController,
                    decoration: InputDecoration(labelText: l10n.company)),
                TextField(
                    controller: startController,
                    decoration: InputDecoration(labelText: l10n.startDate)),
                TextField(
                    controller: endController,
                    decoration: InputDecoration(labelText: l10n.endDate)),
                TextField(
                    controller: descController,
                    decoration: InputDecoration(labelText: l10n.description),
                    maxLines: 3),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  Experience(
                    jobTitle: titleController.text,
                    company: companyController.text,
                    startDate: startController.text,
                    endDate: endController.text,
                    description: descController.text,
                  ),
                );
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }

  Future<Education?> _showEducationDialog(Education? education) {
    final degreeController = TextEditingController(text: education?.degree);
    final schoolController = TextEditingController(text: education?.school);
    final startController = TextEditingController(text: education?.startDate);
    final endController = TextEditingController(text: education?.endDate);
    final descController = TextEditingController(text: education?.description);

    return showDialog<Education>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title:
              Text(education == null ? l10n.addEducation : l10n.editEducation),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: degreeController,
                    decoration: InputDecoration(labelText: l10n.degree)),
                TextField(
                    controller: schoolController,
                    decoration: InputDecoration(labelText: l10n.school)),
                TextField(
                    controller: startController,
                    decoration: InputDecoration(labelText: l10n.startDate)),
                TextField(
                    controller: endController,
                    decoration: InputDecoration(labelText: l10n.endDate)),
                TextField(
                    controller: descController,
                    decoration: InputDecoration(labelText: l10n.description),
                    maxLines: 3),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  Education(
                    degree: degreeController.text,
                    school: schoolController.text,
                    startDate: startController.text,
                    endDate: endController.text,
                    description: descController.text,
                  ),
                );
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }

  Future<Certificate?> _showCertificateDialog(Certificate? certificate) {
    final nameController = TextEditingController(text: certificate?.name);
    final issuerController = TextEditingController(text: certificate?.issuer);
    final dateController = TextEditingController(text: certificate?.date);
    final descController =
        TextEditingController(text: certificate?.description);

    return showDialog<Certificate>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(
              certificate == null ? 'Add Certificate' : 'Edit Certificate'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: 'Certificate Name')),
                TextField(
                    controller: issuerController,
                    decoration: const InputDecoration(labelText: 'Issuer')),
                TextField(
                    controller: dateController,
                    decoration: const InputDecoration(labelText: 'Issue Date')),
                TextField(
                    controller: descController,
                    decoration: InputDecoration(labelText: l10n.description),
                    maxLines: 3),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  Certificate(
                    name: nameController.text,
                    issuer: issuerController.text,
                    date: dateController.text,
                    description: descController.text,
                  ),
                );
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }
}
