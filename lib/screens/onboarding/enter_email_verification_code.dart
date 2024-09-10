import 'package:boomarang/main.dart';
import 'package:boomarang/widgets/alert_dialog.dart';
import 'package:flutter/material.dart';

class EnterEmailVerificationCodeScreen extends StatefulWidget {
  const EnterEmailVerificationCodeScreen({
    super.key,
  });

  @override
  State<EnterEmailVerificationCodeScreen> createState() =>
      _EnterEmailVerificationCodeScreenState();
}

class _EnterEmailVerificationCodeScreenState
    extends State<EnterEmailVerificationCodeScreen> {
  bool isVerifying = false;
  TextEditingController codeController = TextEditingController();

  Future<void> onSubmitted(String code) async {
    setState(() {
      isVerifying = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    await functions
        .httpsCallable('checkEmailVerificationCode')
        .call({'code': code}).catchError((e) {
      buildErrorAlertDialog(e);
      throw e;
    }).whenComplete(() {
      if (mounted) {
        setState(() {
          isVerifying = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 400,
              child: TextFormField(
                controller: codeController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Enter the verification code sent to your email',
                  border: const OutlineInputBorder(),
                  suffixIcon: isVerifying
                      ? const CircularProgressIndicator.adaptive()
                      : IconButton(
                          onPressed: isVerifying
                              ? null
                              : () async {
                                  await onSubmitted(codeController.text);
                                },
                          icon: const Icon(Icons.send)),
                ),
                enabled: !isVerifying,
                onFieldSubmitted: isVerifying
                    ? null
                    : (code) async {
                        await onSubmitted(code);
                      },
              ),
            ),
            //Sign out button
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                auth.signOut();
              },
              child: const Text("Exit"),
            )
          ],
        ),
      ),
    );
  }
}
