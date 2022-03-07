import 'dart:async';
import 'dart:convert';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:blur/blur.dart';
import 'package:callkeep/callkeep.dart';
import 'package:dio/dio.dart';
import 'package:draggable_widget/draggable_widget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Helpers/utils.dart';
import 'package:prive/Models/Call/prive_call.dart';
import 'package:prive/UltraNetwork/ultra_constants.dart';
import 'package:prive/UltraNetwork/ultra_network.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;

import '../../../UltraNetwork/ultra_loading_indicator.dart';

class CallScreen extends StatefulWidget {
  final Channel? channel;
  final bool isJoining;
  final String channelName;
  final bool isVideo;
  final FlutterCallkeep? callKeep;

  const CallScreen(
      {Key? key,
      this.channel,
      this.isJoining = false,
      this.channelName = "",
      required this.isVideo,
      this.callKeep})
      : super(key: key);

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final player = AudioPlayer();
  CancelToken cancelToken = CancelToken();
  String channelName = const Uuid().v4();
  RtcEngine? engine;
  List<String> users = [];
  bool isCalling = true;
  String usersToCall = "";
  Timer? timer;
  int? _remoteUid;
  final remoteDragController = DragController();
  GlobalKey<FlipCardState> flipKey = GlobalKey<FlipCardState>();
  bool volumeOn = true;
  bool isMuted = false;
  bool isVideoOn = true;
  late FlipCardController _flipController;
  RtcStats? _stats;
  late DatabaseReference ref;
  StreamSubscription? listener;

  @override
  void initState() {
    _flipController = FlipCardController();
    if (widget.isJoining == true) {
      channelName = widget.channelName;
      _joinChannel();
    } else {
      _setupRingingTone();
      timer = Timer.periodic(
          const Duration(seconds: 5), (Timer t) => _setupRingingTone());
      _getUsers();
    }
    super.initState();
  }

