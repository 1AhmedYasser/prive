import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prive/Models/Call/group_call.dart';
import 'package:prive/Models/Call/group_call_member.dart';
import 'package:prive/Widgets/AppWidgets/wave_button.dart';
import 'package:prive/Widgets/Common/cached_image.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../../../Extras/resources.dart';
import '../../../Helpers/Utils.dart';

class GroupCallScreen extends StatefulWidget {
  final bool isVideo;
  final Channel channel;
  final bool isJoining;
  final ScrollController scrollController;
  const GroupCallScreen(
      {Key? key,
      this.isVideo = false,
      required this.scrollController,
      this.isJoining = false,
      required this.channel})
      : super(key: key);

  @override
  State<GroupCallScreen> createState() => _GroupCallScreenState();
}

class _GroupCallScreenState extends State<GroupCallScreen> {
  bool isSpeakerOn = false;
  bool isVideoOn = false;
  bool isMute = false;
  List<GroupCallMember> members = [];
  GroupCall? groupCall;
  StreamSubscription? onAddListener;
  StreamSubscription? onChangeListener;
  StreamSubscription? onDeleteListener;
  RtcEngine? agoraEngine;
  List<GroupCallMember> videoMembers = [];
  bool showingInfo = false;

  @override
  void initState() {
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
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "${groupCall?.members?.length ?? "0"} ${groupCall?.members?.length == 1 ? "Participant" : "Participants"}",
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
                          onTap: () => Navigator.pop(context),
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
                                    url: groupCall?.members?[index].image ?? "",
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              title: Text(
                                groupCall?.members?[index].name ?? "",
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: const Text(
                                "Listening",
                                style: TextStyle(color: Colors.grey),
                              ),
                              trailing: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Icon(
                                  groupCall?.members?[index].isMicOn == true
                                      ? Icons.mic
                                      : Icons.mic_off_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: groupCall?.members?.length ?? 0,
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
                    child: Container(
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.switch_camera_rounded,
                        color: Colors.white,
                        size: 25,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {},
                  ),
                if (isVideoOn == true) const SizedBox(height: 13),
                InkWell(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        child: Icon(
                          widget.isVideo
                              ? isVideoOn
                                  ? Icons.videocam
                                  : Icons.videocam_off
                              : isSpeakerOn
                                  ? FontAwesomeIcons.volumeUp
                                  : FontAwesomeIcons.volumeDown,
                          color: Colors.white,
                          size: 25,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.isVideo ? "Video" : "Speaker",
                        style: const TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
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
                  },
                ),
                const SizedBox(height: 60),
              ],
            ),
            const Expanded(child: SizedBox()),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  child: WaveButton(
                    onPressed: (isMute) {
                      setState(() {
                        this.isMute = isMute;
                      });
                      final ref = FirebaseDatabase.instance.ref(
                          "GroupCalls/${widget.channel.id}/members/${context.currentUser?.id}");
                      ref.update({"isMicOn": !this.isMute});
                    },
                    initialIsPlaying: false,
                    playIcon: const Icon(Icons.mic),
                    pauseIcon: const Icon(Icons.mic_off_rounded),
                  ),
                  width: 85,
                  height: 85,
                ),
                const SizedBox(height: 10),
                Text(
                  isMute ? "Un Mute" : "Mute",
                  style: const TextStyle(color: Colors.white, fontSize: 17),
                )
              ],
            ),
            const Expanded(child: SizedBox()),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
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
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    final databaseReference = FirebaseDatabase.instance
                        .ref("GroupCalls/${widget.channel.id}");
                    showCupertinoModalPopup<void>(
                      context: context,
                      builder: (BuildContext context) => CupertinoActionSheet(
                        title: Text(
                            'Are You Sure  You Want to leave this ${widget.isVideo ? "video" : "voice"} call ?'),
                        actions: <CupertinoActionSheetAction>[
                          if (context.currentUser?.id == groupCall?.ownerId)
                            CupertinoActionSheetAction(
                              isDestructiveAction: true,
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                                databaseReference.remove();
                                DatabaseReference userRef =
                                    FirebaseDatabase.instance.ref("Users");
                                userRef.update(
                                    {context.currentUser?.id ?? "": "Ended"});
                              },
                              child: Text(
                                  'End ${widget.isVideo ? "Video" : "Voice"} Call'),
                            ),
                          CupertinoActionSheetAction(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              databaseReference
                                  .child("members/${context.currentUser?.id}")
                                  .remove();
                              DatabaseReference userRef =
                                  FirebaseDatabase.instance.ref("Users");
                              userRef.update(
                                  {context.currentUser?.id ?? "": "Ended"});
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
                  },
                ),
                const SizedBox(height: 6),
                const Text(
                  "Leave",
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
            const SizedBox(width: 50)
          ],
        ),
      ),
      height: 200,
    );
  }

  Future<void> _createGroupCall() async {
    GroupCallMember owner = GroupCallMember(
      id: context.currentUser?.id,
      name: context.currentUser?.name,
      image: context.currentUser?.image,
      phone: context.currentUser?.extraData['phone'] as String,
      isMicOn: true,
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
  }

  void _joinGroupCall() {
    GroupCallMember joiningUser = GroupCallMember(
      id: context.currentUser?.id,
      name: context.currentUser?.name,
      image: context.currentUser?.image,
      phone: context.currentUser?.extraData['phone'] as String,
      isMicOn: true,
      isVideoOn: widget.isVideo,
    );
    final ref = FirebaseDatabase.instance
        .ref("GroupCalls/${widget.channel.id}/members");
    ref.update({joiningUser.id ?? "": joiningUser.toJson()});
    DatabaseReference userRef = FirebaseDatabase.instance.ref("Users");
    userRef.update({context.currentUser?.id ?? "": "In Call"});
  }

  void getGroupCall() async {
    final databaseReference =
        FirebaseDatabase.instance.ref("GroupCalls/${widget.channel.id}");

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

  void _listenToFirebaseChanges() {
    final databaseReference =
        FirebaseDatabase.instance.ref("GroupCalls/${widget.channel.id}");
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

  @override
  void dispose() {
    onAddListener?.cancel();
    onChangeListener?.cancel();
    onDeleteListener?.cancel();
    // agoraEngine?.destroy();
    super.dispose();
  }
}
