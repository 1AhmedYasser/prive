import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Helpers/notifications_manager.dart';
import 'package:prive/Helpers/utils.dart';
import 'package:prive/Screens/Auth/intro_screen.dart';
import 'package:prive/Screens/Main/navigator_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool? isLoggedIn;
  CancelToken cancelToken = CancelToken();

  @override
  void initState() {
    NotificationsManager.setupNotifications(context);
    _checkIfUserIsLoggedIn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoggedIn != null
        ? isLoggedIn == true
            ? const NavigatorScreen()
            : const IntroScreen()
        : Scaffold(
            body: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(R.images.splashImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
  }

  void _checkIfUserIsLoggedIn() async {
    var loginStatus = await Utils.getBool(R.pref.isLoggedIn);
    if (loginStatus == true) {
      Utils.connectUserToStream(context);
      isLoggedIn = (loginStatus == null) ? false : loginStatus;
      setState(() {});
      //_checkForNewNotifications(loginStatus);
    } else {
      isLoggedIn = (loginStatus == null) ? false : loginStatus;
      setState(() {});
    }
  }

// void _checkForNewNotifications(bool? loginStatus) async {
//   UltraNetwork.request(
//     context,
//     newNotifications,
//     cancelToken: cancelToken,
//     showError: false,
//     showLoadingIndicator: false,
//     formData:
//     FormData.fromMap({"UserID": await Utils.getString(R.pref.userId)}),
//   ).then((response) {
//     if (response != null) {
//       if ((response as NewNotifications).data?.isNotEmpty ?? false) {
//         print("Has New Notification");
//         Utils.saveBool(R.pref.hasNewNotifications, true);
//       } else {
//         print("Has No New Notification");
//         Utils.saveBool(R.pref.hasNewNotifications, false);
//       }
//     }
//     isLoggedIn = (loginStatus == null) ? false : loginStatus;
//     setState(() {});
//   });
// }
}
