import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:callkeep/callkeep.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Screens/Chat/Calls/call_screen.dart';
import 'package:prive/Screens/Chat/Chat/chat_screen.dart';
import 'package:prive/Widgets/AppWidgets/calling_widget.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as stream;
import 'package:stream_chat_persistence/stream_chat_persistence.dart';
import 'package:uuid/uuid.dart';

import 'Utils.dart';

class NotificationsManager {
  static late FlutterLocalNotificationsPlugin notificationPlugin;
  static late BuildContext notificationsContext;
  static final FlutterCallkeep _callKeep = FlutterCallkeep();
  static bool _callKeepInitiated = false;
  static RemoteMessage? storedBackgroundMessage;
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
      stream.StreamChat.of(notificationsContext)
          .client
          .addDevice(token ?? "", stream.PushProvider.firebase);
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
      stream.Channel? channel;
      final channels = await stream.StreamChatCore.of(notificationsContext)
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
      stream.Channel? channel;
      stream.StreamChatCore.of(notificationsContext)
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
    if (storedBackgroundMessage?.data.isNotEmpty ?? false) {
      final client = stream.StreamChatClient(R.constants.streamKey);
      await client.connectUser(
        stream.User(
          id: await Utils.getString(R.pref.userId) ?? "",
          extraData: {
            'name': await Utils.getString(R.pref.userName),
            'image': await Utils.getString(R.pref.userImage),
            'phone': await Utils.getString(R.pref.userPhone),
          },
        ),
        client.devToken(await Utils.getString(R.pref.userId) ?? "").rawValue,
      );

      stream.Channel? channel;
      stream.StreamChatCore.of(notificationsContext)
          .client
          .state
          .channels
          .forEach((key, value) {
        if (value.id == storedBackgroundMessage?.data['channel_id']) {
          channel = value;
        }
      });
      if (channel != null) {
        Navigator.of(notificationsContext).push(
          ChatScreen.routeWithChannel(channel!),
        );
      }
    } else {
      print("no");
    }
  }

  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage backgroundMessage) async {
    storedBackgroundMessage = backgroundMessage;
    print("hhhh  ${storedBackgroundMessage?.data}");
    if (backgroundMessage.data.isNotEmpty) {
      final messageId = backgroundMessage.data['message_id'];
      final channelId = backgroundMessage.data['channel_id'];
      final channelType = backgroundMessage.data['channel_type'];
      final cid = '$channelType$channelId';
      final client = stream.StreamChatClient(R.constants.streamKey);
      // final persistenceClient = StreamChatPersistenceClient();
      // await persistenceClient
      //     .connect(await Utils.getString(R.pref.userId) ?? "");
      await client.connectUser(
        stream.User(
          id: await Utils.getString(R.pref.userId) ?? "",
          extraData: {
            'name': await Utils.getString(R.pref.userName),
            'image': await Utils.getString(R.pref.userImage),
            'phone': await Utils.getString(R.pref.userPhone),
          },
        ),
        client.devToken(await Utils.getString(R.pref.userId) ?? "").rawValue,
      );

      final stream.Message message =
          await client.getMessage(messageId).then((res) => res.message);

      // await persistenceClient.updateMessages(cid, [message]);
      // persistenceClient.disconnect();
      initializeNotifications();
      await _showLocalNotification(
          title: message.user?.name ?? "", body: message.text ?? "");
    } else {
      var payload = backgroundMessage.data;
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
    }
    return;
  }

  static Future<void> _firebaseMessagingHandler(RemoteMessage message) async {
    BaseNotification notification = BaseNotification(
      title: message.notification?.title ?? "",
      body: message.notification?.body ?? "",
    );

    print(message.data);
    var payload = message.data;
    var type = payload['type'] as String;
    if (type == "call") {
      var callerId = payload['caller_id'] as String;
      var channelName = payload['channel_name'] as String;
      var uuid = payload['uuid'] as String?;
      var hasVideo = payload['has_video'] == "true";
      final callUUID = const Uuid().v4();
      BotToast.cleanAll();
      BotToast.showAnimationWidget(
          toastBuilder: (context) {
            return CallingWidget(
              channelName: channelName,
              context: notificationsContext,
            );
          },
          animationDuration: const Duration(milliseconds: 0));
    }

    if (type != "call") {
      if (type == "message.new") {
        print("New Message");
      } else {
        await _showLocalNotification(notification: notification);
      }
    }
  }

  static Future<void> _showLocalNotification(
      {BaseNotification? notification,
      String title = "",
      String body = ""}) async {
    if (Platform.isAndroid == true) {
      var androidDetails = const AndroidNotificationDetails("id", "channel",
          channelDescription: "description",
          priority: Priority.high,
          importance: Importance.max,
          icon: "launcher_icon");
      await notificationPlugin.show(
          0,
          notification?.title ?? title,
          notification?.body ?? body,
          NotificationDetails(android: androidDetails));
    } else {
      await notificationPlugin.show(
        0,
        notification?.title ?? title,
        notification?.body ?? body,
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
