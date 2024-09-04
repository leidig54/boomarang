import 'package:boomarang/misc/tab_index_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubmitRequestDialog extends StatelessWidget {
  const SubmitRequestDialog({
    super.key,
    required this.submitRequest,
  });

  final Future<void> Function() submitRequest;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Submit Request'),
      content: const Text('Are you sure you want to submit this request?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            await submitRequest();
            if (!context.mounted) return;
            Navigator.of(context).pop();
            context.read<TabIndexProvider>().setTabIndex(1);
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
