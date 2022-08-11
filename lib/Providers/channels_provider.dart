import 'package:flutter/cupertino.dart';

class ChannelsProvider with ChangeNotifier {
  void refreshChannels() {
    notifyListeners();
  }
}
