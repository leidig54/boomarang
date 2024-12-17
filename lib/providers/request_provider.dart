import 'dart:async';

import 'package:boomarang/main.dart';
import 'package:boomarang_shared/models/consent_request.dart';
import 'package:flutter/material.dart';

class RequestProvider extends ChangeNotifier {
  List<ConsentRequest> sentRequests = [];
  late StreamSubscription sentRequestStreamSubscription;

  RequestProvider() {
    sentRequestStreamSubscription = firestore
        .collection('requests')
        .where('senderUserId', isEqualTo: auth.currentUser!.uid)
        .snapshots()
        .listen((snapshot) {
      sentRequests =
          snapshot.docs.map((e) => ConsentRequest.fromMap(e.data())).toList();
      sentRequests.sort((a, b) {
        return b.dateCreated.compareTo(a.dateCreated);
      });
      notifyListeners();
    });
  }

  @override
  void dispose() {
    sentRequestStreamSubscription.cancel();
    super.dispose();
  }
}
