import 'dart:async';

import 'package:boomarang/main.dart';
import 'package:boomarang_shared/models/organisation.dart';
import 'package:flutter/foundation.dart';

class OrganisationProvider extends ChangeNotifier {
  Organisation? organisation;

  StreamSubscription? organisationSubscription;

  OrganisationProvider() {
    organisationSubscription = firestore
        .collection('organisations')
        .where('members', arrayContains: auth.currentUser?.uid)
        .snapshots()
        .listen((event) {
      if (event.docs.isEmpty) {
        organisation = null;
      } else {
        organisation = Organisation.fromMap(event.docs.first.data());
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    organisationSubscription?.cancel();
    super.dispose();
  }
}
