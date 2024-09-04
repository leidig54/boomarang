import 'package:boomarang/app/screens/add_request.dart';
import 'package:boomarang/app/screens/inbox.dart';
import 'package:boomarang/app/screens/sent.dart';
import 'package:boomarang/shared/profile.dart';
import 'package:boomarang_shared/models/request.dart';
import 'package:flutter/material.dart';

class TabIndexProvider extends ChangeNotifier {
  int _tabIndex = 0;

  int get tabIndex => _tabIndex;

  Widget screen = const AddRequestScreen();

  void setTabIndex(int index) {
    _tabIndex = index;
    screen = screens[_tabIndex];
    notifyListeners();
  }

  //complete request screen
  void setScreen(BoomarangRequest request) {
    _tabIndex = 0;
    screen = AddRequestScreen(request: request);
    notifyListeners();
  }

  List<Widget> screens = [
    const AddRequestScreen(),
    const ReceivedScreen(),
    const SentScreen(),
    const BoomarangProfileScreen(),
  ];
}
