import 'package:boomarang/screens/dashboard.dart';
import 'package:boomarang/screens/inbox/inbox.dart';
import 'package:boomarang/screens/sent/sent.dart';
import 'package:boomarang/screens/settings.dart';
import 'package:flutter/material.dart';

class TabIndexProvider extends ChangeNotifier {
  int _tabIndex = 0;

  int get tabIndex => _tabIndex;

  late Widget screen;

  TabIndexProvider() {
    screen = screens[_tabIndex];
  }

  void setTabIndex(int index) {
    _tabIndex = index;
    screen = screens[_tabIndex];
    notifyListeners();
  }

  //complete request screen
  void setScreen() {
    _tabIndex = 0;
    notifyListeners();
  }

  List<Widget> screens = [
    const DashboardScreen(),
    const InboxScreen(),
    const SentScreen(),
    const AdminScreen(),
  ];
}
