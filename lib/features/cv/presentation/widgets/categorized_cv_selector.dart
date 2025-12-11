import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/cv_model.dart';
import '../../data/cv_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CategorizedCVSelector extends ConsumerWidget {
  final CVModel? selectedCV;
  final ValueChanged<CVModel?> onCVSelected;
  final String? labelText;
  final String? hintText;

  const CategorizedCVSelector({
    super.key,
    required this.selectedCV,
    required this.onCVSelected,
    this.labelText,
    this.hintText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: () => _showSelectionSheet(context, ref, l10n),
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText ?? l10n.selectCVOptional,
          hintText: hintText ?? l10n.selectCVToTailorFrom,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          selectedCV?.title ?? l10n.noneUseProfileData,
          style: TextStyle(
            color: selectedCV == null
                ? Colors.grey
                : Theme.of(context).textTheme.bodyLarge?.color,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  void _showSelectionSheet(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _CVSelectionSheet(
        selectedCV: selectedCV,
        onCVSelected: onCVSelected,
        l10n: l10n,
      ),
    );
  }
}

// Separate ConsumerWidget to maintain provider state in the bottom sheet
class _CVSelectionSheet extends ConsumerWidget {
  final CVModel? selectedCV;
  final ValueChanged<CVModel?> onCVSelected;
  final AppLocalizations l10n;

  const _CVSelectionSheet({
    required this.selectedCV,
    required this.onCVSelected,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch providers here to maintain their state
    final generatedCVs = ref.watch(generatedCVsProvider);
    final optimizedCVs = ref.watch(optimizedCVsProvider);
    final tailoredCVs = ref.watch(tailoredCVsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.selectCVToTailorFrom,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  _buildNoneOption(context),
                  _buildSection(
                    context,
                    l10n.generatedCVs,
                    generatedCVs,
                  ),
                  _buildSection(
                    context,
                    l10n.optimizedCVs,
                    optimizedCVs,
                  ),
                  _buildSection(
                    context,
                    l10n.tailoredCVs,
                    tailoredCVs,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNoneOption(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.grey,
        child: Icon(Icons.person_off, color: Colors.white, size: 20),
      ),
      title: Text(l10n.noneUseProfileData),
      trailing: selectedCV == null
          ? const Icon(Icons.check_circle, color: Colors.green)
          : null,
      onTap: () {
        onCVSelected(null);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    AsyncValue<List<CVModel>> cvsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        cvsAsync.when(
          data: (cvs) {
            if (cvs.isEmpty) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "No $title available",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey),
                ),
              );
            }
            return Column(
              children: cvs.map((cv) => _buildCVItem(context, cv)).toList(),
            );
          },
          loading: () => const Center(
              child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          )),
          error: (err, stack) => Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                Text('Error: $err', style: const TextStyle(color: Colors.red)),
          ),
        ),
      ],
    );
  }

  Widget _buildCVItem(BuildContext context, CVModel cv) {
    final isSelected = selectedCV?.id == cv.id;
    final dateFormat = DateFormat.yMMMd();

    return ListTile(
      leading: CircleAvatar(
        backgroundColor:
            isSelected ? Theme.of(context).primaryColor : Colors.grey.shade200,
        child: Icon(
          Icons.description,
          color: isSelected ? Colors.white : Colors.grey.shade700,
          size: 20,
        ),
      ),
      title: Text(
        cv.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(dateFormat.format(cv.createdAt)),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
          : null,
      onTap: () {
        onCVSelected(cv);
        Navigator.pop(context);
      },
    );
  }
}
