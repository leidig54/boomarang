import 'dart:async';

import 'package:boomarang/main.dart';
import 'package:boomarang_shared/models/request.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class SentboxProvider extends ChangeNotifier {
  List<BoomarangRequest> requests = [];
  late StreamSubscription requestStreamSubscription;
  BoomarangRequest? selectedRequest;

  SentboxProvider() {
    requestStreamSubscription = firestore
        .collection('requests')
        .where('senderUserId', isEqualTo: auth.currentUser!.uid)
        .snapshots()
        .listen((snapshot) {
      requests =
          snapshot.docs.map((e) => BoomarangRequest.fromMap(e.data())).toList();
      requests.sort((a, b) {
        return b.dateCreated.compareTo(a.dateCreated);
      });
      selectedRequest = requests.firstWhereOrNull(
        (element) => element.id == selectedRequest?.id,
      );
      if (selectedRequest == null && requests.isNotEmpty) {
        selectedRequest = requests.first;
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    requestStreamSubscription.cancel();
    super.dispose();
  }

  void selectRequest(BoomarangRequest request) {
    selectedRequest =
        requests.firstWhere((element) => element.id == request.id);
    notifyListeners();
  }

  bool get responseComplete =>
      selectedRequest?.requestStatus == "response_submitted";
}
