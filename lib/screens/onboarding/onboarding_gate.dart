import 'package:boomarang/providers/user_provider.dart';
import 'package:boomarang/screens/nav/home.dart';
import 'package:boomarang/screens/onboarding/enter_email_verification_code.dart';
import 'package:boomarang/screens/onboarding/resend_email_verification_code.dart';
import 'package:boomarang/widgets/loading.dart';
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
      return const LoadingScreen(message: 'Creating user profile...');
    }

    //onboarding - email verification
    if (user.emailVerified == false) {
      if (user.emailVerificationCodeHasExpired) {
        return const ResendEmailVerificationCodeScreen();
      } else {
        return const EnterEmailVerificationCodeScreen();
      }
    }

    // //onboarding - profile
    // if (!user.profileIsComplete) {
    //   return const BoomarangProfileScreen();
    // }

    return const Home();
  }
}
