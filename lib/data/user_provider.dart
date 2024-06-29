import 'dart:async';

import 'package:boomarang/main.dart';
import 'package:boomarang_shared/models/user.dart';
import 'package:flutter/foundation.dart';

class UserProvider extends ChangeNotifier {
  BoomarangUser? user;

  StreamSubscription? userSubscription;

  UserProvider() {
    userSubscription = firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
        .snapshots()
        .listen((event) {
      user = BoomarangUser.fromMap(event.data()!);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    userSubscription?.cancel();
    super.dispose();
  }
}
