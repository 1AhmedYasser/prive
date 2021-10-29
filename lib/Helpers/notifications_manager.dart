import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prive/Extras/resources.dart';
import 'dart:io';
import 'Utils.dart';

class NotificationsManager {
  static late FlutterLocalNotificationsPlugin notificationPlugin;
  static late BuildContext notificationsContext;

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
    var initializationSettings =  InitializationSettings(
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
      RemoteMessage message) async {}

  static Future<void> _firebaseMessagingHandler(RemoteMessage message) async {
    BaseNotification notification = BaseNotification(
      title: message.notification?.title ?? "",
      body: message.notification?.body ?? "",
    );

    if (Platform.isAndroid == true) {
      var androidDetails = const AndroidNotificationDetails(
          "id", "channel", channelDescription: "description",
          priority: Priority.high, importance: Importance.max, icon: "appicon");
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

class BaseNotification {
  final String title;
  final String body;

  BaseNotification({required this.title, required this.body});
}