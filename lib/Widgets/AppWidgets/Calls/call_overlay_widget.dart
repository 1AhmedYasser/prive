import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:draggable_widget/draggable_widget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/main.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../../../Extras/resources.dart';
import '../../../Helpers/Utils.dart';
import '../../../Models/Call/group_call.dart';
import '../../../Models/Call/group_call_member.dart';
import '../../../Screens/Chat/Calls/group_call_screen.dart';

class CallOverlayWidget extends StatefulWidget {
  final bool isGroup;
  final bool isVideo;
  final String callId;
  final RtcEngine? agoraEngine;
  final Channel channel;
  const CallOverlayWidget(
      {Key? key,
      this.isGroup = false,
      this.isVideo = false,
      this.callId = "",
      this.agoraEngine,
      required this.channel})
      : super(key: key);

  @override
  State<CallOverlayWidget> createState() => _CallOverlayWidgetState();
}

class _CallOverlayWidgetState extends State<CallOverlayWidget> {
  final remoteDragController = DragController();
  StreamSubscription? onAddListener;
  StreamSubscription? onChangeListener;
  StreamSubscription? onDeleteListener;
  GroupCall? groupCall;
  List<GroupCallMember> videoMembers = [];
  bool showingInfo = false;
  GroupCallMember? me;
  bool isSpeakerOn = false;

