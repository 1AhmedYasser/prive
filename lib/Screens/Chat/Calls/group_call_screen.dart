import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prive/Widgets/AppWidgets/wave_button.dart';
import 'package:prive/Widgets/Common/cached_image.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class GroupCallScreen extends StatefulWidget {
  final bool isVideo;
  final Channel channel;
  final ScrollController scrollController;
  const GroupCallScreen(
      {Key? key,
      this.isVideo = false,
      required this.scrollController,
      required this.channel})
      : super(key: key);

  @override
  State<GroupCallScreen> createState() => _GroupCallScreenState();
}

class _GroupCallScreenState extends State<GroupCallScreen> {
  bool isSpeakerOn = false;
  bool isVideoOn = false;
  bool isMute = false;
  int count = 3;

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
                            const Text(
                              "3 Participants",
                              style: TextStyle(
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
                      itemCount: count,
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
                        if (count % 2 != 0 && count - 1 == index) {
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
                                    url: context.currentUserImage ?? "",
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              title: const Text(
                                "Ahmed Yasser",
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: const Text(
                                "Listening",
                                style: TextStyle(color: Colors.grey),
                              ),
                              trailing: const Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: Icon(
                                  Icons.mic,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: 2,
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
                  } else {
                    isSpeakerOn = !isSpeakerOn;
                  }
                });
              },
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
                    showCupertinoModalPopup<void>(
                      context: context,
                      builder: (BuildContext context) => CupertinoActionSheet(
                        title: Text(
                            'Are You Sure  You Want to leave this ${widget.isVideo ? "video" : "voice"} call ?'),
                        actions: <CupertinoActionSheetAction>[
                          CupertinoActionSheetAction(
                            isDestructiveAction: true,
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: Text(
                                'End ${widget.isVideo ? "Video" : "Voice"} Call'),
                          ),
                          CupertinoActionSheetAction(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
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
}
