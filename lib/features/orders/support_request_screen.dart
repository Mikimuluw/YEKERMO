import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/app/providers.dart';
import 'package:yekermo/domain/support.dart';
import 'package:yekermo/observability/analytics.dart';
import 'package:yekermo/shared/tokens/app_spacing.dart';
import 'package:yekermo/shared/extensions/context_extensions.dart';
import 'package:yekermo/shared/widgets/app_text_field.dart';
import 'package:yekermo/ui/app_button.dart';
import 'package:yekermo/ui/app_card.dart';
import 'package:yekermo/ui/app_scaffold.dart';
import 'package:yekermo/ui/app_section_header.dart';

class SupportRequestScreen extends ConsumerStatefulWidget {
  const SupportRequestScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<SupportRequestScreen> createState() =>
      _SupportRequestScreenState();
}

class _SupportRequestScreenState extends ConsumerState<SupportRequestScreen> {
  final TextEditingController _messageController = TextEditingController();
  SupportCategory? _selectedCategory;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Get help',
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          const AppSectionHeader(title: 'Category'),
          AppSpacing.vSm,
          ...SupportCategory.values.map((category) {
            final bool isSelected = category == _selectedCategory;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  title: Text(_labelFor(category)),
                  trailing: isSelected ? const Icon(Icons.check) : null,
                  onTap: () => _selectCategory(category),
                ),
              ),
            );
          }),
          AppSpacing.vMd,
          const AppSectionHeader(title: 'Details (optional)'),
          AppSpacing.vSm,
          AppTextField(
            controller: _messageController,
            hintText: 'Share anything we should know.',
            maxLines: 4,
          ),
          if (_selectedCategory == null) ...[
            AppSpacing.vSm,
            Text(
              'Select a category to continue.',
              style: context.text.bodySmall?.copyWith(
                color: context.textMuted,
              ),
            ),
          ],
          AppSpacing.vLg,
          AppButton(
            label: 'Submit',
            onPressed: _selectedCategory == null ? null : _submit,
          ),
        ],
      ),
    );
  }

  void _selectCategory(SupportCategory category) {
    setState(() => _selectedCategory = category);
    ref
        .read(analyticsProvider)
        .track(
          AnalyticsEvents.supportCategorySelected,
          properties: {'category': category.name, 'orderId': widget.orderId},
        );
  }

  Future<void> _submit() async {
    final SupportCategory? category = _selectedCategory;
    if (category == null) return;
    final String email = ref.read(currentUserEmailProvider);
    final SupportEntryPoint entryPoint = SupportEntryPoint(
      orderId: widget.orderId,
      userEmail: email,
    );
    final String message = _messageController.text.trim();
    final SupportRequestDraft draft = entryPoint.createDraft(
      category: category,
      message: message.isEmpty ? null : message,
    );
    // TODO(phase8): replace log-only handoff with email/POST transport.
    ref.read(logProvider).i('Support handoff: ${draft.toPayload()}');
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text('Request received.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  String _labelFor(SupportCategory category) {
    switch (category) {
      case SupportCategory.missingItem:
        return 'Missing item';
      case SupportCategory.wrongItem:
        return 'Wrong item';
      case SupportCategory.lateDelivery:
        return 'Late delivery';
      case SupportCategory.cancelRequest:
        return 'Cancel request';
      case SupportCategory.other:
        return 'Other';
    }
  }
}
