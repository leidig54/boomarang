import 'package:boomarang/main.dart';
import 'package:boomarang/widgets/alert_dialog.dart';
import 'package:flutter/material.dart';

class ResendEmailVerificationCodeScreen extends StatefulWidget {
  const ResendEmailVerificationCodeScreen({
    super.key,
  });

  @override
  State<ResendEmailVerificationCodeScreen> createState() =>
      _ResendEmailVerificationCodeScreenState();
}

class _ResendEmailVerificationCodeScreenState
    extends State<ResendEmailVerificationCodeScreen> {
  bool isSending = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
              'Your email has not been verified. Please verify your email to continue.'),
          const SizedBox(height: 16),
          isSending
              ? const LinearProgressIndicator()
              : TextButton(
                  onPressed: () async {
                    setState(() {
                      isSending = true;
                    });
                    //send the user id to the cloud function
                    await functions
                        .httpsCallable('sendVerificationEmailCallable')
                        .call()
                        .catchError((e) {
                      setState(() {
                        isSending = false;
                      });
                      buildErrorAlertDialog(e);
                      throw e;
                    }).whenComplete(() {
                      setState(() {
                        isSending = false;
                      });
                    });
                  },
                  child: const Text('Resend verification email'),
                ),
        ],
      ),
    );
  }
}
