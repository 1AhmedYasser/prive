import 'package:flutter/cupertino.dart';

class CallProvider with ChangeNotifier {
  bool isOverlayShown = false;

  void changeOverlayState(bool state) {
    isOverlayShown = state;
    notifyListeners();
  }
}
