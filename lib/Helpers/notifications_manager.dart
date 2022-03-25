import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Screens/Chat/Calls/call_screen.dart';
import 'package:prive/Screens/Chat/Chat/chat_screen.dart';
import 'package:prive/Widgets/AppWidgets/calling_widget.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as stream;
import 'package:uuid/uuid.dart';

import 'Utils.dart';

class NotificationsManager {
  static late FlutterLocalNotificationsPlugin notificationPlugin;
  static late BuildContext notificationsContext;
  static RemoteMessage? storedBackgroundMessage;

  static void setupNotifications(BuildContext context) {
    notificationsContext = context;
    checkForCurrentCalls();
    listenToCalls();
    initializeNotifications();
    requestPermissions();
    getToken();
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
    print("do you have initial message $initialMessage");
    if (initialMessage != null) {
      Map<String, dynamic> channelData = Map<String, dynamic>.from(
          json.decode(initialMessage.data["channel"]));
      stream.Channel? channel;
      final channels = await stream.StreamChatCore.of(notificationsContext)
          .client
          .queryChannels()
          .last;

      for (var value in channels) {
        if (value.id == initialMessage.data['channel_id']) {
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
      print("2 hiiiis");
      print(message.data);
      Map<String, dynamic> channelData =
          Map<String, dynamic>.from(json.decode(message.data["channel"]));
      stream.Channel? channel;
      stream.StreamChatCore.of(notificationsContext)
          .client
          .state
          .channels
          .forEach((key, value) {
        if (value.id == message.data['channel_id']) {
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
    print("Tapped Notification1 ${notification}");
    Map selectedNotification = json.decode(notification ?? "");
    if (selectedNotification.isNotEmpty) {
      stream.Channel? channel;
      stream.StreamChatCore.of(notificationsContext)
          .client
          .state
          .channels
          .forEach((key, value) {
        if (value.id == selectedNotification['channel_id']) {
          channel = value;
        }
      });
      print("Channnel $channel");
      if (channel != null) {
        Navigator.of(notificationsContext).push(
          ChatScreen.routeWithChannel(channel!),
        );
      }
      // final client = stream.StreamChatClient(R.constants.streamKey);
      // await client.connectUser(
      //   stream.User(
      //     id: await Utils.getString(R.pref.userId) ?? "",
      //     extraData: {
      //       'name': await Utils.getString(R.pref.userName),
      //       'image': await Utils.getString(R.pref.userImage),
      //       'phone': await Utils.getString(R.pref.userPhone),
      //     },
      //   ),
      //   client.devToken(await Utils.getString(R.pref.userId) ?? "").rawValue,
      // );
      //
      // stream.Channel? channel;
      // stream.StreamChatCore.of(notificationsContext)
      //     .client
      //     .state
      //     .channels
      //     .forEach((key, value) {
      //   if (value.id == storedBackgroundMessage?.data['channel_id']) {
      //     channel = value;
      //   }
      // });
      // if (channel != null) {
      //   Navigator.of(notificationsContext).push(
      //     ChatScreen.routeWithChannel(channel!),
      //   );
      // }
    } else {
      print("no");
    }
  }

  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage backgroundMessage) async {
    storedBackgroundMessage = backgroundMessage;
    listenToCalls();
    if (backgroundMessage.data['type'] != null &&
        backgroundMessage.data['type'] != "call") {
      final messageId = backgroundMessage.data['message_id'];
      final channelId = backgroundMessage.data['channel_id'];
      final channelType = backgroundMessage.data['channel_type'];
      final cid = '$channelType$channelId';
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

      final stream.Message message =
          await client.getMessage(messageId).then((res) => res.message);

      initializeNotifications();
      await _showLocalNotification(
          title: message.user?.name ?? "",
          body: message.text ?? "",
          payload: json.encode(backgroundMessage.data).toString());
    } else {
      var payload = backgroundMessage.data;
      String type = payload['type'];
      if (type == "call") {
        var callerId = payload['caller_id'] as String;
        var channelName = payload['channel_name'] as String;
        var uuid = payload['uuid'] as String;
        var hasVideo = payload['has_video'] == "true";
        var callerName = payload['caller_name'] as String;
        var callerImage = payload['caller_image'] as String;

        final callUUID = const Uuid().v4();

        var params = <String, dynamic>{
          'id': callUUID,
          'nameCaller': callerName,
          'appName': 'Prive',
          'avatar': callerImage,
          'extra': <String, dynamic>{'channelName': channelName},
          'type': hasVideo ? 1 : 0,
          'android': <String, dynamic>{
            'isCustomNotification': false,
            'isShowLogo': false,
            'ringtonePath':
                "/android/app/src/main/res/raw/ringtone_default.mp3",
            'backgroundColor': '#1293a8',
            // 'backgroundUrl': 'https://i.pravatar.cc/500',
            // 'actionColor': '#4CAF50'
          },
          'ios': <String, dynamic>{
            'iconName': callerImage,
            'handleType': 'generic',
            'supportsVideo': true,
            'maximumCallGroups': 2,
            'maximumCallsPerCallGroup': 1,
            'audioSessionMode': 'default',
            'audioSessionActive': true,
            'audioSessionPreferredSampleRate': 44100.0,
            'audioSessionPreferredIOBufferDuration': 0.005,
            'supportsDTMF': true,
            'supportsHolding': true,
            'supportsGrouping': false,
            'supportsUngrouping': false,
            'ringtonePath': R.sounds.calling
          }
        };
        await FlutterCallkitIncoming.showCallkitIncoming(params);
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
      var callerName = payload['caller_name'] as String;
      var callerImage = payload['caller_image'] as String?;
      var uuid = payload['uuid'] as String?;
      var hasVideo = payload['has_video'] == "true";
      final callUUID = const Uuid().v4();
      BotToast.cleanAll();
      BotToast.showAnimationWidget(
        toastBuilder: (context) {
          return CallingWidget(
            channelName: channelName,
            context: notificationsContext,
            callerName: callerName,
            callerImage: callerImage ?? "",
            isVideoCall: hasVideo,
          );
        },
        animationDuration: const Duration(milliseconds: 0),
      );
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
      String body = "",
      String payload = ""}) async {
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
          NotificationDetails(android: androidDetails),
          payload: payload);
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
          payload: payload);
    }
  }

  static Future<void> listenToCalls() async {
    try {
      FlutterCallkitIncoming.onEvent.listen((event) async {
        print("Eveeeent $event");
        switch (event!.name) {
          case CallEvent.ACTION_CALL_INCOMING:
            break;
          case CallEvent.ACTION_CALL_START:
            break;
          case CallEvent.ACTION_CALL_ACCEPT:
            Navigator.of(notificationsContext).push(
              PageRouteBuilder(
                pageBuilder: (BuildContext context, _, __) {
                  return CallScreen(
                    channelName: (event.body as Map<String, dynamic>)['extra']
                        ['channelName'],
                    isJoining: true,
                    isVideo: (event.body as Map<String, dynamic>)['type'] == 0
                        ? false
                        : true,
                    callName:
                        (event.body as Map<String, dynamic>)['nameCaller'],
                    callImage: (event.body as Map<String, dynamic>)['avatar'],
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
            break;
          case CallEvent.ACTION_CALL_DECLINE:
            FlutterCallkitIncoming.endAllCalls();
            await Firebase.initializeApp();
            DatabaseReference ref = FirebaseDatabase.instance.ref(
                "Calls/${(event.body as Map<String, dynamic>)['extra']['channelName']}");

            ref.update({
              await Utils.getString(R.pref.userId) ?? "": "Ended",
            });
            break;
          case CallEvent.ACTION_CALL_ENDED:
            break;
          case CallEvent.ACTION_CALL_TIMEOUT:
            break;
          case CallEvent.ACTION_CALL_CALLBACK:
            break;
          case CallEvent.ACTION_CALL_TOGGLE_HOLD:
            break;
          case CallEvent.ACTION_CALL_TOGGLE_MUTE:
            break;
          case CallEvent.ACTION_CALL_TOGGLE_DMTF:
            break;
          case CallEvent.ACTION_CALL_TOGGLE_GROUP:
            break;
          case CallEvent.ACTION_CALL_TOGGLE_AUDIO_SESSION:
            break;
        }
      });
    } on Exception {
      print("Error");
    }
  }

  static checkForCurrentCalls() async {
    var activeCalls = await FlutterCallkitIncoming.activeCalls();
    if (activeCalls.isNotEmpty) {
      print('initCurrentCall: $activeCalls');
      List<dynamic> calls = json.decode(activeCalls);
      if (calls.isNotEmpty) {
        DatabaseReference ref = FirebaseDatabase.instance
            .ref("Calls/${calls[0]['extra']['channelName']}");
        DatabaseEvent event = await ref.once();
        Map<dynamic, dynamic> data =
            event.snapshot.value as Map<dynamic, dynamic>;
        data.remove(await Utils.getString(R.pref.userId));
        print(event.snapshot.value);
        if (data.isNotEmpty) {
          int endedUsers = 0;
          data.forEach((key, value) {
            if (value == "Ended") {
              endedUsers++;
            }
          });
          if (endedUsers == data.length) {
            FlutterCallkitIncoming.endAllCalls();
          } else {
            Navigator.of(notificationsContext).push(
              PageRouteBuilder(
                pageBuilder: (BuildContext context, _, __) {
                  return CallScreen(
                    channelName: calls[0]['extra']['channelName'],
                    isJoining: true,
                    isVideo: calls[0]['type'] == 0 ? false : true,
                    callName: calls[0]['nameCaller'],
                    callImage: calls[0]['avatar'],
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
          }
        }
      }
    }
  }
}

class BaseNotification {
  final String title;
  final String body;

  BaseNotification({required this.title, required this.body});
}
