import 'dart:async';

import 'package:callkeep/callkeep.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prive/Extras/resources.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'Utils.dart';

class NotificationsManager {
  static late FlutterLocalNotificationsPlugin notificationPlugin;
  static BuildContext? notificationsContext;
  static FlutterCallkeep _callKeep = FlutterCallkeep();
  static bool _callKeepInitiated = false;
  static Map<String, dynamic> callSetup = {
    'ios': {
      'appName': 'Prive',
    },
    'android': {
      'alertTitle': 'Permissions required',
      'alertDescription':
          'This application needs to access your phone accounts',
      'cancelButton': 'Cancel',
      'okButton': 'ok',
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
  }

  static void getToken() {
    FirebaseMessaging.instance.getToken().then((token) async {
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

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // When Selecting the notification while the app is opened
    });
  }

  static Future<dynamic> onSelectNotification(String? notification) async {
    // When Selecting the notification
  }

  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print('backgroundMessage: message => ${message.toString()}');
    var payload = message.data;
    var callerId = payload['caller_id'] as String;
    var callerName = payload['caller_name'] as String;
    var uuid = payload['uuid'] as String;
    var hasVideo = payload['has_video'] == "true";

    final callUUID = uuid;
    _callKeep.on(CallKeepPerformAnswerCallAction(),
        (CallKeepPerformAnswerCallAction event) {
      print(
          'backgroundMessage: CallKeepPerformAnswerCallAction ${event.callUUID}');
      Timer(const Duration(seconds: 1), () {
        print(
            '[setCurrentCallActive] $callUUID, callerId: $callerId, callerName: $callerName');
        _callKeep.setCurrentCallActive(callUUID);
      });
      //_callKeep.endCall(event.callUUID);
    });

    _callKeep.on(CallKeepPerformEndCallAction(),
        (CallKeepPerformEndCallAction event) {
      print(
          'backgroundMessage: CallKeepPerformEndCallAction ${event.callUUID}');
    });
    if (!_callKeepInitiated) {
      if (Platform.isAndroid) {
        print("hi 1");
        final bool hasPhoneAccount = await _callKeep.hasPhoneAccount();
        print("hi 2");
        print("has phone account $hasPhoneAccount");
        print("Conettextt :");
        if (hasPhoneAccount == false) {
          print("heeloz1 ");
          print(notificationsContext);
          await _callKeep
              .hasDefaultPhoneAccount(notificationsContext!, <String, dynamic>{
            'alertTitle': 'Permissions required',
            'alertDescription':
                'This application needs to access your phone accounts',
            'cancelButton': 'Cancel',
            'okButton': 'ok',
            'foregroundService': {
              'channelId': 'com.company.my',
              'channelName': 'Foreground service for my app',
              'notificationTitle': 'My app is running on background',
              'notificationIcon':
                  'Path to the resource icon of the notification',
            },
          });
          print("heeloz2");
        }
      }

      print("hi");
      _callKeep.setup(
          notificationsContext,
          <String, dynamic>{
            'ios': {
              'appName': 'Prive',
            },
            'android': {
              'alertTitle': 'Permissions required',
              'alertDescription':
                  'This application needs to access your phone accounts',
              'cancelButton': 'Cancel',
              'okButton': 'ok',
              'foregroundService': {
                'channelId': 'com.company.my',
                'channelName': 'Foreground service for my app',
                'notificationTitle': 'My app is running on background',
                'notificationIcon':
                    'Path to the resource icon of the notification',
              },
            },
          },
          backgroundMode: true);
      _callKeepInitiated = true;
    }

    print('backgroundMessage: displayIncomingCall ($callerId)');
    _callKeep.displayIncomingCall(callUUID, callerId,
        localizedCallerName: callerName, hasVideo: hasVideo);
    _callKeep.backToForeground();
    return;
  }

  static Future<void> _firebaseMessagingHandler(RemoteMessage message) async {
    BaseNotification notification = BaseNotification(
      title: message.notification?.title ?? "",
      body: message.notification?.body ?? "",
    );

    var payload = message.data;
    var type = payload['type'] as String;
    if (type == "call") {
      var callerId = payload['caller_id'] as String;
      var callerName = payload['caller_name'] as String;
      var uuid = payload['uuid'] as String?;
      var hasVideo = payload['has_video'] == "true";
      final callUUID = uuid ?? const Uuid().v4();
      print("heyy kiddo $callUUID");
      print("heyy kiddo $callerId");
      print("heyy kiddo $callerName");
      print("heyy kiddo $hasVideo");
      print("call keep ${await _callKeep.hasPhoneAccount()}");
      _callKeep.displayIncomingCall(callUUID, callerId,
          localizedCallerName: callerName, hasVideo: hasVideo);
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
