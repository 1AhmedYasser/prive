import 'dart:async';
import 'dart:io';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:badges/badges.dart';
import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prive/Helpers/group_call_menu_dialog.dart';
import 'package:prive/Models/Call/call.dart';
import 'package:prive/Models/Call/call_member.dart';
import 'package:prive/Providers/volume_provider.dart';
import 'package:prive/Widgets/AppWidgets/Calls/wave_button.dart';
import 'package:prive/Widgets/Common/cached_image.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:provider/provider.dart';
import 'package:replay_kit_launcher/replay_kit_launcher.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wakelock/wakelock.dart';
import '../../../Extras/resources.dart';
import '../../../Helpers/utils.dart';
import '../../../Models/Call/prive_call.dart';
import '../../../UltraNetwork/ultra_constants.dart';
import 'package:collection/collection.dart';
import '../../../UltraNetwork/ultra_network.dart';
import '../../../Widgets/AppWidgets/Rooms/kicked_members_widget.dart';

class GroupCallScreen extends StatefulWidget {
  final bool isVideo;
  final Channel channel;
  final bool isJoining;
  final ScrollController scrollController;
  final RtcEngine? agoraEngine;
  final BuildContext parentContext;
  final Call? call;
  const GroupCallScreen(
      {Key? key,
      this.isVideo = false,
      required this.scrollController,
      this.isJoining = false,
      required this.channel,
      this.agoraEngine,
      required this.parentContext,
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
  VideoViewController? localView;
  List<VideoViewController> remoteViews = [];
  bool isSharingScreen = false;
  bool isHeadphonesOn = true;
  CallMember? me;
  List<String> kickedMembersIds = [];
  int channelUid = 0;

  @override
  void initState() {
    if (Platform.isAndroid) {
      _initForegroundTask();
    }
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 87, minWidth: 87),
                          child: call?.ownerId == context.currentUser?.id && (call?.members?.length ?? 1) > 1
                              ? ElevatedButton(
                                  onPressed: () {
                                    if ((call?.members?.length ?? 0) > 1) {
                                      if (call?.isMuteAllEnabled == false) {
                                        // Mute All
                                        final ref = FirebaseDatabase.instance.ref("GroupCalls/${widget.channel.id}");
                                        ref.update({"isMuteAllEnabled": true});
                                        call?.members?.forEach((member) {
                                          if (member.id != context.currentUser?.id) {
                                            final userRef = FirebaseDatabase.instance
                                                .ref("GroupCalls/${widget.channel.id}/members/${member.id}");
                                            userRef.update({"isMicOn": false, "hasPermissionToSpeak": false});
                                          }
                                        });
                                      } else {
                                        // UnMute All
                                        final ref = FirebaseDatabase.instance.ref("GroupCalls/${widget.channel.id}");
                                        ref.update({"isMuteAllEnabled": false});
                                        call?.members?.forEach((member) {
                                          if (member.id != context.currentUser?.id) {
                                            final userRef = FirebaseDatabase.instance
                                                .ref("GroupCalls/${widget.channel.id}/members/${member.id}");
                                            userRef.update({"hasPermissionToSpeak": true});
                                          }
                                        });
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade800,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(3),
                                    child: Text(
                                      call?.isMuteAllEnabled == true ? 'UnMute All' : 'Mute All',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 50),
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
                            // if (mounted) {
                            //   Provider.of<CallProvider>(context, listen: false).changeOverlayState(true);
                            // }
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
                    padding: const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 0),
                    child: StaggeredGridView.countBuilder(
                      crossAxisCount: 2,
                      itemCount: videoMembers.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) => Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: videoMembers[index].id == context.currentUser?.id
                            ? Consumer<VolumeProvider>(
                                builder: (context, provider, ch) {
                                  return Container(
                                    height: 200,
                                    width: 150,
                                    constraints: const BoxConstraints.expand(),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: call?.members?[index].isSpeaking == true
                                            ? Colors.green
                                            : Colors.transparent,
                                        width: call?.members?[index].isSpeaking == true ? 1 : 0,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: _renderLocalPreview(),
                                    ),
                                  );
                                },
                              )
                            : Consumer<VolumeProvider>(
                                builder: (context, provider, ch) {
                                  return Container(
                                    constraints: const BoxConstraints.expand(),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: call?.members?[index].isSpeaking == true
                                            ? Colors.green
                                            : Colors.transparent,
                                        width: call?.members?[index].isSpeaking == true ? 1 : 0,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: index > remoteViews.length
                                          ? const SizedBox.shrink()
                                          : AgoraVideoView(
                                              controller: remoteViews[index],
                                            ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      staggeredTileBuilder: (int index) {
                        if (videoMembers.length % 2 != 0 && videoMembers.length - 1 == index) {
                          return const StaggeredTile.count(4, 1);
                        }
                        return const StaggeredTile.count(1, 1);
                      },
                      mainAxisSpacing: 4.0,
                      crossAxisSpacing: 4.0,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 25, right: 25, bottom: 0),
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
                              subtitle: Consumer<VolumeProvider>(
                                builder: (context, provider, ch) {
                                  return Text(
                                    call?.members?[index].isSpeaking == true ? "Speaking" : "Listening",
                                    style: const TextStyle(color: Colors.grey),
                                  );
                                },
                              ),
                              trailing: Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      call?.members?[index].isMicOn == true ? Icons.mic : Icons.mic_off_rounded,
                                      color: call?.members?[index].hasPermissionToSpeak == true
                                          ? Colors.white
                                          : Colors.red,
                                    ),
                                    if (context.currentUser?.id == call?.ownerId)
                                      if (call?.members?[index].id != context.currentUser?.id)
                                        GestureDetector(
                                          onTap: () {
                                            GroupCallMenuDialog.showMemberMenu(
                                              context,
                                              call?.members?[index],
                                              onKickPressed: () {
                                                CallMember? member = call?.members?[index];
                                                final ref =
                                                    FirebaseDatabase.instance.ref("GroupCalls/${widget.channel.id}");
                                                ref.child('kickedMembers/${member?.id}').update({
                                                  "id": member?.id,
                                                  "name": member?.name,
                                                  "image": member?.image,
                                                  "phone": member?.phone,
                                                  "hasPermissionToSpeak": member?.hasPermissionToSpeak,
                                                  "isMicOn": member?.isMicOn,
                                                  "isHeadphonesOn": member?.isHeadphonesOn,
                                                  "isVideoOn": member?.isVideoOn,
                                                });
                                              },
                                              onMutePressed: () {
                                                final ref = FirebaseDatabase.instance.ref(
                                                    "GroupCalls/${widget.channel.id}/members/${call?.members?[index].id}");

                                                if (call?.members?[index].hasPermissionToSpeak == true) {
                                                  ref.update({"isMicOn": false, "hasPermissionToSpeak": false});
                                                } else {
                                                  ref.update({"hasPermissionToSpeak": true});
                                                }
                                              },
                                            );
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Icon(
                                              Icons.more_vert_rounded,
                                              color: Colors.white,
                                              size: 27,
                                            ),
                                          ),
                                        )
                                  ],
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
      //height: 250,
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
        child: Padding(
          padding: const EdgeInsets.only(bottom: 35),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(width: 50),
              Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        isHeadphonesOn = !isHeadphonesOn;
                        final ref = FirebaseDatabase.instance
                            .ref("GroupCalls/${widget.channel.id}/members/${context.currentUser?.id}");
                        if (isHeadphonesOn == false) {
                          ref.update({"isMicOn": false, "isHeadphonesOn": false});
                        } else {
                          ref.update({"isHeadphonesOn": true});
                        }
                        setState(() {});
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          isHeadphonesOn ? Icons.headset_rounded : Icons.headset_off_rounded,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ),
                    const SizedBox(height: 13),
                    if (isVideoOn == true)
                      InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          if (agoraEngine != null) {
                            if (isSharingScreen == false) {
                              _startScreenShare();
                            } else {
                              _stopScreenShare();
                            }
                          }
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Icon(
                            isSharingScreen == false ? Icons.mobile_screen_share_rounded : Icons.mobile_off_rounded,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ),
                    if (isVideoOn == true) const SizedBox(height: 13),
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
                            final ref = FirebaseDatabase.instance
                                .ref("GroupCalls/${widget.channel.id}/members/${context.currentUser?.id}");
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
                  ],
                ),
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
                        if (isHeadphonesOn && (me?.hasPermissionToSpeak == true)) {
                          setState(() {
                            this.isMute = isMute;
                          });
                          final ref = FirebaseDatabase.instance
                              .ref("GroupCalls/${widget.channel.id}/members/${context.currentUser?.id}");
                          ref.update({"isMicOn": !this.isMute});
                          agoraEngine?.muteRemoteAudioStream(
                            uid: int.parse(context.currentUser?.id ?? "0"),
                            mute: this.isMute,
                          );
                          await agoraEngine?.muteLocalAudioStream(this.isMute);
                        }
                      },
                      initialIsPlaying: isMute,
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
              Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (call?.ownerId == context.currentUser?.id && call?.kickedMembers?.isNotEmpty == true)
                      Badge(
                        badgeContent: Text(
                          "${call?.kickedMembers?.length}",
                          style: const TextStyle(color: Colors.white),
                        ),
                        showBadge: call?.kickedMembers?.isNotEmpty == true ? true : false,
                        position: BadgePosition.topEnd(end: -4),
                        padding: const EdgeInsets.all(7),
                        badgeColor: Theme.of(context).primaryColorDark,
                        child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            showMaterialModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => SingleChildScrollView(
                                controller: ModalScrollController.of(context),
                                child: KickedMembersWidget(
                                  ref: 'GroupCalls/${widget.channel.id}/kickedMembers',
                                  agoraEngine: agoraEngine,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              height: 55,
                              width: 55,
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Icon(
                                FontAwesomeIcons.ban,
                                size: 25,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        final databaseReference = FirebaseDatabase.instance.ref("GroupCalls/${widget.channel.id}");
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
                                    endCall(context, databaseReference);
                                  },
                                  child: Text(
                                      '${"End".tr()} ${widget.isVideo ? "Video".tr() : "Voice".tr()} ${"Call".tr()}'),
                                ),
                              CupertinoActionSheetAction(
                                onPressed: () {
                                  Navigator.pop(context);
                                  leaveCall(context, databaseReference);
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
              ),
              const SizedBox(width: 50)
            ],
          ),
        ),
      ),
    );
  }

  void endCall(BuildContext context, DatabaseReference databaseReference) async {
    didEndCall = true;
    Navigator.pop(context);
    Navigator.pop(context);
    databaseReference.remove();
    _stopForegroundTask();
    DatabaseReference userRef = FirebaseDatabase.instance.ref("Users");
    userRef.update({context.currentUser?.id ?? "": "Ended"});
    await agoraEngine?.leaveChannel();
  }

  void leaveCall(BuildContext context, DatabaseReference databaseReference) async {
    didEndCall = true;
    Navigator.pop(context);
    databaseReference.child("members/${context.currentUser?.id}").remove();
    _stopForegroundTask();
    DatabaseReference userRef = FirebaseDatabase.instance.ref("Users");
    userRef.update({context.currentUser?.id ?? "": "Ended"});
    await agoraEngine?.leaveChannel();
  }

  Future<void> _createGroupCall() async {
    CallMember owner = CallMember(
      id: context.currentUser?.id,
      name: context.currentUser?.name,
      image: context.currentUser?.image,
      isHeadphonesOn: true,
      hasPermissionToSpeak: true,
      phone: context.currentUser?.extraData['phone'] as String,
      isMicOn: false,
      isVideoOn: widget.isVideo,
    );
    DatabaseReference ref = FirebaseDatabase.instance.ref("GroupCalls/${widget.channel.id}");
    await ref.set({
      "ownerId": context.currentUser?.id ?? "",
      "type": widget.isVideo ? "Video" : "Voice",
      "members": {owner.id: owner.toJson()},
      "isMuteAllEnabled": false
    });
    DatabaseReference userRef = FirebaseDatabase.instance.ref("Users");
    userRef.update({context.currentUser?.id ?? "": "In Call"});
    initAgora();
  }

  Future<void> _joinGroupCall() async {
    CallMember joiningUser = CallMember(
      id: context.currentUser?.id,
      name: context.currentUser?.name,
      image: context.currentUser?.image,
      isHeadphonesOn: widget.call != null
          ? widget.call?.members?.firstWhere((member) => member.id == context.currentUser?.id).isHeadphonesOn
          : true,
      phone: context.currentUser?.extraData['phone'] as String,
      hasPermissionToSpeak: widget.call != null
          ? widget.call?.members?.firstWhere((member) => member.id == context.currentUser?.id).hasPermissionToSpeak
          : true,
      isMicOn: widget.call != null
          ? widget.call?.members?.firstWhere((member) => member.id == context.currentUser?.id).isMicOn == true
          : false,
      isVideoOn: widget.call != null
          ? widget.call?.members?.firstWhere((member) => member.id == context.currentUser?.id).isVideoOn == true
          : widget.isVideo,
    );
    final ref = FirebaseDatabase.instance.ref("GroupCalls/${widget.channel.id}/members");
    ref.update({joiningUser.id ?? "": joiningUser.toJson()});
    DatabaseReference userRef = FirebaseDatabase.instance.ref("Users");
    userRef.update({context.currentUser?.id ?? "": "In Call"});

    if (widget.agoraEngine == null) {
      initAgora();
    } else {
      isSpeakerOn = await widget.agoraEngine?.isSpeakerphoneEnabled() ?? false;
      agoraEngine = widget.agoraEngine;
      localView = VideoViewController(
        rtcEngine: agoraEngine!,
        canvas: VideoCanvas(uid: channelUid),
      );
      setState(() {});
    }
  }

  void getCall() async {
    final databaseReference = FirebaseDatabase.instance.ref("GroupCalls/${widget.channel.id}");

    final snapshot = await databaseReference.get();
    if (snapshot.exists) {
      Map<dynamic, dynamic>? groupCallResponse = {};
      groupCallResponse = (snapshot.value as Map<dynamic, dynamic>);

      String? ownerId = groupCallResponse['ownerId'];
      String? type = groupCallResponse['type'];
      bool? isMuteAllEnabled = groupCallResponse['isMuteAllEnabled'];
      List<CallMember>? members = [];
      List<CallMember>? kickedMembers = [];

      Map<dynamic, dynamic>? membersList = (groupCallResponse['members'] as Map<dynamic, dynamic>?) ?? {};
      membersList.forEach((key, value) {
        members.add(
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

      Map<dynamic, dynamic>? kickedMembersList = (groupCallResponse['kickedMembers'] as Map<dynamic, dynamic>?) ?? {};
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
        isMuteAllEnabled: isMuteAllEnabled,
      );
      me = call?.members?.firstWhereOrNull((element) => element.id == context.currentUser?.id);
      kickedMembersIds = call?.kickedMembers?.map((e) => e.id ?? "").toList() ?? [];

      // Check If Kicked Your Kicked Out From The Call
      if (kickedMembersIds.contains(context.currentUser?.id)) {
        if (mounted) {
          leaveCall(context, databaseReference);
          Utils.showAlert(
            context,
            message: "You Have Been Kicked Out Of This Call".tr(),
            alertImage: R.images.alertInfoImage,
          );
        }
      }

      // Handle Mute All
      if (members.length == 1 && isMuteAllEnabled == true && ownerId == context.currentUser?.id) {
        final ref = FirebaseDatabase.instance.ref("GroupCalls/${widget.channel.id}");
        ref.update({"isMuteAllEnabled": false});
      }

      // Handle Mute All When All Members has permissions to speak
      if (members.length > 1 && isMuteAllEnabled == true && ownerId == context.currentUser?.id) {
        List<CallMember> callMembersWhoCanSpeak =
            call?.members?.where((e) => e.hasPermissionToSpeak == true && e.id != context.currentUser?.id).toList() ??
                [];

        if (callMembersWhoCanSpeak.length == (call?.members?.length ?? 1) - 1) {
          final ref = FirebaseDatabase.instance.ref("GroupCalls/${widget.channel.id}");
          ref.update({"isMuteAllEnabled": false});
        }
      }

      videoMembers = call?.members?.where((element) => element.isVideoOn == true).toList() ?? [];

      isHeadphonesOn = me?.isHeadphonesOn ?? true;
      isMute = !(me?.isMicOn ?? false);
      if (isHeadphonesOn == false) {
        await agoraEngine?.muteAllRemoteAudioStreams(true);
        await agoraEngine?.muteRemoteAudioStream(
          uid: int.parse(context.currentUser?.id ?? "0"),
          mute: false,
        );
        await agoraEngine?.muteLocalAudioStream(true);
      } else {
        await agoraEngine?.muteAllRemoteAudioStreams(false);
      }

      if (me?.hasPermissionToSpeak == false) {
        await agoraEngine?.muteLocalAudioStream(true);
      }

      if (agoraEngine != null) {
        remoteViews.clear();
        if (widget.isVideo) {
          for (var member in videoMembers) {
            remoteViews.add(
              VideoViewController.remote(
                rtcEngine: agoraEngine!,
                canvas: VideoCanvas(
                  uid: int.parse(member.id ?? "0"),
                ),
                connection: RtcConnection(channelId: widget.channel.id),
              ),
            );
          }
        }
      }
      setState(() {});
    } else {
      if (showingInfo == false) {
        didEndCall = true;
        _stopForegroundTask();
        if (mounted) {
          Utils.showAlert(
            context,
            message: "Group Call Has Ended".tr(),
            alertImage: R.images.alertInfoImage,
          ).then(
            (value) {
              if (mounted) {
                Navigator.pop(context);
              }
            },
          );
        }
      }
      showingInfo = true;
    }
  }

  void _listenToFirebaseChanges() {
    final databaseReference = FirebaseDatabase.instance.ref("GroupCalls/${widget.channel.id}");
    onAddListener = databaseReference.onChildAdded.listen((event) {
      if (mounted) {
        getCall();
      }
    });
    onChangeListener = databaseReference.onChildChanged.listen((event) {
      if (mounted) {
        getCall();
      }
    });
    onDeleteListener = databaseReference.onChildRemoved.listen((event) {
      if (mounted) {
        getCall();
      }
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

        agoraEngine = createAgoraRtcEngine();
        await agoraEngine?.initialize(RtcEngineContext(appId: R.constants.agoraAppId));

        if (widget.isVideo) {
          await agoraEngine?.enableVideo();
          agoraEngine?.muteLocalAudioStream(true);
          if (mounted) {
            setState(() {});
          }
        } else {
          agoraEngine?.muteLocalAudioStream(true);
          if (mounted) {
            setState(() {});
          }
        }

        await agoraEngine?.setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);
        await agoraEngine?.enableAudioVolumeIndication(interval: 250, smooth: 6, reportVad: true);
        agoraEngine?.registerEventHandler(
          RtcEngineEventHandler(
            onJoinChannelSuccess: (connection, uid) async {
              print('joinChannelSuccess $uid');
              channelUid = uid;
              if (mounted) {
                setState(() {});
              }
              if (widget.isVideo) {
                agoraEngine?.setEnableSpeakerphone(true);
              } else {
                agoraEngine?.setEnableSpeakerphone(false);
              }
            },
            onUserJoined: (connection, uid, elapsed) {
              print('userJoined $uid');
              localView = VideoViewController(
                rtcEngine: agoraEngine!,
                canvas: VideoCanvas(uid: channelUid),
              );
              remoteViews.clear();
              for (var member in videoMembers) {
                remoteViews.add(
                  VideoViewController.remote(
                    rtcEngine: agoraEngine!,
                    canvas: VideoCanvas(
                      uid: int.parse(member.id ?? "0"),
                    ),
                    connection: RtcConnection(channelId: widget.channel.id),
                  ),
                );
              }
              if (mounted) {
                setState(() {});
              }
            },
            onCameraReady: () async {
              print("camera ready");
              await agoraEngine?.enableVideo();
              if (mounted) {
                setState(() {});
              }
            },
            onAudioVolumeIndication: (connection, volumeInfo, v, k) {
              for (var speaker in volumeInfo) {
                if ((speaker.volume ?? 0) > 5) {
                  try {
                    changeVolumeStatus(speaker.uid, true);
                  } catch (error) {
                    print('Error:${error.toString()}');
                  }
                } else {
                  changeVolumeStatus(speaker.uid, false);
                }
              }
            },
          ),
        );
        await agoraEngine?.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
        await agoraEngine?.startPreview();
        await agoraEngine
            ?.joinChannel(
          token: tokenResponse.data ?? "",
          channelId: widget.channel.id ?? "",
          uid: int.parse(context.currentUser?.id ?? "0"),
          options: ChannelMediaOptions(
            token: tokenResponse.data ?? "",
            clientRoleType: ClientRoleType.clientRoleBroadcaster,
            channelProfile: ChannelProfileType.channelProfileCommunication1v1,
          ),
        )
            .then(
          (value) {
            localView = VideoViewController(
              rtcEngine: agoraEngine!,
              canvas: VideoCanvas(uid: channelUid),
            );
            remoteViews.clear();

            for (var member in videoMembers) {
              remoteViews.add(
                VideoViewController.remote(
                  rtcEngine: agoraEngine!,
                  canvas: VideoCanvas(
                    uid: int.parse(member.id ?? "0"),
                  ),
                  connection: RtcConnection(channelId: widget.channel.id),
                ),
              );
            }
            print("Number of video members ${videoMembers.length}");
            print("Number of remote views ${remoteViews.length}");
            if (mounted) {
              setState(() {});
            }
          },
        );
        agoraEngine?.setParameters('{"che.audio.opensl":true}');
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  Widget _renderLocalPreview() {
    return localView != null
        ? AgoraVideoView(
            controller: localView!,
          )
        : const SizedBox.shrink();
  }

  Future<void> _initForegroundTask() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'call_channel_id',
        channelName: 'Prive',
        channelDescription: 'Call In Progress',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher_icon',
        ),
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        autoRunOnBoot: true,
        allowWifiLock: true,
      ),
    );
    await FlutterForegroundTask.startService(notificationTitle: "Prive", notificationText: "Call In Progress");
  }

  Future<void> _stopForegroundTask() async {
    if (Platform.isAndroid) {
      await FlutterForegroundTask.stopService();
    }
  }

  void changeVolumeStatus(int? speakerId, bool status) {
    if (mounted) {
      if (speakerId == 0) {
        call?.members?.firstWhereOrNull((member) => (member.id ?? 0) == context.currentUser?.id)?.isSpeaking = status;
      } else {
        call?.members?.firstWhereOrNull((member) => (member.id ?? 0) == "$speakerId")?.isSpeaking = status;
      }
      Provider.of<VolumeProvider>(context, listen: false).refreshVolumes();
    }
  }

  void _startScreenShare() async {
    await agoraEngine?.startScreenCapture(const ScreenCaptureParameters2(captureAudio: true, captureVideo: true));
    await agoraEngine?.startPreview(sourceType: VideoSourceType.videoSourceScreen);

    if (Platform.isIOS) {
      ReplayKitLauncher.launchReplayKitBroadcast('ScreenSharing');
    }
    _updateScreenShareChannelMediaOptions();

    setState(() {
      isSharingScreen = true;
    });
  }

  Future<void> _updateScreenShareChannelMediaOptions({bool startShare = true}) async {
    await agoraEngine?.updateChannelMediaOptions(
      ChannelMediaOptions(
        publishScreenTrack: startShare,
        publishSecondaryScreenTrack: startShare,
        publishCameraTrack: !startShare,
        publishMicrophoneTrack: !startShare,
        publishScreenCaptureAudio: startShare,
        publishScreenCaptureVideo: startShare,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  void _stopScreenShare() async {
    print("Stop Screen Sharing");
    await agoraEngine?.stopScreenCapture();
    _updateScreenShareChannelMediaOptions(startShare: false);

    if (Platform.isIOS) {
      ReplayKitLauncher.finishReplayKitBroadcast('');
    }
    setState(() {
      isSharingScreen = false;
    });
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
