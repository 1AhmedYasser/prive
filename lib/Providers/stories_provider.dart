import 'package:flutter/cupertino.dart';

class StoriesProvider with ChangeNotifier {
  int currentShowIndex = -1;

  void setCurrentShownIndex(int index) {
    currentShowIndex = index;
    notifyListeners();
  }
}
