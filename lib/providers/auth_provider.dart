import 'dart:async';

import 'package:boomarang/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserAuthProvider extends ChangeNotifier {
  User? user;

  StreamSubscription? userSubscription;

  UserAuthProvider() {
    userSubscription = auth.authStateChanges().listen((event) {
      user = event;
      notifyListeners();
    });
  }
}
