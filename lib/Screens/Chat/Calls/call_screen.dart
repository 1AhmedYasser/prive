import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class CallScreen extends StatefulWidget {
  final Channel channel;

  const CallScreen({Key? key, required this.channel}) : super(key: key);

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final player = AudioPlayer();

  @override
  void initState() {
    setupRingingTone();
    super.initState();
  }

  void setupRingingTone() async {
    await player.setAsset(R.sounds.calling);
    // await player.setAudioSource(
    //   ConcatenatingAudioSource(
    //     children: [
    //       SilenceAudioSource(duration: const Duration(milliseconds: 300)),
    //     //  AudioSource.uri(Uri.parse('asset:///${R.sounds.calling}')),
    //     ],
    //   ),
    //   initialIndex: 0, // default
    //   initialPosition: Duration.zero, // default
    // );
    player.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: buildCallingState(),
    );
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

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
