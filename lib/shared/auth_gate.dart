import 'package:boomarang/main.dart';
import 'package:boomarang/shared/alert_dialog.dart';
import 'package:boomarang/shared/onboarding_gate.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart' hide ProfileScreen;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    try {
      if (kDebugMode && useEmulators) {
        functions.useFunctionsEmulator('localhost', 5001);
        auth.useAuthEmulator('localhost', 9099);
        firestore.useFirestoreEmulator('localhost', 8080);
        // storage.useStorageEmulator('localhost', 9199);
      }
    } on Exception catch (e) {
      buildErrorAlertDialog(e);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    Text('Checking authentication...'),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          } else if (snapshot.data == null) {
            return Scaffold(
              body: SignInScreen(
                providers: [
                  EmailAuthProvider(),
                ],
              ),
            );
          } else {
            return const OnboardingGateScreen();
          }
        });
  }
}
