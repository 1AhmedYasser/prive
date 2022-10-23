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
import 'package:prive/Screens/Chat/Chat/chat_screen.dart';
import 'package:prive/Widgets/AppWidgets/Calls/calling_widget.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as stream;
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'Utils.dart';

class NotificationsManager {
  static late FlutterLocalNotificationsPlugin notificationPlugin;
  static late BuildContext notificationsContext;
  static RemoteMessage? storedBackgroundMessage;

  static void setupNotifications(BuildContext context) {
    notificationsContext = context;
    //checkForCurrentCalls();
    listenToCalls();
    initializeNotifications();
    requestPermissions();
    getToken();
  }

  static void getToken() async {
    FirebaseMessaging.instance.getToken().then((token) async {
      stream.StreamChat.of(notificationsContext)
          .client
          .addDevice(token ?? "", stream.PushProvider.firebase, pushProviderName: "prive_firebase")
          .then((value) {
        print("Added Device to stream");
      });
      print("Firebase token: $token");
      Utils.saveString(R.pref.firebaseToken, token ?? "");
    });
    var devicePushTokenVoIP = await FlutterCallkitIncoming.getDevicePushTokenVoIP();
    print("Device Token $devicePushTokenVoIP");
  }

  static void initializeNotifications() {
    notificationPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: const DarwinInitializationSettings(
        defaultPresentSound: true,
        defaultPresentAlert: true,
        defaultPresentBadge: true,
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );
    FlutterLocalNotificationsPlugin().initialize(initializationSettings,
        onDidReceiveNotificationResponse: onSelectNotification,
        onDidReceiveBackgroundNotificationResponse: onSelectNotification);
  }

  static void requestPermissions() async {
    await [
      Permission.notification,
    ].request();

    FirebaseMessaging.onMessage.listen((message) async {
      _firebaseMessagingHandler(message);
    });

    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    print("do you have initial message ${initialMessage != null}");
    print("Initial Message Data ${initialMessage?.data}");
    if (initialMessage != null) {
      stream.Channel? channel;
      var channels = await stream.StreamChatCore.of(notificationsContext)
          .client
          .queryChannels(
            filter: Filter.in_(
              'members',
              [await Utils.getString(R.pref.userId) ?? ""],
            ),
          )
          .last;

      for (var currentChannel in channels) {
        if (currentChannel.id == initialMessage.data['channel_id']) {
          channel = currentChannel;
        }
      }

      if (channel != null) {
        Navigator.of(notificationsContext).push(
          ChatScreen.routeWithChannel(channel),
        );
      } else {
        print("Channel not found");
      }
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notifications Message Opened App");
      stream.Channel? channel;
      stream.StreamChatCore.of(notificationsContext).client.state.channels.forEach((key, value) {
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

  static Future<dynamic> onSelectNotification(NotificationResponse? notification) async {
    Map selectedNotification = json.decode(notification?.payload ?? "");
    if (selectedNotification.isNotEmpty) {
      stream.Channel? channel;
      stream.StreamChatCore.of(notificationsContext).client.state.channels.forEach((key, value) {
        if (value.id == selectedNotification['channel_id']) {
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

  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage backgroundMessage) async {
    storedBackgroundMessage = backgroundMessage;
    listenToCalls();
    if (backgroundMessage.data['type'] != null && backgroundMessage.data['type'] != "call") {
      final messageId = backgroundMessage.data['message_id'];
      final channelId = backgroundMessage.data['channel_id'];
      final channelType = backgroundMessage.data['channel_type'];
      initializeNotifications();
      // await _showLocalNotification(
      //     title: backgroundMessage.notification?.title ?? "New Message",
      //     body: backgroundMessage.notification?.body ?? "",
      //     payload: json.encode(backgroundMessage.data).toString());
    } else {
      var payload = backgroundMessage.data;
      String type = payload['type'];
      if (type == "call") {
        var channelName = payload['channel_name'] as String;
        var hasVideo = payload['has_video'] == "true";
        var callerName = payload['caller_name'] as String;
        var callerImage = payload['caller_image'] as String;

        final callUUID = const Uuid().v4();

        var params = <String, dynamic>{
          'id': callUUID,
          'nameCaller': callerName,
          'appName': 'Prive',
          'avatar': callerImage,
          'handle': hasVideo ? "Video Call" : "Voice Call",
          'extra': <String, dynamic>{'channelName': channelName},
          'type': hasVideo ? 1 : 0,
          'android': <String, dynamic>{
            'isCustomNotification': false,
            'isShowLogo': false,
            'ringtonePath': "ringtone_default",
            'backgroundColor': '#1293a8',
            'backgroundUrl': 'https://fv9-3.failiem.lv/thumb_show.php?i=yxvrrm7mr&view',
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
            'ringtonePath': "Ringtone"
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
          groupKey: "incoming_call_overlay");
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
      {BaseNotification? notification, String title = "", String body = "", String payload = ""}) async {
    if (Platform.isAndroid == true) {
      var androidDetails = const AndroidNotificationDetails("id", "channel",
          channelDescription: "description",
          priority: Priority.high,
          importance: Importance.max,
          icon: "launcher_icon");
      await notificationPlugin.show(
          0, notification?.title ?? title, notification?.body ?? body, NotificationDetails(android: androidDetails),
          payload: payload);
    } else {
      await notificationPlugin.show(
          0,
          notification?.title ?? title,
          notification?.body ?? body,
          const NotificationDetails(
            iOS: DarwinNotificationDetails(
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
        switch (event!.name) {
          case CallEvent.ACTION_CALL_INCOMING:
            break;
          case CallEvent.ACTION_CALL_START:
            break;
          case CallEvent.ACTION_CALL_ACCEPT:
            break;
          case CallEvent.ACTION_CALL_DECLINE:
            FlutterCallkitIncoming.endAllCalls();
            await Firebase.initializeApp();
            final databaseReference = FirebaseDatabase.instance
                .ref("SingleCalls/${(event.body as Map<String, dynamic>)['extra']['channelName']}");
            DatabaseReference usersRef = FirebaseDatabase.instance.ref("Users");
            databaseReference.remove();
            usersRef.update({
              await Utils.getString(R.pref.userId) ?? "": "Ended",
            });
            Utils.logAnswerOrCancelCall(
                notificationsContext, notificationsContext.currentUser?.id ?? "", "CANCELLED", "0");
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
        DatabaseReference ref = FirebaseDatabase.instance.ref("Calls/${calls[0]['extra']['channelName']}");
        DatabaseEvent event = await ref.once();
        Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
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
            // Navigator.of(notificationsContext).push(
            //   PageRouteBuilder(
            //     pageBuilder: (BuildContext context, _, __) {
            //       return CallScreen(
            //         channelName: calls[0]['extra']['channelName'],
            //         isJoining: true,
            //         isVideo: calls[0]['type'] == 0 ? false : true,
            //         callName: calls[0]['nameCaller'],
            //         callImage: calls[0]['avatar'],
            //       );
            //     },
            //     transitionsBuilder:
            //         (_, Animation<double> animation, __, Widget child) {
            //       return FadeTransition(
            //         opacity: animation,
            //         child: child,
            //       );
            //     },
            //   ),
            // );
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
