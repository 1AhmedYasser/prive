import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:blur/blur.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Helpers/utils.dart';
import 'package:prive/Models/Call/prive_call.dart';
import 'package:prive/UltraNetwork/ultra_constants.dart';
import 'package:prive/UltraNetwork/ultra_loading_indicator.dart';
import 'package:prive/UltraNetwork/ultra_network.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:uuid/uuid.dart';

class CallScreen extends StatefulWidget {
  final Channel? channel;
  final bool isJoining;
  final String channelName;

  const CallScreen({
    Key? key,
    this.channel,
    this.isJoining = false,
    this.channelName = "",
  }) : super(key: key);

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final player = AudioPlayer();
  CancelToken cancelToken = CancelToken();
  String channelName = const Uuid().v4();
  // AgoraClient? client;
  RtcEngine? engine;
  List<String> users = [];
  String usersToCall = "";

  @override
  void initState() {
    if (widget.isJoining == true) {
      channelName = widget.channelName;
      _joinChannel();
    } else {
      _setupRingingTone();
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

    _makeACall(ids: usersToCall);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
    );
    //   body: client != null
    //       ? Stack(
    //           children: [
    //             AgoraVideoViewer(
    //               videoRenderMode: VideoRenderMode.FILL,
    //               client: client!,
    //             ),
    //             AgoraVideoButtons(
    //               client: client!,
    //             ),
    //           ],
    //         )
    //       : widget.isJoining
    //           ? const UltraLoadingIndicator()
    //           : buildCallingState(),
    // );
  }

  SizedBox buildCallingState() {
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
                const Text(
                  "Calling ...",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
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
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          )
        ],
      ),
    );
  }

  _makeACall({String ids = ""}) async {
    print("Ids to call $ids");
    UltraNetwork.request(
      context,
      makeACall,
      cancelToken: cancelToken,
      formData: FormData.fromMap({
        "Uid": await Utils.getString(R.pref.userId),
        "channelName": channelName,
        "caller_name":
            "${await Utils.getString(R.pref.userFirstName)} ${await Utils.getString(R.pref.userLastName)}",
        "ids": ids
      }),
      showLoadingIndicator: false,
      showError: false,
    ).then((response) async {
      if (response != null) {
        PriveCall tokenResponse = response;
        // client = AgoraClient(
        //   agoraConnectionData: AgoraConnectionData(
        //       appId: "666a21c863d9431da1ee9651748608fb",
        //       channelName: channelName,
        //       tempToken: tokenResponse.data,
        //       uid: int.parse(await Utils.getString(R.pref.userId) ?? "0")),
        //   enabledPermission: [
        //     Permission.camera,
        //     Permission.microphone,
        //   ],
        //   agoraEventHandlers: AgoraEventHandlers(
        //     joinChannelSuccess: (String channel, int uid, int elapsed) {
        //       print('joinChannelSuccess $channel $uid');
        //     },
        //     userJoined: (int uid, int elapsed) {
        //       print('userJoined $uid');
        //     },
        //     userOffline: (int uid, UserOfflineReason reason) {
        //       print('userOffline $uid');
        //     },
        //     onError: (error) {
        //       // if (error.index == 15) {
        //       //   leaveChannel();
        //       // }
        //       print("error ${error.index}");
        //       print("error $error");
        //     },
        //   ),
        // );
        initAgora();
        setState(() {});
      }
    });
  }

  void _setupRingingTone() async {
    await player.setAsset(R.sounds.calling);
    player.play();
  }

  void initAgora() async {
    // await client!.initialize();
  }

  void _joinChannel() {
    _makeACall();
  }

  @override
  void dispose() {
    player.dispose();
    // if (client != null) {
    //   client?.sessionController.endCall();
    //   client?.sessionController.dispose();
    // }
    super.dispose();
  }
}
