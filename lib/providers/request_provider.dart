import 'dart:async';

import 'package:boomarang/main.dart';
import 'package:boomarang_shared/models/request.dart';
import 'package:flutter/material.dart';

class RequestProvider extends ChangeNotifier {
  List<BoomarangRequest> receivedRequests = [];
  late StreamSubscription receivedRequestStreamSubscription;

  RequestProvider() {
    receivedRequestStreamSubscription = firestore
        .collection('requests')
        .where('recipientUserId', isEqualTo: auth.currentUser!.uid)
        .snapshots()
        .listen((snapshot) {
      receivedRequests =
          snapshot.docs.map((e) => BoomarangRequest.fromMap(e.data())).toList();
      receivedRequests.sort((a, b) {
        return b.dateCreated.compareTo(a.dateCreated);
      });
      notifyListeners();
    });
  }

  @override
  void dispose() {
    receivedRequestStreamSubscription.cancel();
    super.dispose();
  }
}
