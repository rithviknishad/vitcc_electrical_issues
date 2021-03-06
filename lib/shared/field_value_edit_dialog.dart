import 'package:flutter/material.dart';
import 'package:vitcc_electrical_issues/shared/dialog_result.dart';

class FieldValueEditDialog extends StatelessWidget {
  final String title;
  final String okButtonText;
  final String cancelButtonText;
  final Widget content;

  FieldValueEditDialog({
    required this.title,
    required this.content,
    this.okButtonText = 'Ok',
    this.cancelButtonText = 'Cancel',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(
        title,
        style: TextStyle(color: theme.primaryColor),
      ),
      titlePadding: const EdgeInsets.all(16),
      content: content,
      actions: [
        TextButton(
          child: Text(cancelButtonText),
          onPressed: () => Navigator.of(context).pop(DialogResult.cancel),
        ),
        TextButton(
          child: Text(okButtonText),
          onPressed: () => Navigator.of(context).pop(DialogResult.ok),
        ),
      ],
    );
  }
}
