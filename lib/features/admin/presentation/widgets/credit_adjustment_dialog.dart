import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/admin_user_model.dart';

class CreditAdjustmentDialog extends StatefulWidget {
  final AdminUserModel user;
  final Future<void> Function({
    required String userId,
    required int amount,
    required String reason,
  }) onAdjust;

  const CreditAdjustmentDialog({
    super.key,
    required this.user,
    required this.onAdjust,
  });

  @override
  State<CreditAdjustmentDialog> createState() => _CreditAdjustmentDialogState();
}

class _CreditAdjustmentDialogState extends State<CreditAdjustmentDialog> {
  late TextEditingController _amountController;
  late TextEditingController _reasonController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int _amount = 0;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _handleAdjust() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await widget.onAdjust(
        userId: widget.user.id,
        amount: _amount,
        reason: _reasonController.text,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  int get _newBalance => widget.user.creditBalance + _amount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Adjust Credits'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'User: ${widget.user.displayName}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Current Balance:'),
                    Text(
                      '${widget.user.creditBalance}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Credit Amount',
                  helperText: 'Use negative numbers to deduct credits',
                  border: OutlineInputBorder(),
                  prefixText: '+/- ',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(signed: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  final amount = int.tryParse(value);
                  if (amount == null) {
                    return 'Invalid number';
                  }
                  if (amount == 0) {
                    return 'Amount cannot be zero';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _amount = int.tryParse(value) ?? 0;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _newBalance >= 0
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('New Balance:'),
                    Text(
                      '$_newBalance',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _newBalance >= 0
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _handleAdjust,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Adjust Credits'),
        ),
      ],
    );
  }
}
