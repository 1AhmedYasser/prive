import 'dart:async';
import 'dart:io';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:blur/blur.dart';
import 'package:dio/dio.dart';
import 'package:draggable_widget/draggable_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Helpers/utils.dart';
import 'package:prive/Models/Call/call.dart';
import 'package:prive/Models/Call/call_member.dart';
import 'package:prive/Models/Call/prive_call.dart';
import 'package:prive/Providers/call_provider.dart';
import 'package:prive/Resources/constants.dart';
import 'package:prive/Resources/images.dart';
import 'package:prive/Resources/sounds.dart';
import 'package:prive/UltraNetwork/ultra_constants.dart';
import 'package:prive/UltraNetwork/ultra_network.dart';
import 'package:prive/Widgets/Common/cached_image.dart';
import 'package:provider/provider.dart';
import 'package:replay_kit_launcher/replay_kit_launcher.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:wakelock/wakelock.dart';

class SingleCallScreen extends StatefulWidget {
  final bool isVideo;
  final Channel channel;
  final bool isJoining;
  final String channelName;
  final String channelImage;
  final RtcEngine? agoraEngine;
  final Call? call;
  const SingleCallScreen({
    Key? key,
    this.isVideo = false,
    required this.channel,
    this.isJoining = false,
    this.channelName = '',
    this.channelImage = '',
    this.agoraEngine,
    this.call,
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
  bool isRemoteVideoOn = true;
  bool isSpeakerOn = false;
  bool isHeadphonesOn = true;
  bool isMute = false;
  CallMember? me;
  VideoViewController? remoteView;
  VideoViewController? localView;

  bool didJoinAgora = false;
  bool didEndCall = false;
  bool isSharingScreen = false;
  String userAgoraToken = '';
  int channelUid = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Platform.isAndroid) {
        _initForegroundTask();
      }
      Wakelock.enable();
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
        leading: BackButton(
          onPressed: () {
            if (mounted) {
              Provider.of<CallProvider>(context, listen: false).changeOverlayState(true);
            }
            Navigator.pop(context);
          },
          color: Colors.white,
        ),
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
                  isSpeakerOn ? FontAwesomeIcons.volumeHigh : FontAwesomeIcons.volumeLow,
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
    await player.setAsset(Sounds.calling);
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
                child: widget.channelImage.isEmpty
                    ? StreamChannelAvatar(
                        borderRadius: BorderRadius.circular(0),
                        channel: widget.channel,
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width,
                          minHeight: MediaQuery.of(context).size.height,
                          maxWidth: MediaQuery.of(context).size.width,
                          maxHeight: MediaQuery.of(context).size.height,
                        ),
                      )
                    : SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: CachedImage(
                          url: widget.channelImage,
                        ),
                      ),
              ),
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.channelImage.isEmpty
                    ? StreamChannelAvatar(
                        borderRadius: BorderRadius.circular(50),
                        channel: widget.channel,
                        constraints: const BoxConstraints(
                          minWidth: 100,
                          minHeight: 100,
                          maxWidth: 100,
                          maxHeight: 100,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: CachedImage(
                            url: widget.channelImage,
                          ),
                        ),
                      ),
                const SizedBox(height: 20),
                Text(
                  widget.channelName.isEmpty
                      ? StreamManager.getChannelName(
                          widget.channel,
                          context.currentUser!,
                        )
                      : widget.channelName,
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
                      ? 'Calling ...'
                      : _stats != null
                          ? formatTime(_stats?.duration ?? 0)
                          : didJoinAgora
                              ? ''
                              : 'Connecting ...',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ).tr(),
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
                  Images.closeCall,
                ),
                onPressed: () async {
                  didEndCall = true;
                  final databaseReference = FirebaseDatabase.instance.ref('SingleCalls/${widget.channel.id}');
                  DatabaseReference usersRef = FirebaseDatabase.instance.ref('Users');
                  databaseReference.remove();
                  _stopForegroundTask();
                  for (var member in widget.channel.state?.members ?? []) {
                    usersRef.update({member.userId ?? '': 'Ended'});
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
      isHeadphonesOn: true,
      phone: context.currentUser?.extraData['phone'] as String,
      isMicOn: true,
      isVideoOn: widget.isVideo,
    );
    DatabaseReference ref = FirebaseDatabase.instance.ref('SingleCalls/${widget.channel.id}');
    await ref.set({
      'ownerId': context.currentUser?.id ?? '',
      'type': widget.isVideo ? 'Video' : 'Voice',
      'members': {owner.id: owner.toJson()},
    });
    DatabaseReference userRef = FirebaseDatabase.instance.ref('Users');
    userRef.update({context.currentUser?.id ?? '': 'In Call'});
    initAgora();
  }

  void _listenToFirebaseChanges() {
    final databaseReference = FirebaseDatabase.instance.ref('SingleCalls/${widget.channel.id}');
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

  Future<void> _joinCall() async {
    CallMember joiningUser = CallMember(
      id: context.currentUser?.id,
      name: context.currentUser?.name,
      image: context.currentUser?.image,
      isHeadphonesOn: true,
      phone: context.currentUser?.extraData['phone'] as String,
      isMicOn: widget.call != null
          ? widget.call?.members?.firstWhere((member) => member.id == context.currentUser?.id).isMicOn == true
          : true,
      isVideoOn: widget.call != null
          ? widget.call?.members?.firstWhere((member) => member.id == context.currentUser?.id).isVideoOn == true
          : widget.isVideo,
    );

    final ref = FirebaseDatabase.instance.ref('SingleCalls/${widget.channel.id}/members');
    ref.update({joiningUser.id ?? '': joiningUser.toJson()});
    DatabaseReference userRef = FirebaseDatabase.instance.ref('Users');
    userRef.update({context.currentUser?.id ?? '': 'In Call'});

    if (widget.agoraEngine == null) {
      initAgora();
    } else {
      if (widget.call != null) {
        isSpeakerOn = await agoraEngine?.isSpeakerphoneEnabled() ?? false;
      }
      agoraEngine = widget.agoraEngine;
      localView = VideoViewController(
        rtcEngine: agoraEngine!,
        canvas: VideoCanvas(
          uid: channelUid,
          sourceType: isSharingScreen ? VideoSourceType.videoSourceScreen : null,
        ),
      );
      setState(() {});
    }
  }

  void getCall() async {
    final databaseReference = FirebaseDatabase.instance.ref('SingleCalls/${widget.channel.id}');

    final snapshot = await databaseReference.get();
    if (snapshot.exists) {
      Map<dynamic, dynamic>? callResponse = {};
      callResponse = (snapshot.value as Map<dynamic, dynamic>);

      String? ownerId = callResponse['ownerId'];
      String? type = callResponse['type'];
      List<CallMember>? members = [];

      Map<dynamic, dynamic>? membersList = (callResponse['members'] as Map<dynamic, dynamic>?) ?? {};
      membersList.forEach((key, value) {
        members.add(
          CallMember(
            id: value['id'],
            name: value['name'],
            image: value['image'],
            phone: value['phone'],
            isHeadphonesOn: value['isHeadphonesOn'],
            isMicOn: value['isMicOn'],
            isVideoOn: value['isVideoOn'],
          ),
        );
      });

      if (membersList.isEmpty == true) {
        databaseReference.remove();
      }

      call = Call(ownerId: ownerId, type: type, members: members);
      me = call?.members?.firstWhere((element) => element.id == context.currentUser?.id);
      videoMembers = call?.members?.where((element) => element.isVideoOn == true).toList() ?? [];
      isHeadphonesOn = me?.isHeadphonesOn ?? true;
      if (isHeadphonesOn == false) {
        isMute = true;
        await agoraEngine?.muteAllRemoteAudioStreams(true);
        await agoraEngine?.muteRemoteAudioStream(
          uid: int.parse(context.currentUser?.id ?? '0'),
          mute: false,
        );
        await agoraEngine?.muteLocalAudioStream(true);
      } else {
        await agoraEngine?.muteAllRemoteAudioStreams(false);
      }

      if (widget.agoraEngine != null) {
        if (widget.isVideo) {
          remoteView = VideoViewController.remote(
            rtcEngine: agoraEngine!,
            canvas: VideoCanvas(
              uid: int.parse(call?.members?.firstWhere((member) => member.id != context.currentUser?.id).id ?? '0'),
            ),
            connection: RtcConnection(channelId: widget.channel.id),
          );
        }
      }

      if (call?.members?.length == 2) {
        player.dispose();
        timer?.cancel();
      }
      if (mounted) {
        setState(() {});
      }
    } else {
      if (showingInfo == false) {
        didEndCall = true;
        _stopForegroundTask();
        DatabaseReference usersRef = FirebaseDatabase.instance.ref('Users');
        if (mounted) {
          await usersRef.update({
            context.currentUser?.id ?? '': 'Ended',
          });
        }
        await agoraEngine?.leaveChannel();
        try {
          await agoraEngine?.release(sync: true);
        } catch (_) {}

        if (mounted) {
          Utils.showAlert(
            context,
            message: 'Call Has Ended',
            alertImage: Images.alertInfoImage,
          ).then(
            (value) => Navigator.pop(context),
          );
        }
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
        'Uid': context.currentUser?.id,
        'channelName': widget.channel.id,
        'caller_name': context.currentUser?.name,
        'ids': widget.isJoining
            ? {}
            : widget.channel.state?.members.firstWhere((element) => element.userId != context.currentUser?.id).userId,
        'has_video': widget.isVideo,
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
        agoraEngine = createAgoraRtcEngine();
        await agoraEngine?.initialize(const RtcEngineContext(appId: Constants.agoraAppId));

        if (widget.isVideo) {
          await agoraEngine?.enableVideo();
        }

        agoraEngine?.registerEventHandler(
          RtcEngineEventHandler(
            onJoinChannelSuccess: (connection, uid) async {
              print('joinChannelSuccess $uid');
              if (mounted) {
                channelUid = uid;
                setState(() {});
              }
            },
            onUserJoined: (connection, uid, elapsed) {
              print('userJoined $uid');
              timer?.cancel();
              remoteView = VideoViewController.remote(
                rtcEngine: agoraEngine!,
                canvas: VideoCanvas(
                  uid: int.parse(call?.members?.firstWhere((member) => member.id != context.currentUser?.id).id ?? '0'),
                ),
                connection: RtcConnection(channelId: widget.channel.id),
              );
              if (mounted) {
                setState(() {});
              }
            },
            onRemoteVideoStateChanged: (connection, uid, state, reason, time) {
              if (mounted) {
                if (state.index == 0) {
                  setState(() {
                    isRemoteVideoOn = false;
                    print('Remote Closed Camera');
                  });
                } else {
                  setState(() {
                    isRemoteVideoOn = true;
                    print('Remote Opened Camera');
                  });
                }
              }
            },
            onRtcStats: (connection, stats) {
              _stats = stats;
              if (mounted) {
                setState(() {});
              }
            },
            onCameraReady: () {
              if (mounted) {
                setState(() {});
              }
            },
          ),
        );
        userAgoraToken = tokenResponse.data ?? '';

        await agoraEngine?.startPreview();

        await agoraEngine
            ?.joinChannel(
          token: tokenResponse.data ?? '',
          channelId: widget.channel.id ?? '',
          uid: int.parse(context.currentUser?.id ?? '0'),
          options: ChannelMediaOptions(
            token: tokenResponse.data ?? '',
            clientRoleType: ClientRoleType.clientRoleBroadcaster,
            channelProfile: ChannelProfileType.channelProfileCommunication,
          ),
        )
            .then((value) {
          localView = VideoViewController(
            rtcEngine: agoraEngine!,
            canvas: VideoCanvas(
              uid: channelUid,
              sourceType: isSharingScreen ? VideoSourceType.videoSourceScreen : null,
            ),
          );
          if (call?.members?.length == 2) {
            remoteView = VideoViewController.remote(
              rtcEngine: agoraEngine!,
              canvas: VideoCanvas(
                uid: int.parse(call?.members?.firstWhere((member) => member.id != context.currentUser?.id).id ?? '0'),
              ),
              connection: RtcConnection(channelId: widget.channel.id),
            );
          }
          didJoinAgora = true;
          setState(() {});
        });
        agoraEngine?.setParameters('{"che.audio.opensl":true}');
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
                child: widget.channelImage.isEmpty
                    ? StreamChannelAvatar(
                        borderRadius: BorderRadius.circular(0),
                        channel: widget.channel,
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width,
                          minHeight: MediaQuery.of(context).size.height,
                          maxWidth: MediaQuery.of(context).size.width,
                          maxHeight: MediaQuery.of(context).size.height,
                        ),
                      )
                    : SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: CachedImage(
                          url: widget.channelImage,
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
                widget.channelImage.isEmpty
                    ? StreamChannelAvatar(
                        borderRadius: BorderRadius.circular(50),
                        channel: widget.channel,
                        constraints: const BoxConstraints(
                          minWidth: 100,
                          minHeight: 100,
                          maxWidth: 100,
                          maxHeight: 100,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: CachedImage(
                            url: widget.channelImage,
                          ),
                        ),
                      ),
                const SizedBox(height: 20),
                Text(
                  widget.channelName.isEmpty
                      ? StreamManager.getChannelName(
                          widget.channel,
                          context.currentUser!,
                        )
                      : widget.channelName,
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
                      ? 'Calling ...'
                      : formatTime(
                          _stats?.duration ?? 0,
                        ),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ).tr(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        if (isVideo &&
            call?.members?.length == 2 &&
            call?.members?.firstWhere((member) => member.id == context.currentUser?.id).isVideoOn == true)
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
            // child: FlipCard(
            //   controller: _flipController,
            //   flipOnTouch: false,
            //   front: _buildLocalView(), //_buildLocalView(),
            //   back: _buildLocalView(),
            // ),
            initialPosition: AnchoringPosition.topRight,
            dragController: remoteDragController,
            child: _buildLocalView(),
          ),
        Positioned(
          bottom: 50,
          right: 35,
          left: 35,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  isHeadphonesOn = !isHeadphonesOn;
                  final ref = FirebaseDatabase.instance
                      .ref('SingleCalls/${widget.channel.id}/members/${context.currentUser?.id}');
                  if (isHeadphonesOn == false) {
                    ref.update({'isMicOn': false, 'isHeadphonesOn': false});
                  } else {
                    ref.update({'isHeadphonesOn': true});
                  }
                  setState(() {});
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(23),
                    color: Colors.grey.withOpacity(0.7),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      isHeadphonesOn ? Icons.headset_rounded : Icons.headset_off_rounded,
                      color: Colors.white,
                      size: 27,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (isVideo)
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
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(23),
                      color: Colors.grey.withOpacity(0.7),
                    ),
                    child: Icon(
                      isSharingScreen == false ? Icons.mobile_screen_share_rounded : Icons.mobile_off_rounded,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
              if (isVideo) const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isVideo)
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        bool isVideoOn =
                            !(call?.members?.firstWhere((element) => element.id == context.currentUser?.id).isVideoOn ??
                                false);
                        final ref = FirebaseDatabase.instance
                            .ref('SingleCalls/${widget.channel.id}/members/${context.currentUser?.id}');
                        ref.update({'isVideoOn': isVideoOn});
                        agoraEngine?.enableLocalVideo(isVideoOn);
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(23),
                          color: Colors.grey.withOpacity(0.7),
                        ),
                        child: Icon(
                          call?.members?.firstWhere((element) => element.id == context.currentUser?.id).isVideoOn ==
                                  true
                              ? Icons.videocam
                              : Icons.videocam_off,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  if (isVideo) const SizedBox(width: 15),
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      if (isHeadphonesOn) {
                        bool isMicOn = me?.isMicOn == true;
                        final ref = FirebaseDatabase.instance
                            .ref('SingleCalls/${widget.channel.id}/members/${context.currentUser?.id}');
                        ref.update({'isMicOn': !isMicOn});
                        await agoraEngine?.muteRemoteAudioStream(
                          uid: int.parse(context.currentUser?.id ?? '0'),
                          mute: isMicOn,
                        );
                        await agoraEngine?.muteLocalAudioStream(isMicOn);
                        setState(() {});
                      }
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(23),
                        color: Colors.grey.withOpacity(0.7),
                      ),
                      child: Icon(
                        me?.isMicOn == false ? Icons.mic_off_rounded : Icons.mic,
                        size: 28,
                        color: Colors.white,
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
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(23),
                          color: Colors.grey.withOpacity(0.7),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            isSpeakerOn ? FontAwesomeIcons.volumeHigh : FontAwesomeIcons.volumeLow,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ),
                    ),
                  if (isVideo)
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(23),
                        color: Colors.grey.withOpacity(0.7),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: IconButton(
                          iconSize: 30,
                          icon: Image.asset(
                            Images.cameraSwitch,
                          ),
                          onPressed: () {
                            // _flipController.toggleCard();

                            agoraEngine?.switchCamera();
                          },
                        ),
                      ),
                    ),
                  const SizedBox(width: 15),
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      didEndCall = true;
                      final databaseReference = FirebaseDatabase.instance.ref('SingleCalls/${widget.channel.id}');
                      DatabaseReference usersRef = FirebaseDatabase.instance.ref('Users');
                      databaseReference.remove();
                      _stopForegroundTask();
                      for (var member in widget.channel.state?.members ?? []) {
                        usersRef.update({member.userId ?? '': 'Ended'});
                      }
                      FlutterCallkitIncoming.endAllCalls();
                      Utils.logAnswerOrCancelCall(
                        context,
                        context.currentUser?.id ?? '',
                        'END',
                        formatTime(_stats?.duration ?? 0),
                      );
                    },
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: Image.asset(
                        Images.closeCall,
                      ),
                    ),
                  )
                ],
              ),
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
          child: localView != null
              ? AgoraVideoView(
                  controller: localView!,
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _renderRemoteVideo() {
    if (remoteView != null) {
      if (call?.members?.firstWhere((member) => member.id != context.currentUser?.id).isVideoOn == true) {
        return AgoraVideoView(
          controller: remoteView!,
        );
      } else {
        return _buildCallingState(isRemoteVideoOn: false);
      }
    } else {
      return _buildCallingState(isRemoteVideoOn: false);
    }
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
    await FlutterForegroundTask.startService(notificationTitle: 'Prive', notificationText: 'Call In Progress');
  }

  Future<void> _stopForegroundTask() async {
    if (Platform.isAndroid) {
      await FlutterForegroundTask.stopService();
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
    print('Stop Screen Sharing');
    await agoraEngine?.stopScreenCapture();
    if (Platform.isIOS) {
      ReplayKitLauncher.finishReplayKitBroadcast('ScreenSharing');
    }
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
        isGroup: false,
        isVideo: widget.isVideo,
        callId: widget.channel.id ?? '',
        agoraEngine: agoraEngine,
        channel: widget.channel,
      );
    }
    if (mounted) {
      Wakelock.disable();
      player.dispose();
      timer?.cancel();
    }

    super.dispose();
  }
}