  void _getUsers() async {
    String me = await Utils.getString(R.pref.userId) ?? "";
    for (var element in widget.channel?.state?.members ?? []) {
      if (element.userId != me) {
        users.add(element.userId ?? "");
      }
    }
    usersToCall = users
        .toString()
        .replaceAll("[", "")
        .replaceAll("]", "")
        .replaceAll(" ", "")
        .trim();

    _makeACall(ids: usersToCall, users: users);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: (_stats != null)
            ? Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  formatTime(_stats?.duration ?? 0),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
            : null,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 30),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  volumeOn = !volumeOn;
                  engine?.setEnableSpeakerphone(volumeOn);
                });
              },
              child: volumeOn
                  ? ImageIcon(
                      AssetImage(
                        R.images.volume,
                      ),
                      size: 25,
                    )
                  : const Icon(
                      FontAwesomeIcons.volumeMute,
                      color: Colors.white,
                      size: 25,
                    ),
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: isCalling == false && _remoteUid != null
          ? widget.isVideo
              ? _buildSingleVideoCall()
              : buildCallingState(inCall: true)
          : widget.isJoining
              ? const UltraLoadingIndicator()
              : buildCallingState(),
    );
  }

  Stack _buildSingleVideoCall() {
    return Stack(
      children: [
        Container(
          color: Colors.black,
          child: Center(
            child: _renderRemoteVideo(),
          ),
        ),
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
          child: _buildLocalView(),
          // child: FlipCard(
          //   flipOnTouch: false,
          //   controller: _flipController,
          //   direction: FlipDirection.HORIZONTAL,
          //   onFlip: () {
          //     setState(() {});
          //   },
          //   fill: Fill.none,
          //   front: _buildLocalView(),
          //   back: _buildLocalView(),
          // ),
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
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    isVideoOn = !isVideoOn;
                  });
                  if (isVideoOn) {
                    engine?.enableVideo();
                  } else {
                    engine?.disableVideo();
                  }
                },
                child: Container(
                  width: 60,
                  height: 60,
                  child: Icon(
                    isVideoOn ? Icons.videocam : Icons.videocam_off,
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
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    isMuted = !isMuted;
                  });
                  engine?.muteLocalAudioStream(isMuted);
                },
                child: Container(
                  width: 60,
                  height: 60,
                  child: Icon(
                    isMuted ? Icons.mic_off_rounded : Icons.mic,
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
                      //_flipController.toggleCard();
                      engine?.switchCamera();
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
                  if (widget.callKeep != null) {
                    widget.callKeep?.endAllCalls();
                  }
                  Navigator.pop(context);
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

  SizedBox buildCallingState({String title = "", bool inCall = false}) {
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
                    widget.channel!,
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
                  isCalling == false
                      ? title.isEmpty
                          ? "Calling ..."
                          : title
                      : widget.isVideo
                          ? ""
                          : formatTime(_stats?.duration ?? 0),
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
                if (widget.callKeep != null) {
                  widget.callKeep?.endAllCalls();
                }
                Navigator.pop(context);
                await ref.update({
                  await Utils.getString(R.pref.userId) ?? "": "Ended",
                });
              },
            ),
          )
        ],
      ),
    );
  }

  _makeACall({String ids = "", List<String> users = const []}) async {
    ref = FirebaseDatabase.instance.ref("Calls/$channelName");
    Map<String, String> callUsers = {};
    callUsers[await Utils.getString(R.pref.userId) ?? ""] = "In Call";
    for (var element in users) {
      callUsers[element] = "Waiting";
    }
    await ref.set(callUsers);
    listener = ref.onValue.listen((DatabaseEvent event) async {
      Map<dynamic, dynamic> data =
          event.snapshot.value as Map<dynamic, dynamic>;
      data.remove(await Utils.getString(R.pref.userId));
      int endedUsers = 0;
      data.forEach((key, value) {
        if (value == "Ended") {
          endedUsers++;
        }
      });
      if (endedUsers == data.length) {
        if (widget.callKeep != null) {
          widget.callKeep?.endAllCalls();
        }
      }
    });
    UltraNetwork.request(
      context,
      makeACall,
      cancelToken: cancelToken,
      formData: FormData.fromMap({
        "Uid": await Utils.getString(R.pref.userId),
        "channelName": channelName,
        "caller_name":
            "${await Utils.getString(R.pref.userFirstName)} ${await Utils.getString(R.pref.userLastName)}",
        "ids": ids,
        "has_video": widget.isVideo,
        //"caller_image": "ss"
      }),
      showLoadingIndicator: false,
      showError: false,
    ).then((response) async {
      if (response != null) {
        PriveCall tokenResponse = response;
        initAgora(token: tokenResponse.data ?? "", channelName: channelName);
        setState(() {});
      }
    });
  }

  void _setupRingingTone() async {
    await player.setAsset(R.sounds.calling);
    player.play();
  }

  Future<void> initAgora({String token = "", String channelName = ""}) async {
    await [Permission.camera, Permission.microphone].request();

    engine = await RtcEngine.createWithContext(
        RtcEngineContext(R.constants.agoraAppId));

    engine?.setEventHandler(RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
      print('joinChannelSuccess $channel $uid');
    }, userJoined: (int uid, int elapsed) {
      print('userJoined $uid');
      timer?.cancel();
      setState(() {
        isCalling = false;
        _remoteUid = uid;
      });
    }, userOffline: (int uid, UserOfflineReason reason) async {
      print('userOffline $uid');
      setState(() {
        _remoteUid = null;
      });
      if (widget.callKeep != null) {
        widget.callKeep?.endAllCalls();
      }
      Navigator.pop(context);
      await ref.update({
        await Utils.getString(R.pref.userId) ?? "": "Ended",
      });
    }, remoteVideoStateChanged: (uid, state, reason, time) {
      print("$uid ${state.name} ${state.index}");
    }, rtcStats: (stats) {
      _stats = stats;
      setState(() {});
    }));

    if (widget.isVideo == true) {
      await engine?.enableVideo();
    } else {
      setState(() {
        isVideoOn = false;
      });
    }
    await engine?.joinChannel(token, channelName, null,
        int.parse(await Utils.getString(R.pref.userId) ?? "0"));
  }

  void _joinChannel() {
    _makeACall();
  }

  Widget _renderLocalPreview() {
    if (isCalling == false) {
      return rtc_local_view.SurfaceView();
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _renderRemoteVideo() {
    if (_remoteUid != null) {
      return rtc_remote_view.SurfaceView(
        uid: _remoteUid ?? 0,
        channelId: "",
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  String formatTime(int seconds) {
    return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');
  }

  @override
  void dispose() {
    endCall();
    if (listener != null) {
      listener?.cancel();
    }
    player.dispose();
    timer?.cancel();
    engine?.destroy();
    super.dispose();
  }

  void endCall() async {
    ref.update({
      await Utils.getString(R.pref.userId) ?? "": "Ended",
    });
  }
}
