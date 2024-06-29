import 'package:boomarang/main.dart';
import 'package:boomarang/shared/alert_dialog.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Enter the verification code sent to your email',
              border: const OutlineInputBorder(),
              suffixIcon: isVerifying
                  ? const CircularProgressIndicator.adaptive()
                  : null,
            ),
            enabled: !isVerifying,
            onSubmitted: isVerifying
                ? null
                : (code) async {
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
                  },
          ),
        ),
      ),
    );
  }
}
