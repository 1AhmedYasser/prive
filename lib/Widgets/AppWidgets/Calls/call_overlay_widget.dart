import 'dart:async';
import 'dart:io';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:draggable_widget/draggable_widget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/main.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../../../Extras/resources.dart';
import '../../../Helpers/utils.dart';
import '../../../Models/Call/call.dart';
import '../../../Models/Call/call_member.dart';
import '../../../Screens/Chat/Calls/group_call_screen.dart';
import '../../../Screens/Chat/Calls/single_call_screen.dart';

class CallOverlayWidget extends StatefulWidget {
  final bool isGroup;
  final bool isVideo;
  final String callId;
  final RtcEngine? agoraEngine;
  final Channel channel;
  const CallOverlayWidget(
      {Key? key, this.isGroup = false, this.isVideo = false, this.callId = "", this.agoraEngine, required this.channel})
      : super(key: key);

  @override
  State<CallOverlayWidget> createState() => _CallOverlayWidgetState();
}

class _CallOverlayWidgetState extends State<CallOverlayWidget> {
  final remoteDragController = DragController();
  StreamSubscription? onAddListener;
  StreamSubscription? onChangeListener;
  StreamSubscription? onDeleteListener;
  Call? call;
  List<CallMember> videoMembers = [];
  bool showingInfo = false;
  CallMember? me;
  bool isSpeakerOn = false;
  bool isHeadphonesOn = true;
  List<String> kickedMembersIds = [];

