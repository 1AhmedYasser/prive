import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:blur/blur.dart';
import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../../../Extras/resources.dart';
import '../../../Helpers/stream_manager.dart';
import '../../../Helpers/utils.dart';
import '../../../Models/Call/call.dart';
import '../../../Models/Call/call_member.dart';
import '../../../Models/Call/prive_call.dart';
import '../../../UltraNetwork/ultra_constants.dart';
import '../../../UltraNetwork/ultra_network.dart';

class SingleCallScreen extends StatefulWidget {
  final bool isVideo;
  final Channel channel;
  final bool isJoining;
  const SingleCallScreen({
    Key? key,
    this.isVideo = false,
    required this.channel,
    this.isJoining = false,
  }) : super(key: key);

  @override
  State<SingleCallScreen> createState() => _SingleCallScreenState();
}

class _SingleCallScreenState extends State<SingleCallScreen> {
  final player = AudioPlayer();
  Timer? timer;
  CancelToken cancelToken = CancelToken();
  Call? call;
  StreamSubscription? onAddListener;
  StreamSubscription? onChangeListener;
  StreamSubscription? onDeleteListener;
  List<CallMember> videoMembers = [];
  bool showingInfo = false;
  RtcEngine? agoraEngine;
  RtcStats? _stats;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (widget.isJoining == false) {
        _startCall();
      } else {
        _joinCall();
      }
      _listenToFirebaseChanges();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: call != null ? _buildCallingState() : const SizedBox.shrink(),
    );
  }

  void _startCall() {
    // Setup Ringing Tone
    _setupRingingTone();
    timer = Timer.periodic(
      const Duration(seconds: 5),
      (Timer t) => _setupRingingTone(),
    );
    _createCall();
  }

  void _setupRingingTone() async {
    await player.setAsset(R.sounds.calling);
    player.play();
  }

  Widget _buildCallingState({bool isRemoteVideoOn = true}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          Positioned.fill(
            child: Blur(
              blur: 12,
              blurColor: Colors.black,
              child: Center(
                child: ChannelAvatar(
                  borderRadius: BorderRadius.circular(0),
                  channel: widget.channel,
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width,
                    maxHeight: MediaQuery.of(context).size.height,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChannelAvatar(
                  borderRadius: BorderRadius.circular(50),
                  channel: widget.channel,
                  constraints: const BoxConstraints(
                    maxWidth: 100,
                    maxHeight: 100,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  StreamManager.getChannelName(
                    widget.channel,
                    context.currentUser!,
                  ),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 21,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  call?.members?.length == 1
                      ? "Calling"
                      : _stats != null
                          ? formatTime(_stats?.duration ?? 0)
                          : "Connecting",
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
          if (isRemoteVideoOn)
            Positioned(
              bottom: MediaQuery.of(context).size.height / 8,
              left: 0,
              right: 0,
              child: IconButton(
                iconSize: 60,
                icon: Image.asset(
                  R.images.closeCall,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  final databaseReference = FirebaseDatabase.instance
                      .ref("SingleCalls/${widget.channel.id}");
                  DatabaseReference usersRef =
                      FirebaseDatabase.instance.ref("Users");
                  databaseReference.remove();
                  for (var member in widget.channel.state?.members ?? []) {
                    usersRef.update({member.userId ?? "": "Ended"});
                  }
                },
              ),
            )
        ],
      ),
    );
  }

  Future<void> _createCall() async {
    CallMember owner = CallMember(
      id: context.currentUser?.id,
      name: context.currentUser?.name,
      image: context.currentUser?.image,
      phone: context.currentUser?.extraData['phone'] as String,
      isMicOn: false,
      isVideoOn: widget.isVideo,
    );
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("SingleCalls/${widget.channel.id}");
    await ref.set({
      "ownerId": context.currentUser?.id ?? "",
      "type": widget.isVideo ? "Video" : "Voice",
      "members": {owner.id: owner.toJson()},
    });
    DatabaseReference userRef = FirebaseDatabase.instance.ref("Users");
    userRef.update({context.currentUser?.id ?? "": "In Call"});
    initAgora();
  }

  void _listenToFirebaseChanges() {
    final databaseReference =
        FirebaseDatabase.instance.ref("SingleCalls/${widget.channel.id}");
    onAddListener = databaseReference.onChildAdded.listen((event) {
      getCall();
    });
    onChangeListener = databaseReference.onChildChanged.listen((event) {
      getCall();
    });
    onChangeListener = databaseReference.onChildRemoved.listen((event) {
      getCall();
    });
  }

  void _joinCall() {
    CallMember joiningUser = CallMember(
      id: context.currentUser?.id,
      name: context.currentUser?.name,
      image: context.currentUser?.image,
      phone: context.currentUser?.extraData['phone'] as String,
      isMicOn: false,
      isVideoOn: widget.isVideo,
    );
    final ref = FirebaseDatabase.instance
        .ref("SingleCalls/${widget.channel.id}/members");
    ref.update({joiningUser.id ?? "": joiningUser.toJson()});
    DatabaseReference userRef = FirebaseDatabase.instance.ref("Users");
    userRef.update({context.currentUser?.id ?? "": "In Call"});
    initAgora();
  }

  void getCall() async {
    final databaseReference =
        FirebaseDatabase.instance.ref("SingleCalls/${widget.channel.id}");

    final snapshot = await databaseReference.get();
    if (snapshot.exists) {
      Map<dynamic, dynamic>? callResponse = {};
      callResponse = (snapshot.value as Map<dynamic, dynamic>);

      String? ownerId = callResponse['ownerId'];
      String? type = callResponse['type'];
      List<CallMember>? members = [];

      Map<dynamic, dynamic>? membersList =
          (callResponse['members'] as Map<dynamic, dynamic>?) ?? {};
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

      if (call?.members?.length == 2) {
        player.dispose();
        timer?.cancel();
      }
      setState(() {});
    } else {
      if (showingInfo == false) {
        DatabaseReference usersRef = FirebaseDatabase.instance.ref("Users");
        await usersRef.update({
          context.currentUser?.id ?? "": "Ended",
        });
        Utils.showAlert(
          context,
          message: "Call Has Ended",
          alertImage: R.images.alertInfoImage,
        ).then(
          (value) => Navigator.pop(context),
        );
      }
      showingInfo = true;
    }
  }

  String formatTime(int seconds) {
    return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');
  }

  Future<void> initAgora() async {
    UltraNetwork.request(
      context,
      makeACall,
      cancelToken: cancelToken,
      formData: FormData.fromMap({
        "Uid": context.currentUser?.id,
        "channelName": widget.channel.id,
        "caller_name": context.currentUser?.name,
        "ids": widget.isJoining
            ? {}
            : widget.channel.state?.members
                .firstWhere(
                    (element) => element.userId != context.currentUser?.id)
                .userId,
        "has_video": widget.isVideo,
      }),
      showLoadingIndicator: false,
      showError: false,
    ).then((response) async {
      if (response != null) {
        PriveCall tokenResponse = response;
        if (widget.isVideo) {
          await [Permission.camera, Permission.microphone].request();
        } else {
          await [Permission.microphone].request();
        }

        agoraEngine = await RtcEngine.createWithContext(
            RtcEngineContext(R.constants.agoraAppId));

        if (widget.isVideo) {
          await agoraEngine?.enableVideo();
          setState(() {});
        } else {
          await agoraEngine?.setEnableSpeakerphone(false);
          setState(() {});
        }

        await agoraEngine?.setChannelProfile(ChannelProfile.LiveBroadcasting);
        agoraEngine?.setEventHandler(RtcEngineEventHandler(
            joinChannelSuccess: (String channel, int uid, int elapsed) async {
          print('joinChannelSuccess $channel $uid');
        }, userJoined: (int uid, int elapsed) {
          print('userJoined $uid');
        }, cameraReady: () async {
          print("camera ready");
          await agoraEngine?.enableVideo();
          setState(() {});
        }));
        await agoraEngine?.setClientRole(ClientRole.Broadcaster);

        await agoraEngine?.joinChannel(
            tokenResponse.data ?? "",
            widget.channel.id ?? "",
            null,
            int.parse(context.currentUser?.id ?? "0"));
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    if (mounted) {
      player.dispose();
      timer?.cancel();
    }
    super.dispose();
  }
}
