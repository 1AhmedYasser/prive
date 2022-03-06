import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../../Extras/resources.dart';
import '../../Screens/Chat/Calls/call_screen.dart';

class CallingWidget extends StatefulWidget {
  final String channelName;
  final BuildContext context;
  const CallingWidget(
      {Key? key, required this.channelName, required this.context})
      : super(key: key);

  @override
  _CallingWidgetState createState() => _CallingWidgetState();
}

class _CallingWidgetState extends State<CallingWidget> {
  final player = AudioPlayer();
  Timer? timer;

  @override
  void initState() {
    _setupRingingTone();
    timer = Timer.periodic(
        const Duration(seconds: 5), (Timer t) => _setupRingingTone());
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
                        child: Image.network(
                          "https://wac-cdn.atlassian.com/dam/jcr:ba03a215-2f45-40f5-8540-b2015223c918/Max-R_Headshot%20(1).jpg?cdnVersion=243",
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Ahmed Yasser",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Voice Call",
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
                      onPressed: () {
                        BotToast.cleanAll();
                        Navigator.of(widget.context).push(
                          PageRouteBuilder(
                            pageBuilder: (BuildContext context, _, __) {
                              return CallScreen(
                                channelName: widget.channelName,
                                isJoining: true,
                                channel: Channel(
                                    StreamChatCore.of(widget.context).client,
                                    "messaging",
                                    widget.channelName),
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
                      onPressed: () {
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
    await player.setAsset(R.sounds.calling);
    player.play();
  }

  @override
  void dispose() {
    player.dispose();
    timer?.cancel();
    super.dispose();
  }
}