  @override
  void initState() {
    _getSpeakerStatus();
    _listenToFirebaseChanges();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamChannel(
      channel: widget.channel,
      child: Stack(
        children: [
          DraggableWidget(
            bottomMargin: 60,
            intialVisibility: true,
            horizontalSpace: 20,
            verticalSpace: 120,
            shadowBorderRadius: 20,
            normalShadow: const BoxShadow(
              color: Colors.transparent,
              offset: Offset(0, 0),
              blurRadius: 2,
            ),
            initialPosition: AnchoringPosition.topRight,
            dragController: remoteDragController,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorDark,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 20),
                      child: ListTile(
                        leading: SizedBox(
                          width: 60,
                          height: 80,
                          child: StreamChannelAvatar(
                            borderRadius: BorderRadius.circular(50),
                            channel: widget.channel,
                            constraints: const BoxConstraints(
                              minWidth: 60,
                              minHeight: 60,
                              maxWidth: 60,
                              maxHeight: 60,
                            ),
                          ),
                        ),
                        title: Text(
                          StreamManager.getChannelName(widget.channel, context.currentUser!),
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          "${call?.members?.length ?? "0"} ${call?.members?.length == 1 ? "Participant".tr() : "Participants".tr()}",
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: GestureDetector(
                          onTap: () {
                            BotToast.removeAll("call_overlay");
                            if (widget.isGroup) {
                              showModalBottomSheet(
                                context: navigatorKey.currentContext!,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) {
                                  return DraggableScrollableSheet(
                                    minChildSize: 0.2,
                                    maxChildSize: 0.95,
                                    builder: (_, controller) {
                                      return GroupCallScreen(
                                        isVideo: call?.type == "Video" ? true : false,
                                        isJoining: true,
                                        call: call,
                                        channel: widget.channel,
                                        scrollController: controller,
                                        agoraEngine: widget.agoraEngine,
                                      );
                                    },
                                  );
                                },
                              );
                            } else {
                              Navigator.of(navigatorKey.currentContext!).push(
                                PageRouteBuilder(
                                  pageBuilder: (BuildContext context, _, __) {
                                    return SingleCallScreen(
                                      isJoining: true,
                                      isVideo: widget.isVideo,
                                      channel: widget.channel,
                                      agoraEngine: widget.agoraEngine,
                                      call: call,
                                    );
                                  },
                                  transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            }
                          },
                          child: const Icon(
                            FontAwesomeIcons.expand,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 25, right: 25),
                      child: Row(
                        children: [
                          buildControl(
                            widget.isVideo
                                ? me?.isVideoOn == true
                                    ? Icons.videocam
                                    : Icons.videocam_off
                                : isSpeakerOn
                                    ? FontAwesomeIcons.volumeHigh
                                    : FontAwesomeIcons.volumeLow,
                            Colors.black38,
                            () async {
                              if (widget.isVideo) {
                                bool isVideoOn = !(call?.members
                                        ?.firstWhere((element) => element.id == context.currentUser?.id)
                                        .isVideoOn ??
                                    false);
                                final ref = FirebaseDatabase.instance.ref(
                                    "${widget.isGroup ? "GroupCalls" : "SingleCalls"}/${widget.channel.id}/members/${context.currentUser?.id}");
                                ref.update({"isVideoOn": isVideoOn});
                                await widget.agoraEngine?.enableLocalVideo(isVideoOn);
                              } else {
                                if (widget.isVideo == false) {
                                  isSpeakerOn = !isSpeakerOn;
                                  await widget.agoraEngine?.setEnableSpeakerphone(isSpeakerOn);
                                  setState(() {});
                                }
                              }
                            },
                          ),
                          const SizedBox(width: 15),
                          buildControl(
                            me?.isMicOn == true ? Icons.mic : Icons.mic_off,
                            Colors.black38,
                            () async {
                              if (isHeadphonesOn && (me?.hasPermissionToSpeak == true)) {
                                bool isMicOn = me?.isMicOn == true;
                                final ref = FirebaseDatabase.instance.ref(
                                    "${widget.isGroup ? "GroupCalls" : "SingleCalls"}/${widget.channel.id}/members/${context.currentUser?.id}");
                                ref.update({"isMicOn": !isMicOn});
                                await widget.agoraEngine?.muteRemoteAudioStream(
                                  uid: int.parse(context.currentUser?.id ?? "0"),
                                  mute: isMicOn,
                                );
                                await widget.agoraEngine?.muteLocalAudioStream(isMicOn);
                                setState(() {});
                              }
                            },
                          ),
                          const SizedBox(width: 15),
                          buildControl(
                            Icons.call_end,
                            const Color(0xffff2d55),
                            () {
                              final databaseReference = FirebaseDatabase.instance
                                  .ref("${widget.isGroup ? "GroupCalls" : "SingleCalls"}/${widget.callId}");
                              if (widget.isGroup) {
                                showCupertinoModalPopup<void>(
                                  context: navigatorKey.currentContext!,
                                  builder: (BuildContext context) => CupertinoActionSheet(
                                    title: Text(
                                        '${"Are You Sure You Want to leave this".tr()} ${widget.isVideo ? "video".tr() : "voice".tr()} ${"call ?".tr()}'),
                                    actions: <CupertinoActionSheetAction>[
                                      if (context.currentUser?.id == call?.ownerId)
                                        CupertinoActionSheetAction(
                                          isDestructiveAction: true,
                                          onPressed: () {
                                            Navigator.pop(context);
                                            BotToast.removeAll("call_overlay");
                                            FlutterCallkitIncoming.endAllCalls();
                                            databaseReference.remove();
                                            _stopForegroundTask();
                                            DatabaseReference userRef = FirebaseDatabase.instance.ref("Users");
                                            userRef.update({context.currentUser?.id ?? "": "Ended"});
                                            widget.agoraEngine?.leaveChannel();
                                          },
                                          child: Text(
                                            '${"End".tr()} ${widget.isVideo ? "Video".tr() : "Voice".tr()} ${"Call".tr()}',
                                          ),
                                        ),
                                      CupertinoActionSheetAction(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          FlutterCallkitIncoming.endAllCalls();
                                          BotToast.removeAll("call_overlay");
                                          _stopForegroundTask();
                                          databaseReference.child("members/${context.currentUser?.id}").remove();
                                          DatabaseReference userRef = FirebaseDatabase.instance.ref("Users");
                                          userRef.update({context.currentUser?.id ?? "": "Ended"});
                                          widget.agoraEngine?.leaveChannel();
                                        },
                                        child: Text(
                                            '${"Leave".tr()} ${widget.isVideo ? "Video".tr() : "Voice".tr()} ${"Call".tr()}'),
                                      ),
                                    ],
                                    cancelButton: CupertinoActionSheetAction(
                                      child: const Text('Cancel').tr(),
                                      onPressed: () {
                                        Navigator.pop(context, 'Cancel');
                                      },
                                    ),
                                  ),
                                );
                              } else {
                                BotToast.removeAll("call_overlay");
                                FlutterCallkitIncoming.endAllCalls();
                                final databaseReference =
                                    FirebaseDatabase.instance.ref("SingleCalls/${widget.channel.id}");
                                DatabaseReference usersRef = FirebaseDatabase.instance.ref("Users");
                                databaseReference.remove();
                                _stopForegroundTask();
                                for (var member in widget.channel.state?.members ?? []) {
                                  usersRef.update({member.userId ?? "": "Ended"});
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 50,
                            child: buildControl(
                              isHeadphonesOn ? Icons.headset_rounded : Icons.headset_off_rounded,
                              Colors.black38,
                              () async {
                                isHeadphonesOn = !isHeadphonesOn;
                                final ref = FirebaseDatabase.instance.ref(
                                    "${widget.isGroup ? "GroupCalls" : "SingleCalls"}/${widget.channel.id}/members/${context.currentUser?.id}");
                                if (isHeadphonesOn == false) {
                                  ref.update({"isMicOn": false, "isHeadphonesOn": false});
                                } else {
                                  ref.update({"isHeadphonesOn": true});
                                }
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildControl(IconData icon, Color containerColor, Function onPressed) {
    return Expanded(
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () => onPressed(),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 25,
          ),
        ),
      ),
    );
  }

  void _listenToFirebaseChanges() {
    final databaseReference =
        FirebaseDatabase.instance.ref("${widget.isGroup ? "GroupCalls" : "SingleCalls"}/${widget.callId}");
    onAddListener = databaseReference.onChildAdded.listen((event) {
      getCall();
    });
    onChangeListener = databaseReference.onChildChanged.listen((event) {
      getCall();
    });
    onDeleteListener = databaseReference.onChildRemoved.listen((event) {
      getCall();
    });
  }

  void getCall() async {
    final databaseReference =
        FirebaseDatabase.instance.ref("${widget.isGroup ? "GroupCalls" : "SingleCalls"}/${widget.callId}");

    final snapshot = await databaseReference.get();
    if (snapshot.exists) {
      Map<dynamic, dynamic>? callResponse = {};
      callResponse = (snapshot.value as Map<dynamic, dynamic>);

      String? ownerId = callResponse['ownerId'];
      String? type = callResponse['type'];
      List<CallMember>? members = [];
      List<CallMember>? kickedMembers = [];

      Map<dynamic, dynamic>? membersList = (callResponse['members'] as Map<dynamic, dynamic>?) ?? {};
      membersList.forEach((key, value) {
        members.add(
          CallMember(
            id: value['id'],
            name: value['name'],
            image: value['image'],
            phone: value['phone'],
            isMicOn: value['isMicOn'],
            isVideoOn: value['isVideoOn'],
            hasPermissionToSpeak: value['hasPermissionToSpeak'],
            isHeadphonesOn: value['isHeadphonesOn'],
          ),
        );
      });

      Map<dynamic, dynamic>? kickedMembersList = (callResponse['kickedMembers'] as Map<dynamic, dynamic>?) ?? {};
      kickedMembersList.forEach((key, value) {
        kickedMembers.add(
          CallMember(
            id: value['id'],
            name: value['name'],
            image: value['image'],
            phone: value['phone'],
            isMicOn: value['isMicOn'],
            isHeadphonesOn: value['isHeadphonesOn'],
            hasPermissionToSpeak: value['hasPermissionToSpeak'],
            isVideoOn: value['isVideoOn'],
          ),
        );
      });

      if (membersList.isEmpty == true) {
        databaseReference.remove();
      }

      call = Call(
        ownerId: ownerId,
        type: type,
        members: members,
        kickedMembers: kickedMembers,
      );

      me = call?.members?.firstWhere((element) => element.id == context.currentUser?.id);
      kickedMembersIds = call?.kickedMembers?.map((e) => e.id ?? "").toList() ?? [];

      // Check If Kicked Your Kicked Out From The Call
      if (kickedMembersIds.contains(context.currentUser?.id)) {
        if (mounted) {
          FlutterCallkitIncoming.endAllCalls();
          BotToast.removeAll("call_overlay");
          _stopForegroundTask();
          databaseReference.child("members/${context.currentUser?.id}").remove();
          DatabaseReference userRef = FirebaseDatabase.instance.ref("Users");
          userRef.update({context.currentUser?.id ?? "": "Ended"});
          widget.agoraEngine?.leaveChannel();
          Utils.showAlert(
            navigatorKey.currentContext!,
            message: "You Have Been Kicked Out Of This Room".tr(),
            alertImage: R.images.alertInfoImage,
          );
        }
      }

      if (me?.hasPermissionToSpeak == false) {
        await widget.agoraEngine?.muteLocalAudioStream(true);
      }

      isHeadphonesOn = me?.isHeadphonesOn ?? true;
      if (isHeadphonesOn == false) {
        me?.isMicOn = false;
        await widget.agoraEngine?.muteAllRemoteAudioStreams(true);
        await widget.agoraEngine?.muteRemoteAudioStream(
          uid: int.parse(context.currentUser?.id ?? "0"),
          mute: false,
        );
        await widget.agoraEngine?.muteLocalAudioStream(true);
      } else {
        await widget.agoraEngine?.muteAllRemoteAudioStreams(false);
      }
      print("My Mic is On ? : ${me?.isMicOn}");
      videoMembers = call?.members?.where((element) => element.isVideoOn == true).toList() ?? [];
      setState(() {});
    } else {
      if (showingInfo == false) {
        _stopForegroundTask();
        if (mounted) {
          BotToast.removeAll("call_overlay");
        }
      }
      showingInfo = true;
    }
  }

  Future<void> _stopForegroundTask() async {
    if (Platform.isAndroid) {
      await FlutterForegroundTask.stopService();
    }
  }

  void _getSpeakerStatus() async {
    isSpeakerOn = await widget.agoraEngine?.isSpeakerphoneEnabled() ?? false;
    setState(() {});
  }

  @override
  void dispose() {
    onAddListener?.cancel();
    onChangeListener?.cancel();
    onDeleteListener?.cancel();
    super.dispose();
  }
}
