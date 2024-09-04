import 'package:flutter/material.dart';

class OverwriteReportDialog extends StatelessWidget {
  const OverwriteReportDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Warning'),
      content:
          const Text('Are you sure you want to overwrite the current report?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
