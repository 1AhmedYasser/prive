import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:callkeep/callkeep.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Screens/Chat/Calls/call_screen.dart';
import 'package:prive/Screens/Chat/Chat/chat_screen.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:uuid/uuid.dart';

import 'Utils.dart';

class NotificationsManager {
  static late FlutterLocalNotificationsPlugin notificationPlugin;
  static late BuildContext notificationsContext;
  static final FlutterCallkeep _callKeep = FlutterCallkeep();
  static bool _callKeepInitiated = false;
  static Map<String, dynamic> callKeepSetupMap = {
    'ios': {
      'appName': 'CallKeepDemo',
    },
    'android': {
      'alertTitle': 'Permissions required',
      'alertDescription':
          'This application needs to access your phone accounts',
      'cancelButton': 'Cancel',
      'okButton': 'ok',
      "additionalPermissions": <String>[],
      'foregroundService': {
        'channelId': 'com.company.my',
        'channelName': 'Foreground service for my app',
        'notificationTitle': 'My app is running on background',
        'notificationIcon': 'Path to the resource icon of the notification',
      },
    },
  };

  static void setupNotifications(BuildContext context) {
    notificationsContext = context;
    initializeNotifications();
    requestPermissions();
    getToken();
    _callKeep.setup(context, callKeepSetupMap);
  }

  static void getToken() {
    FirebaseMessaging.instance.getToken().then((token) async {
      StreamChat.of(notificationsContext)
          .client
          .addDevice(token ?? "", PushProvider.firebase);
      print("Firebase token: $token");
      Utils.saveString(R.pref.firebaseToken, token ?? "");
    });
  }

  static void initializeNotifications() {
    notificationPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: const IOSInitializationSettings(
        defaultPresentSound: true,
        defaultPresentAlert: true,
        defaultPresentBadge: true,
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );
    FlutterLocalNotificationsPlugin().initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  static void requestPermissions() async {
    await [
      Permission.notification,
    ].request();

    FirebaseMessaging.onMessage.listen((message) async {
      _firebaseMessagingHandler(message);
    });

    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      Map<String, dynamic> channelData = Map<String, dynamic>.from(
          json.decode(initialMessage.data["channel"]));
      Channel? channel;
      final channels = await StreamChatCore.of(notificationsContext)
          .client
          .queryChannels()
          .last;

      for (var value in channels) {
        if (value.id == channelData['id']) {
          channel = value;
        }
      }

      if (channel != null) {
        Navigator.of(notificationsContext).push(
          ChatScreen.routeWithChannel(channel),
        );
      }
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Map<String, dynamic> channelData =
          Map<String, dynamic>.from(json.decode(message.data["channel"]));
      Channel? channel;
      StreamChatCore.of(notificationsContext)
          .client
          .state
          .channels
          .forEach((key, value) {
        if (value.id == channelData['id']) {
          channel = value;
        }
      });
      if (channel != null) {
        Navigator.of(notificationsContext).push(
          ChatScreen.routeWithChannel(channel!),
        );
      }
    });
  }

  static Future<dynamic> onSelectNotification(String? notification) async {
    // When Selecting the notification
    print("hi");
  }

  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    var payload = message.data;
    String type = payload['type'];
    if (type == "call") {
      var callerId = payload['caller_id'] as String;
      var channelName = payload['channel_name'] as String;
      var uuid = payload['uuid'] as String;
      var hasVideo = payload['has_video'] == "true";

      final callUUID = const Uuid().v4();
      _callKeep.on(CallKeepPerformAnswerCallAction(),
          (CallKeepPerformAnswerCallAction event) {
        Navigator.of(notificationsContext).push(
          PageRouteBuilder(
            pageBuilder: (BuildContext context, _, __) {
              return CallScreen(
                channelName: channelName,
                isJoining: true,
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

        // print(
        //     'backgroundMessage: CallKeepPerformAnswerCallAction ${event.callUUID}');
        // Timer(const Duration(seconds: 1), () {
        //   print(
        //       '[setCurrentCallActive] $callUUID, callerId: $callerId, callerName: $callerName');
        //   _callKeep.setCurrentCallActive(callUUID);
        // });
        //_callKeep.endCall(event.callUUID);
      });

      _callKeep.on(CallKeepPerformEndCallAction(),
          (CallKeepPerformEndCallAction event) {
        print(
            'backgroundMessage: CallKeepPerformEndCallAction ${event.callUUID}');
      });
      if (!_callKeepInitiated) {
        if (Platform.isAndroid) {
          final bool hasPhoneAccount = await _callKeep.hasPhoneAccount();
          if (hasPhoneAccount == false) {
            await _callKeep.hasDefaultPhoneAccount(
                notificationsContext, callKeepSetupMap);
          }
        }
        _callKeep.setup(notificationsContext, callKeepSetupMap,
            backgroundMode: true);
        _callKeepInitiated = true;
      }

      print('backgroundMessage: displayIncomingCall ($callerId)');
      _callKeep.displayIncomingCall(callUUID, callerId,
          localizedCallerName: "Incoming Call ...", hasVideo: hasVideo);
      _callKeep.backToForeground();
    }
    return;
  }

  static Future<void> _firebaseMessagingHandler(RemoteMessage message) async {
    BaseNotification notification = BaseNotification(
      title: message.notification?.title ?? "",
      body: message.notification?.body ?? "",
    );

    if (Platform.isAndroid) {
      final bool hasPhoneAccount = await _callKeep.hasPhoneAccount();
      if (hasPhoneAccount == false) {
        await _callKeep.hasDefaultPhoneAccount(
            notificationsContext, callKeepSetupMap);
      }
    }

    print(message.data);
    var payload = message.data;
    var type = payload['type'] as String;
    print("type $type");
    if (type == "call") {
      var callerId = payload['caller_id'] as String;
      var channelName = payload['channel_name'] as String;
      var uuid = payload['uuid'] as String?;
      var hasVideo = payload['has_video'] == "true";
      final callUUID = const Uuid().v4();
      _callKeep.displayIncomingCall(callUUID, callerId,
          localizedCallerName: "Incoming Call ...",
          hasVideo: hasVideo,
          handleType: "number");

      _callKeep.on(CallKeepPerformAnswerCallAction(),
          (CallKeepPerformAnswerCallAction event) {
        // Timer(const Duration(seconds: 1), () {
        //   _callKeep.setCurrentCallActive(callUUID);
        // });
        //_callKeep.endCall(event.callUUID);
        print("Contextt $notificationsContext");
        Navigator.of(notificationsContext).push(
          PageRouteBuilder(
            pageBuilder: (BuildContext context, _, __) {
              return CallScreen(
                channelName: channelName,
                isJoining: true,
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
      });

      _callKeep.on(CallKeepPerformEndCallAction(),
          (CallKeepPerformEndCallAction event) {});
    }

    if (type != "call") {
      if (Platform.isAndroid == true) {
        var androidDetails = const AndroidNotificationDetails("id", "channel",
            channelDescription: "description",
            priority: Priority.high,
            importance: Importance.max,
            icon: "appicon");
        await notificationPlugin.show(0, notification.title, notification.body,
            NotificationDetails(android: androidDetails));
      } else {
        await notificationPlugin.show(
          0,
          notification.title,
          notification.body,
          const NotificationDetails(
            iOS: IOSNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
        );
      }
    }
  }
}

class BaseNotification {
  final String title;
  final String body;

  BaseNotification({required this.title, required this.body});
}
