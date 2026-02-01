import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/app/di.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/shared/extensions/context_extensions.dart';
import 'package:yekermo/shared/state/screen_state.dart';
import 'package:yekermo/shared/tokens/app_spacing.dart';
import 'package:yekermo/shared/widgets/app_button.dart';
import 'package:yekermo/shared/widgets/app_scaffold.dart';
import 'package:yekermo/shared/widgets/app_text_field.dart';
import 'package:yekermo/shared/widgets/async_state_view.dart';

class AddressManagerScreen extends ConsumerStatefulWidget {
  const AddressManagerScreen({super.key});

  @override
  ConsumerState<AddressManagerScreen> createState() =>
      _AddressManagerScreenState();
}

class _AddressManagerScreenState extends ConsumerState<AddressManagerScreen> {
  final TextEditingController _line1 = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  AddressLabel _label = AddressLabel.home;

  @override
  void dispose() {
    _line1.dispose();
    _city.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ScreenState<Address?> state = ref.watch(addressControllerProvider);
    return AppScaffold(
      title: 'Address',
      body: AsyncStateView<Address?>(
        state: state,
        emptyBuilder: (_) => _AddressForm(
          line1: _line1,
          city: _city,
          notes: _notes,
          label: _label,
          onLabelChanged: (value) => setState(() => _label = value),
          onSave: _save,
        ),
        dataBuilder: (_, data) {
          if (data != null) {
            _line1.text = data.line1;
            _city.text = data.city;
            _notes.text = data.notes ?? '';
            _label = data.label;
          }
          return _AddressForm(
            line1: _line1,
            city: _city,
            notes: _notes,
            label: _label,
            onLabelChanged: (value) => setState(() => _label = value),
            onSave: _save,
          );
        },
      ),
    );
  }

  void _save() {
    if (_line1.text.trim().isEmpty || _city.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add an address and city to continue.')),
      );
      return;
    }

    final Address address = Address(
      id: 'addr-default',
      label: _label,
      line1: _line1.text.trim(),
      city: _city.text.trim(),
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
    );
    ref.read(addressControllerProvider.notifier).save(address);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Address saved.')));
  }
}

class _AddressForm extends StatelessWidget {
  const _AddressForm({
    required this.line1,
    required this.city,
    required this.notes,
    required this.label,
    required this.onLabelChanged,
    required this.onSave,
  });

  final TextEditingController line1;
  final TextEditingController city;
  final TextEditingController notes;
  final AddressLabel label;
  final ValueChanged<AddressLabel> onLabelChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        Text('Where should we deliver?', style: context.text.titleMedium),
        AppSpacing.vSm,
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            FilterChip(
              label: const Text('Home'),
              selected: label == AddressLabel.home,
              onSelected: (_) => onLabelChanged(AddressLabel.home),
            ),
            FilterChip(
              label: const Text('Work'),
              selected: label == AddressLabel.work,
              onSelected: (_) => onLabelChanged(AddressLabel.work),
            ),
          ],
        ),
        AppSpacing.vMd,
        AppTextField(controller: line1, hintText: 'Address'),
        AppSpacing.vSm,
        AppTextField(controller: city, hintText: 'City'),
        AppSpacing.vSm,
        AppTextField(controller: notes, hintText: 'Notes (optional)'),
        AppSpacing.vMd,
        AppButton(label: 'Save address', onPressed: onSave),
      ],
    );
  }
}
