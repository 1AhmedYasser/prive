import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prive/Models/Call/call.dart';
import 'package:prive/Models/Call/call_member.dart';
import 'package:prive/Widgets/AppWidgets/Calls/wave_button.dart';
import 'package:prive/Widgets/Common/cached_image.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wakelock/wakelock.dart';
import '../../../Extras/resources.dart';
import '../../../Helpers/utils.dart';
import '../../../Models/Call/prive_call.dart';
import '../../../UltraNetwork/ultra_constants.dart';
import '../../../UltraNetwork/ultra_network.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;

class GroupCallScreen extends StatefulWidget {
  final bool isVideo;
  final Channel channel;
  final bool isJoining;
  final ScrollController scrollController;
  final RtcEngine? agoraEngine;
  final Call? call;
  const GroupCallScreen(
      {Key? key,
      this.isVideo = false,
      required this.scrollController,
      this.isJoining = false,
      required this.channel,
      this.agoraEngine,
      this.call})
      : super(key: key);

  @override
  State<GroupCallScreen> createState() => _GroupCallScreenState();
}

class _GroupCallScreenState extends State<GroupCallScreen> {
  bool isSpeakerOn = false;
  bool isVideoOn = false;
  bool isMute = true;
  Call? call;
  StreamSubscription? onAddListener;
  StreamSubscription? onChangeListener;
  StreamSubscription? onDeleteListener;
  RtcEngine? agoraEngine;
  List<CallMember> videoMembers = [];
  bool showingInfo = false;
  CancelToken cancelToken = CancelToken();
  bool didEndCall = false;
  rtc_local_view.SurfaceView? localView;
  List<rtc_remote_view.SurfaceView> remoteViews = [];

