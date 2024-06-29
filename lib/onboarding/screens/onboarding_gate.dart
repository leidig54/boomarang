import 'package:boomarang/data/user_provider.dart';
import 'package:boomarang/holder/screens/home.dart';
import 'package:boomarang/onboarding/screens/enter_email_verification_code.dart';
import 'package:boomarang/onboarding/screens/resend_email_verification_code.dart';
import 'package:boomarang/onboarding/screens/select_user_type.dart';
import 'package:boomarang/requester/screens/home.dart';
import 'package:boomarang/shared/profile.dart';
import 'package:boomarang_shared/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OnboardingGateScreen extends StatefulWidget {
  const OnboardingGateScreen({super.key});

  @override
  State<OnboardingGateScreen> createState() => _OnboardingGateScreenState();
}

class _OnboardingGateScreenState extends State<OnboardingGateScreen> {
  @override
  Widget build(BuildContext context) {
    BoomarangUser? user = context.watch<UserProvider>().user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              Text("Creating user profile...")
            ],
          ),
        ),
      );
    }

    //onboarding - email verification
    if (user.emailVerified == false) {
      if (user.emailVerificationCodeHasExpired) {
        return const ResendEmailVerificationCodeScreen();
      } else {
        return const EnterEmailVerificationCodeScreen();
      }
    }

    //onboarding - user type
    if (user.userType == null) {
      return const SelectUserTypeScreen();
    }

    //onboarding - profile
    if (!user.profileIsComplete) {
      return const BoomarangProfileScreen();
    }

    if (user.userType == 'holder') {
      return const HolderHome();
    } else if (user.userType == 'requester') {
      return const RequesterHome();
    } else {
      return const Scaffold(
        body: Center(
          child: Text('User type not recognised. Please contact support.'),
        ),
      );
    }
  }
}
