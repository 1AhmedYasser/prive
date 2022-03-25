import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:just_audio/just_audio.dart';
import 'package:prive/Widgets/Common/cached_image.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../../Extras/resources.dart';
import '../../Helpers/Utils.dart';
import '../../Screens/Chat/Calls/call_screen.dart';

class CallingWidget extends StatefulWidget {
  final String channelName;
  final String callerName;
  final String callerImage;
  final bool isVideoCall;
  final BuildContext context;
  const CallingWidget(
      {Key? key,
      required this.channelName,
      required this.context,
      this.callerName = "Incoming Call",
      required this.isVideoCall,
      this.callerImage = ""})
      : super(key: key);

  @override
  _CallingWidgetState createState() => _CallingWidgetState();
}

class _CallingWidgetState extends State<CallingWidget> {
  final player = AudioPlayer();
  Timer? timer;
  StreamSubscription? listener;
  late DatabaseReference ref;

  @override
  void initState() {
    _setupRingingTone();
    timer = Timer.periodic(
        const Duration(seconds: 5), (Timer t) => _setupRingingTone());
    ref = FirebaseDatabase.instance.ref("Calls/${widget.channelName}");
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
        BotToast.cleanAll();
        FlutterCallkitIncoming.endAllCalls();
        await ref.update({
          await Utils.getString(R.pref.userId) ?? "": "Ended",
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: MediaQuery.of(context).size.width - 30,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 20),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: CachedImage(
                          url: widget.callerImage,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.callerName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.isVideoCall ? "Video Call" : "Voice Call",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Expanded(child: SizedBox()),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        DatabaseReference ref = FirebaseDatabase.instance
                            .ref("Calls/${widget.channelName}");

                        BotToast.cleanAll();
                        Navigator.of(widget.context).push(
                          PageRouteBuilder(
                            pageBuilder: (BuildContext context, _, __) {
                              return CallScreen(
                                channelName: widget.channelName,
                                isJoining: true,
                                isVideo: widget.isVideoCall,
                                callImage: widget.callerImage,
                                callName: widget.callerName,
                              );
                            },
                            transitionsBuilder: (_, Animation<double> animation,
                                __, Widget child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                        await ref.update({
                          await Utils.getString(R.pref.userId) ?? "": "In Call",
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.transparent,
                        onPrimary: Colors.transparent,
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            R.images.acceptCall,
                            width: 17,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            "Reply",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        FlutterCallkitIncoming.endAllCalls();
                        DatabaseReference ref = FirebaseDatabase.instance
                            .ref("Calls/${widget.channelName}");

                        await ref.update({
                          await Utils.getString(R.pref.userId) ?? "": "Ended",
                        });
                        BotToast.cleanAll();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.transparent,
                        onPrimary: Colors.transparent,
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            R.images.declineCall,
                            width: 23,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            "Decline",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _setupRingingTone() async {
    await player.setAsset(R.sounds.incomingCall);
    player.play();
  }

  @override
  void dispose() {
    if (listener != null) {
      listener?.cancel();
    }
    player.dispose();
    timer?.cancel();
    super.dispose();
  }
}
