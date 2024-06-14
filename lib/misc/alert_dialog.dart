import 'package:boomarang/main.dart';
import 'package:flutter/material.dart';

Future<dynamic> buildErrorAlertDialog(error) {
  return showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(error.toString()),
          actions: [
            TextButton(
              onPressed: () {
                navigatorKey.currentState!.pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      });
}
