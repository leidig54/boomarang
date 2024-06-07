import 'package:boomarang/main.dart';
import 'package:flutter/material.dart';

Future<dynamic> showErrorDialog(String errorText) {
  return showAdaptiveDialog(
      context: navigatorKey.currentContext!,
      builder: (context) {
        return AlertDialog.adaptive(
          title: const Text('Error'),
          content: Text(errorText),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      });
}
