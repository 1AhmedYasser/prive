import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:blur/blur.dart';
import 'package:dio/dio.dart';
import 'package:draggable_widget/draggable_widget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;

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
  final remoteDragController = DragController();
  final FlipCardController _flipController = FlipCardController();
  bool isRemoteVideoOn = true;
  bool isSpeakerOn = false;
  bool isMute = false;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (widget.isJoining == false) {
        _startCall();
      } else {
        _joinCall();
      }
      if (widget.isVideo) {
        setState(() {
          isSpeakerOn = true;
        });
      }
      _listenToFirebaseChanges();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: (_stats != null && widget.isVideo && isRemoteVideoOn)
            ? Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  formatTime(_stats?.duration ?? 0),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
            : null,
        actions: [
          if (widget.isVideo)
            Padding(
              padding: const EdgeInsets.only(right: 30),
              child: GestureDetector(
                onTap: () async {
                  isSpeakerOn = !isSpeakerOn;
                  await agoraEngine?.setEnableSpeakerphone(isSpeakerOn);
                  setState(() {});
                },
                child: Icon(
                  isSpeakerOn
                      ? FontAwesomeIcons.volumeUp
                      : FontAwesomeIcons.volumeDown,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            ),
        ],
      ),
      body: call != null
          ? widget.isVideo
              ? _buildSingleCall(isVideo: true)
              : _buildSingleCall()
          : const SizedBox.shrink(),
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
    onDeleteListener = databaseReference.onChildRemoved.listen((event) {
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
      if (mounted) {
        setState(() {});
      }
    } else {
      if (showingInfo == false) {
        DatabaseReference usersRef = FirebaseDatabase.instance.ref("Users");
        await usersRef.update({
          context.currentUser?.id ?? "": "Ended",
        });
        agoraEngine?.destroy();
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
          await agoraEngine?.setEnableSpeakerphone(true);
          setState(() {});
        } else {
          await agoraEngine?.setEnableSpeakerphone(false);
          setState(() {});
        }

        agoraEngine?.setEventHandler(
          RtcEngineEventHandler(
            joinChannelSuccess: (String channel, int uid, int elapsed) async {
              print('joinChannelSuccess $channel $uid');
            },
            userJoined: (int uid, int elapsed) {
              print('userJoined $uid');
              timer?.cancel();
              setState(() {});
            },
            remoteVideoStateChanged: (uid, state, reason, time) {
              if (state.index == 0) {
                setState(() {
                  isRemoteVideoOn = false;
                });
              } else {
                setState(() {
                  isRemoteVideoOn = true;
                });
              }
            },
            rtcStats: (stats) {
              _stats = stats;
              setState(() {});
            },
          ),
        );
        await agoraEngine?.joinChannel(
          tokenResponse.data ?? "",
          widget.channel.id ?? "",
          null,
          int.parse(context.currentUser?.id ?? "0"),
        );
        setState(() {});
      }
    });
  }

  Widget _buildSingleCall({bool isVideo = false}) {
    return Stack(
      children: [
        if (isVideo)
          Container(
            color: Colors.black,
            child: Center(
              child: _renderRemoteVideo(),
            ),
          ),
        if (isVideo == false)
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
        if (isVideo == false)
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
                      ? "Calling ..."
                      : formatTime(
                          _stats?.duration ?? 0,
                        ),
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
        if (isVideo && call?.members?.length == 2)
          DraggableWidget(
            bottomMargin: 60,
            intialVisibility: true,
            horizontalSpace: 20,
            verticalSpace: 100,
            shadowBorderRadius: 20,
            normalShadow: const BoxShadow(
              color: Colors.transparent,
              offset: Offset(0, 0),
              blurRadius: 2,
            ),
            child: FlipCard(
              controller: _flipController,
              fill: Fill.fillFront,
              front: _buildLocalView(), //_buildLocalView(),
              back: _buildLocalView(),
            ),
            initialPosition: AnchoringPosition.topRight,
            dragController: remoteDragController,
          ),
        Positioned(
          bottom: 50,
          right: 20,
          left: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isVideo)
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    bool isVideoOn = !(call?.members
                            ?.firstWhere((element) =>
                                element.id == context.currentUser?.id)
                            .isVideoOn ??
                        false);
                    final ref = FirebaseDatabase.instance.ref(
                        "SingleCalls/${widget.channel.id}/members/${context.currentUser?.id}");
                    ref.update({"isVideoOn": isVideoOn});
                    agoraEngine?.enableLocalVideo(isVideoOn);
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    child: Icon(
                      call?.members
                                  ?.firstWhere((element) =>
                                      element.id == context.currentUser?.id)
                                  .isVideoOn ==
                              true
                          ? Icons.videocam
                          : Icons.videocam_off,
                      size: 28,
                      color: Colors.white,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(23),
                      color: Colors.grey.withOpacity(0.7),
                    ),
                  ),
                ),
              if (isVideo) const SizedBox(width: 15),
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  isMute = !isMute;
                  final ref = FirebaseDatabase.instance.ref(
                      "SingleCalls/${widget.channel.id}/members/${context.currentUser?.id}");
                  ref.update({"isMicOn": isMute});
                  await agoraEngine?.muteRemoteAudioStream(
                    int.parse(context.currentUser?.id ?? "0"),
                    isMute,
                  );
                  await agoraEngine?.muteLocalAudioStream(isMute);
                  setState(() {});
                },
                child: Container(
                  width: 60,
                  height: 60,
                  child: Icon(
                    isMute ? Icons.mic_off_rounded : Icons.mic,
                    size: 28,
                    color: Colors.white,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(23),
                    color: Colors.grey.withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              if (isVideo == false)
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    isSpeakerOn = !isSpeakerOn;
                    await agoraEngine?.setEnableSpeakerphone(isSpeakerOn);
                    setState(() {});
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        isSpeakerOn
                            ? FontAwesomeIcons.volumeUp
                            : FontAwesomeIcons.volumeDown,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(23),
                      color: Colors.grey.withOpacity(0.7),
                    ),
                  ),
                ),
              if (isVideo)
                Container(
                  width: 60,
                  height: 60,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: IconButton(
                      iconSize: 30,
                      icon: Image.asset(
                        R.images.cameraSwitch,
                      ),
                      onPressed: () {
                        _flipController.toggleCard();
                        agoraEngine?.switchCamera();
                      },
                    ),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(23),
                    color: Colors.grey.withOpacity(0.7),
                  ),
                ),
              const SizedBox(width: 15),
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  final databaseReference = FirebaseDatabase.instance
                      .ref("SingleCalls/${widget.channel.id}");
                  DatabaseReference usersRef =
                      FirebaseDatabase.instance.ref("Users");
                  databaseReference.remove();
                  for (var member in widget.channel.state?.members ?? []) {
                    usersRef.update({member.userId ?? "": "Ended"});
                  }
                  FlutterCallkitIncoming.endAllCalls();
                  Utils.logAnswerOrCancelCall(
                    context,
                    context.currentUser?.id ?? "",
                    "END",
                    formatTime(_stats?.duration ?? 0),
                  );
                },
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.asset(
                    R.images.closeCall,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Container _buildLocalView() {
    return Container(
      height: 200,
      width: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey.shade700,
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _renderLocalPreview(),
        ),
      ),
    );
  }

  Widget _renderRemoteVideo() {
    if (call?.members?.length == 2) {
      return rtc_remote_view.SurfaceView(
        uid: int.parse(call?.members
                ?.firstWhere((element) => element.id != context.currentUser?.id)
                .id ??
            "0"),
        channelId: widget.channel.id ?? "",
      );
    } else {
      return _buildCallingState(isRemoteVideoOn: false);
    }
  }

  Widget _renderLocalPreview() {
    return const rtc_local_view.SurfaceView();
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