  @override
  void initState() {
    _getSpeakerStatus();
    if (widget.isGroup) {
      _listenToFirebaseChanges();
    }
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
            child: Container(
              width: 230,
              height: 170,
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
                          child: ChannelAvatar(
                            borderRadius: BorderRadius.circular(50),
                            channel: widget.channel,
                            constraints: const BoxConstraints(
                              maxWidth: 60,
                              maxHeight: 60,
                            ),
                          ),
                          width: 60,
                          height: 80,
                        ),
                        // leading: SizedBox(
                        //   child: ClipRRect(
                        //     borderRadius: BorderRadius.circular(20),
                        //     child: CachedImage(
                        //       url: context.currentUserImage ?? "",
                        //     ),
                        //   ),
                        //   width: 60,
                        //   height: 80,
                        // ),
                        title: Text(
                          widget.isGroup ? widget.channel.name ?? "" : "",
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          "${groupCall?.members?.length ?? "0"} ${groupCall?.members?.length == 1 ? "Participant" : "Participants"}",
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: GestureDetector(
                          onTap: () {
                            BotToast.removeAll("call_overlay");
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
                                      isVideo: groupCall?.type == "Video"
                                          ? true
                                          : false,
                                      isJoining: true,
                                      startCam: me?.isVideoOn == true,
                                      channel: widget.channel,
                                      scrollController: controller,
                                    );
                                  },
                                );
                              },
                            );
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
                                    ? FontAwesomeIcons.volumeUp
                                    : FontAwesomeIcons.volumeDown,
                            Colors.black38,
                            () async {
                              if (widget.isGroup) {
                                if (widget.isVideo) {
                                  bool isVideoOn = me?.isVideoOn == true;
                                  final ref = FirebaseDatabase.instance.ref(
                                      "GroupCalls/${widget.channel.id}/members/${context.currentUser?.id}");
                                  ref.update({"isVideoOn": !isVideoOn});
                                  if (isVideoOn) {
                                    await widget.agoraEngine?.enableVideo();
                                  } else {
                                    await widget.agoraEngine?.disableVideo();
                                  }
                                } else {
                                  if (widget.isVideo == false) {
                                    isSpeakerOn = !isSpeakerOn;
                                    await widget.agoraEngine
                                        ?.setEnableSpeakerphone(isSpeakerOn);
                                    setState(() {});
                                  }
                                }
                              }
                            },
                          ),
                          const SizedBox(width: 15),
                          buildControl(
                            me?.isMicOn == true ? Icons.mic : Icons.mic_off,
                            Colors.black38,
                            () async {
                              if (widget.isGroup) {
                                bool isMute =
                                    me?.isMicOn == true ? false : true;
                                final ref = FirebaseDatabase.instance.ref(
                                    "GroupCalls/${widget.channel.id}/members/${context.currentUser?.id}");
                                ref.update({
                                  "isMicOn": me?.isMicOn == true ? false : true
                                });
                                widget.agoraEngine?.muteRemoteAudioStream(
                                  int.parse(context.currentUser?.id ?? "0"),
                                  isMute,
                                );
                                await widget.agoraEngine
                                    ?.muteLocalAudioStream(isMute);
                              }
                            },
                          ),
                          const SizedBox(width: 15),
                          buildControl(
                            Icons.call_end,
                            const Color(0xffff2d55),
                            () {
                              if (widget.isGroup) {
                                final databaseReference = FirebaseDatabase
                                    .instance
                                    .ref("GroupCalls/${widget.callId}");
                                showCupertinoModalPopup<void>(
                                  context: navigatorKey.currentContext!,
                                  builder: (BuildContext context) =>
                                      CupertinoActionSheet(
                                    title: Text(
                                        'Are You Sure  You Want to leave this ${widget.isVideo ? "video" : "voice"} call ?'),
                                    actions: <CupertinoActionSheetAction>[
                                      if (context.currentUser?.id ==
                                          groupCall?.ownerId)
                                        CupertinoActionSheetAction(
                                          isDestructiveAction: true,
                                          onPressed: () {
                                            Navigator.pop(context);
                                            BotToast.removeAll("call_overlay");
                                            databaseReference.remove();
                                            DatabaseReference userRef =
                                                FirebaseDatabase.instance
                                                    .ref("Users");
                                            userRef.update({
                                              context.currentUser?.id ?? "":
                                                  "Ended"
                                            });
                                            widget.agoraEngine?.destroy();
                                          },
                                          child: Text(
                                            'End ${widget.isVideo ? "Video" : "Voice"} Call',
                                          ),
                                        ),
                                      CupertinoActionSheetAction(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          BotToast.removeAll("call_overlay");
                                          databaseReference
                                              .child(
                                                  "members/${context.currentUser?.id}")
                                              .remove();
                                          DatabaseReference userRef =
                                              FirebaseDatabase.instance
                                                  .ref("Users");
                                          userRef.update({
                                            context.currentUser?.id ?? "":
                                                "Ended"
                                          });
                                          widget.agoraEngine?.destroy();
                                        },
                                        child: Text(
                                            'Leave ${widget.isVideo ? "Video" : "Voice"} Call'),
                                      ),
                                    ],
                                    cancelButton: CupertinoActionSheetAction(
                                      child: const Text('Cancel'),
                                      onPressed: () {
                                        Navigator.pop(context, 'Cancel');
                                      },
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            initialPosition: AnchoringPosition.topRight,
            dragController: remoteDragController,
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
          child: Icon(
            icon,
            color: Colors.white,
            size: 25,
          ),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  void _listenToFirebaseChanges() {
    final databaseReference =
        FirebaseDatabase.instance.ref("GroupCalls/${widget.callId}");
    onAddListener = databaseReference.onChildAdded.listen((event) {
      getGroupCall();
    });
    onChangeListener = databaseReference.onChildChanged.listen((event) {
      getGroupCall();
    });
    onChangeListener = databaseReference.onChildRemoved.listen((event) {
      getGroupCall();
    });
  }

  void getGroupCall() async {
    final databaseReference =
        FirebaseDatabase.instance.ref("GroupCalls/${widget.callId}");

    final snapshot = await databaseReference.get();
    if (snapshot.exists) {
      Map<dynamic, dynamic>? groupCallResponse = {};
      groupCallResponse = (snapshot.value as Map<dynamic, dynamic>);

      String? ownerId = groupCallResponse['ownerId'];
      String? type = groupCallResponse['type'];
      List<GroupCallMember>? members = [];

      Map<dynamic, dynamic>? membersList =
          (groupCallResponse['members'] as Map<dynamic, dynamic>?) ?? {};
      membersList.forEach((key, value) {
        members.add(
          GroupCallMember(
            id: value['id'],
            name: value['name'],
            image: value['image'],
            phone: value['phone'],
            isMicOn: value['isMicOn'],
            isVideoOn: value['isVideoOn'],
          ),
        );
      });

      if (membersList.isEmpty == true) {
        databaseReference.remove();
      }

      groupCall = GroupCall(ownerId: ownerId, type: type, members: members);
      me = groupCall?.members
          ?.firstWhere((element) => element.id == context.currentUser?.id);
      videoMembers = groupCall?.members
              ?.where((element) => element.isVideoOn == true)
              .toList() ??
          [];
      setState(() {});
    } else {
      if (showingInfo == false) {
        Utils.showAlert(
          context,
          message: "Group Call Has Ended",
          alertImage: R.images.alertInfoImage,
        ).then(
          (value) => Navigator.pop(context),
        );
      }
      showingInfo = true;
    }
  }

  void _getSpeakerStatus() async {
    isSpeakerOn = await widget.agoraEngine?.isSpeakerphoneEnabled() ?? false;
    print(isSpeakerOn);
    setState(() {});
  }
}