  @override
  void initState() {
    Wakelock.enable();
    isVideoOn = widget.isVideo;
    if (widget.isJoining) {
      _joinGroupCall();
    } else {
      _createGroupCall();
    }
    _listenToFirebaseChanges();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(22),
          topLeft: Radius.circular(22),
        ),
      ),
      child: SizedBox(
        child: Stack(
          children: [
            ListView(
              controller: widget.scrollController,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.transparent,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              widget.isVideo ? "Video Call" : "Voice Call",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                              ),
                            ).tr(),
                            const SizedBox(height: 5),
                            Text(
                              "${call?.members?.length ?? "0"} ${call?.members?.length == 1 ? "Participant".tr() : "Participants".tr()}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 30),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                if (widget.isVideo)
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 15, left: 15, right: 15, bottom: 0),
                    child: StaggeredGridView.countBuilder(
                      crossAxisCount: 2,
                      itemCount: videoMembers.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) =>
                          Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: videoMembers[index].id == context.currentUser?.id
                            ? Container(
                                height: 200,
                                width: 150,
                                constraints: const BoxConstraints.expand(),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: _renderLocalPreview(),
                                ),
                              )
                            : Container(
                                constraints: const BoxConstraints.expand(),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: index > remoteViews.length
                                      ? const SizedBox.shrink()
                                      : remoteViews[index],
                                ),
                              ),
                      ),
                      staggeredTileBuilder: (int index) {
                        if (videoMembers.length % 2 != 0 &&
                            videoMembers.length - 1 == index) {
                          return const StaggeredTile.count(4, 1);
                        }
                        return const StaggeredTile.count(1, 1);
                      },
                      mainAxisSpacing: 4.0,
                      crossAxisSpacing: 4.0,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 10, left: 25, right: 25, bottom: 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: MediaQuery.removePadding(
                      context: context,
                      removeBottom: true,
                      removeTop: true,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Container(
                            color: Colors.grey.shade900,
                            child: ListTile(
                              leading: SizedBox(
                                height: 44,
                                width: 44,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: CachedImage(
                                    url: call?.members?[index].image ?? "",
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              title: Text(
                                call?.members?[index].name ?? "",
                                style: const TextStyle(color: Colors.white),
                              ),
                              // subtitle: const Text(
                              //   "Listening",
                              //   style: TextStyle(color: Colors.grey),
                              // ),
                              trailing: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Icon(
                                  call?.members?[index].isMicOn == true
                                      ? Icons.mic
                                      : Icons.mic_off_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: call?.members?.length ?? 0,
                        separatorBuilder: (BuildContext context, int index) {
                          return const Divider(
                            height: 0,
                            color: Colors.grey,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 200,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.2, 0.5],
            colors: [
              Colors.transparent,
              Colors.black,
            ],
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 50),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isVideoOn == true)
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      agoraEngine?.switchCamera();
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.switch_camera_rounded,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                if (isVideoOn == true) const SizedBox(height: 13),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    setState(() {
                      if (widget.isVideo) {
                        isVideoOn = !isVideoOn;
                        final ref = FirebaseDatabase.instance.ref(
                            "GroupCalls/${widget.channel.id}/members/${context.currentUser?.id}");
                        ref.update({"isVideoOn": isVideoOn});
                      } else {
                        isSpeakerOn = !isSpeakerOn;
                      }
                    });
                    if (widget.isVideo == false) {
                      await agoraEngine?.setEnableSpeakerphone(isSpeakerOn);
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          widget.isVideo
                              ? isVideoOn
                                  ? Icons.videocam
                                  : Icons.videocam_off
                              : isSpeakerOn
                                  ? FontAwesomeIcons.volumeHigh
                                  : FontAwesomeIcons.volumeLow,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.isVideo ? "Video" : "Speaker",
                        style: const TextStyle(color: Colors.white),
                      ).tr()
                    ],
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
            const Expanded(child: SizedBox()),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 85,
                  height: 85,
                  child: WaveButton(
                    onPressed: (isMute) async {
                      setState(() {
                        this.isMute = isMute;
                      });
                      final ref = FirebaseDatabase.instance.ref(
                          "GroupCalls/${widget.channel.id}/members/${context.currentUser?.id}");
                      ref.update({"isMicOn": !this.isMute});
                      agoraEngine?.muteRemoteAudioStream(
                        int.parse(context.currentUser?.id ?? "0"),
                        this.isMute,
                      );
                      await agoraEngine?.muteLocalAudioStream(this.isMute);
                    },
                    initialIsPlaying: true,
                    playIcon: const Icon(Icons.mic),
                    pauseIcon: const Icon(
                      Icons.mic_off_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isMute ? "Un Mute" : "Mute",
                  style: const TextStyle(color: Colors.white, fontSize: 17),
                ).tr()
              ],
            ),
            const Expanded(child: SizedBox()),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    final databaseReference = FirebaseDatabase.instance
                        .ref("GroupCalls/${widget.channel.id}");
                    showCupertinoModalPopup<void>(
                      context: context,
                      builder: (BuildContext context) => CupertinoActionSheet(
                        title: Text(
                            '${"Are You Sure  You Want to leave this".tr()} ${widget.isVideo ? "video".tr() : "voice".tr()} ${"call ?".tr()}'),
                        actions: <CupertinoActionSheetAction>[
                          if (context.currentUser?.id == call?.ownerId)
                            CupertinoActionSheetAction(
                              isDestructiveAction: true,
                              onPressed: () {
                                didEndCall = true;
                                Navigator.pop(context);
                                Navigator.pop(context);
                                databaseReference.remove();
                                DatabaseReference userRef =
                                    FirebaseDatabase.instance.ref("Users");
                                userRef.update(
                                    {context.currentUser?.id ?? "": "Ended"});
                                agoraEngine?.destroy();
                              },
                              child: Text(
                                  '${"End".tr()} ${widget.isVideo ? "Video".tr() : "Voice".tr()} ${"Call".tr()}'),
                            ),
                          CupertinoActionSheetAction(
                            onPressed: () {
                              didEndCall = true;
                              Navigator.pop(context);
                              Navigator.pop(context);
                              databaseReference
                                  .child("members/${context.currentUser?.id}")
                                  .remove();
                              DatabaseReference userRef =
                                  FirebaseDatabase.instance.ref("Users");
                              userRef.update(
                                  {context.currentUser?.id ?? "": "Ended"});
                              agoraEngine?.destroy();
                            },
                            child: Text(
                                '${"Leave".tr()} ${widget.isVideo ? "Video".tr() : "Voice".tr()} ${"Call".tr()}'),
                          ),
                        ],
                        cancelButton: CupertinoActionSheetAction(
                          child: const Text('Cancel').tr(),
                          onPressed: () {
                            Navigator.pop(context, 'Cancel'.tr());
                          },
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 55,
                    width: 55,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Leave",
                  style: TextStyle(color: Colors.white),
                ).tr()
              ],
            ),
            const SizedBox(width: 50)
          ],
        ),
      ),
    );
  }

  Future<void> _createGroupCall() async {
    CallMember owner = CallMember(
      id: context.currentUser?.id,
      name: context.currentUser?.name,
      image: context.currentUser?.image,
      phone: context.currentUser?.extraData['phone'] as String,
      isMicOn: false,
      isVideoOn: widget.isVideo,
    );
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("GroupCalls/${widget.channel.id}");
    await ref.set({
      "ownerId": context.currentUser?.id ?? "",
      "type": widget.isVideo ? "Video" : "Voice",
      "members": {owner.id: owner.toJson()},
    });
    DatabaseReference userRef = FirebaseDatabase.instance.ref("Users");
    userRef.update({context.currentUser?.id ?? "": "In Call"});
    initAgora();
  }

  void _joinGroupCall() {
    CallMember joiningUser = CallMember(
      id: context.currentUser?.id,
      name: context.currentUser?.name,
      image: context.currentUser?.image,
      phone: context.currentUser?.extraData['phone'] as String,
      isMicOn: widget.call != null
          ? widget.call?.members
                  ?.firstWhere((member) => member.id == context.currentUser?.id)
                  .isMicOn ==
              true
          : false,
      isVideoOn: widget.call != null
          ? widget.call?.members
                  ?.firstWhere((member) => member.id == context.currentUser?.id)
                  .isVideoOn ==
              true
          : widget.isVideo,
    );
    final ref = FirebaseDatabase.instance
        .ref("GroupCalls/${widget.channel.id}/members");
    ref.update({joiningUser.id ?? "": joiningUser.toJson()});
    DatabaseReference userRef = FirebaseDatabase.instance.ref("Users");
    userRef.update({context.currentUser?.id ?? "": "In Call"});

    if (widget.agoraEngine == null) {
      initAgora();
    } else {
      agoraEngine = widget.agoraEngine;
      localView = const rtc_local_view.SurfaceView();
      setState(() {});
    }
  }

  void getCall() async {
    final databaseReference =
        FirebaseDatabase.instance.ref("GroupCalls/${widget.channel.id}");

    final snapshot = await databaseReference.get();
    if (snapshot.exists) {
      Map<dynamic, dynamic>? groupCallResponse = {};
      groupCallResponse = (snapshot.value as Map<dynamic, dynamic>);

      String? ownerId = groupCallResponse['ownerId'];
      String? type = groupCallResponse['type'];
      List<CallMember>? members = [];

      Map<dynamic, dynamic>? membersList =
          (groupCallResponse['members'] as Map<dynamic, dynamic>?) ?? {};
      membersList.forEach((key, value) {
        members.add(
          CallMember(
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

      call = Call(ownerId: ownerId, type: type, members: members);
      videoMembers = call?.members
              ?.where((element) => element.isVideoOn == true)
              .toList() ??
          [];

      if (agoraEngine != null) {
        remoteViews.clear();
        for (var member in videoMembers) {
          remoteViews.add(rtc_remote_view.SurfaceView(
            uid: int.parse(member.id ?? "0"),
            channelId: widget.channel.id ?? "",
          ));
        }
      }
      setState(() {});
    } else {
      if (showingInfo == false) {
        didEndCall = true;
        if (mounted) {
          Utils.showAlert(
            context,
            message: "Group Call Has Ended".tr(),
            alertImage: R.images.alertInfoImage,
          ).then(
            (value) => Navigator.pop(context),
          );
        }
      }
      showingInfo = true;
    }
  }

  void _listenToFirebaseChanges() {
    final databaseReference =
        FirebaseDatabase.instance.ref("GroupCalls/${widget.channel.id}");
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

  Future<void> initAgora() async {
    UltraNetwork.request(
      context,
      roomToken,
      cancelToken: cancelToken,
      formData: FormData.fromMap({
        "Uid": context.currentUser?.id ?? "0",
        "channelName": widget.channel.id,
      }),
      showLoadingIndicator: false,
      showError: false,
    ).then((response) async {
      if (response != null) {
        PriveCall tokenResponse = response;
        await [Permission.camera, Permission.microphone].request();

        agoraEngine = await RtcEngine.createWithContext(
            RtcEngineContext(R.constants.agoraAppId));

        if (widget.isVideo) {
          await agoraEngine?.enableVideo();
          await agoraEngine?.setEnableSpeakerphone(true);
          agoraEngine?.muteLocalAudioStream(true);
          setState(() {});
        } else {
          agoraEngine?.muteLocalAudioStream(true);
          await agoraEngine?.setEnableSpeakerphone(false);
          setState(() {});
        }

        await agoraEngine?.setChannelProfile(ChannelProfile.LiveBroadcasting);
        agoraEngine?.setEventHandler(RtcEngineEventHandler(
            joinChannelSuccess: (String channel, int uid, int elapsed) async {
          print('joinChannelSuccess $channel $uid');
        }, userJoined: (int uid, int elapsed) {
          print('userJoined $uid');
          localView = const rtc_local_view.SurfaceView();
          remoteViews.clear();
          for (var member in videoMembers) {
            remoteViews.add(rtc_remote_view.SurfaceView(
              uid: int.parse(member.id ?? "0"),
              channelId: widget.channel.id ?? "",
            ));
          }
          setState(() {});
        }, cameraReady: () async {
          print("camera ready");
          await agoraEngine?.enableVideo();
          setState(() {});
        }));
        await agoraEngine?.setClientRole(ClientRole.Broadcaster);

        agoraEngine
            ?.joinChannel(tokenResponse.data ?? "", widget.channel.id ?? "",
                null, int.parse(context.currentUser?.id ?? "0"))
            .then(
          (value) {
            localView = const rtc_local_view.SurfaceView();
            remoteViews.clear();

            for (var member in videoMembers) {
              remoteViews.add(rtc_remote_view.SurfaceView(
                uid: int.parse(member.id ?? "0"),
                channelId: widget.channel.id ?? "",
              ));
            }
            print("Number of video members ${videoMembers.length}");
            print("Number of remote views ${remoteViews.length}");

            setState(() {});
          },
        );
        setState(() {});
      }
    });
  }

  Widget _renderLocalPreview() {
    return localView ?? const SizedBox.shrink();
  }

  @override
  void dispose() {
    if (didEndCall == false) {
      Utils.showCallOverlay(
        isGroup: true,
        isVideo: widget.isVideo,
        callId: widget.channel.id ?? "",
        agoraEngine: agoraEngine,
        channel: widget.channel,
      );
    }
    Wakelock.disable();
    onAddListener?.cancel();
    onChangeListener?.cancel();
    onDeleteListener?.cancel();
    super.dispose();
  }
}
