import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Helpers/utils.dart';
import 'package:prive/Screens/Auth/intro_screen.dart';
import 'package:prive/Screens/Main/navigator_screen.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../Chat/Calls/single_call_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool? isLoggedIn;
  CancelToken cancelToken = CancelToken();

  @override
  void initState() {
    // NotificationsManager.setupNotifications(context);
    WidgetsBinding.instance.addObserver(this);
    checkForCalls();
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
      StreamManager.connectUserToStream(context);
      isLoggedIn = (loginStatus == null) ? false : loginStatus;
      setState(() {});
      //_checkForNewNotifications(loginStatus);
    } else {
      isLoggedIn = (loginStatus == null) ? false : loginStatus;
      setState(() {});
    }
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    print(state);
    if (state == AppLifecycleState.resumed) {
      //Check call when open app from background
      checkForCalls();
    }
  }

  checkForCalls() async {
    var currentCall = await getCurrentCall();
    if (currentCall != null) {
      print("Have Calls");
      print(currentCall);
      DatabaseReference ref = FirebaseDatabase.instance
          .ref("SingleCalls/${currentCall['extra']['channelName']}");
      final event = await ref.once();

      if (event.snapshot.exists) {
        Map<dynamic, dynamic>? callResponse = {};
        callResponse = (event.snapshot.value as Map<dynamic, dynamic>);
        Map<dynamic, dynamic>? membersList =
            (callResponse['members'] as Map<dynamic, dynamic>?) ?? {};

        if (membersList.length == 1) {
          final client = StreamChatCore.of(context).client;
          ChannelState? channelState = await client.queryChannel("messaging",
              channelId: currentCall['extra']['channelName']);
          Channel? channel = Channel(
              client, "messaging", channelState.channel?.id,
              name: channelState.channel?.name,
              image: currentCall['avatar'],
              extraData: channelState.channel?.extraData);
          client.state.channels.forEach((key, ch) {
            if (ch.id == currentCall['extra']['channelName']) {
              channel = ch;
            }
          });
          if (channel != null) {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (BuildContext context, _, __) {
                  return SingleCallScreen(
                    isJoining: true,
                    isVideo:
                        currentCall['handle'] == "Voice Call" ? false : true,
                    channelName: currentCall['nameCaller'],
                    channelImage: currentCall['avatar'],
                    channel: channel!,
                  );
                },
                transitionsBuilder:
                    (_, Animation<double> animation, __, Widget child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              ),
            );
          } else {
            print("No Channel Found");
          }
        } else {
          print("Already Joined Call");
        }
      } else {
        print("No Calls End All Calls");
        FlutterCallkitIncoming.endAllCalls();
      }
    } else {
      print("No Calls");
    }
  }

  getCurrentCall() async {
    var calls = await FlutterCallkitIncoming.activeCalls();
    if (calls is List) {
      if (calls.isNotEmpty) {
        return calls.first;
      } else {
        return null;
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
