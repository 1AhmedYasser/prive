import 'package:flutter/cupertino.dart';

class VolumeProvider with ChangeNotifier {
  void refreshVolumes() {
    notifyListeners();
  }
}
