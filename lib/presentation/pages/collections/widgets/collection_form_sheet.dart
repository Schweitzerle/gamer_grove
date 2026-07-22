import 'package:flutter/material.dart';
import 'package:gamer_grove/domain/usecases/user_collection/create_collection_use_case.dart';

/// Result of the collection create/edit sheet.
class CollectionFormResult {
  const CollectionFormResult({required this.name, this.description});

  final String name;
  final String? description;
}

/// Shows a modal sheet to create or rename a custom collection.
///
/// Returns the entered values, or null if dismissed. Validation of the final
/// values happens in the use case; the sheet only enforces the "non-empty +
/// max length" affordance so the CTA can gate.
Future<CollectionFormResult?> showCollectionFormSheet(
  BuildContext context, {
  String title = 'New collection',
  String submitLabel = 'Create',
  String? initialName,
  String? initialDescription,
}) {
  return showModalBottomSheet<CollectionFormResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _CollectionFormSheet(
      title: title,
      submitLabel: submitLabel,
      initialName: initialName,
      initialDescription: initialDescription,
    ),
  );
}

class _CollectionFormSheet extends StatefulWidget {
  const _CollectionFormSheet({
    required this.title,
    required this.submitLabel,
    this.initialName,
    this.initialDescription,
  });

  final String title;
  final String submitLabel;
  final String? initialName;
  final String? initialDescription;

  @override
  State<_CollectionFormSheet> createState() => _CollectionFormSheetState();
}

class _CollectionFormSheetState extends State<_CollectionFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descriptionController =
        TextEditingController(text: widget.initialDescription);
    _nameController.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  bool get _isValid => _nameController.text.trim().isNotEmpty;

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final description = _descriptionController.text.trim();
    Navigator.of(context).pop(
      CollectionFormResult(
        name: name,
        description: description.isEmpty ? null : description,
      ),
    );
  }

  @override
  void dispose() {
    _nameController
      ..removeListener(_onChanged)
      ..dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 4,
        bottom: viewInsets + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            maxLength: CreateCollectionUseCase.maxNameLength,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'e.g. Cozy games',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 3,
            maxLength: 500,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _isValid ? _submit : null,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(widget.submitLabel),
          ),
        ],
      ),
    );
  }
}
