import 'dart:async';

import 'package:boomarang/main.dart';
import 'package:boomarang_shared/models/organisation.dart';
import 'package:flutter/foundation.dart';

class OrganisationProvider extends ChangeNotifier {
  Organisation? organisation;

  StreamSubscription? organisationSubscription;

  bool hasLoaded = false;

  OrganisationProvider() {
    organisationSubscription = firestore
        .collection('organisations')
        .where('users', arrayContains: auth.currentUser?.uid)
        .snapshots()
        .listen((event) {
      if (event.docs.isEmpty) {
        organisation = null;
      } else {
        organisation = Organisation.fromMap(event.docs.first.data());
      }
      hasLoaded = true;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    organisationSubscription?.cancel();
    super.dispose();
  }
}
