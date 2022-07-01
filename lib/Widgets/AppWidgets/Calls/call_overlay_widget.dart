import 'package:draggable_widget/draggable_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prive/Helpers/stream_manager.dart';
import '../../Common/cached_image.dart';

class CallOverlayWidget extends StatefulWidget {
  final bool isGroup;
  final bool isVideo;
  const CallOverlayWidget({
    Key? key,
    this.isGroup = false,
    this.isVideo = false,
  }) : super(key: key);

  @override
  State<CallOverlayWidget> createState() => _CallOverlayWidgetState();
}

class _CallOverlayWidgetState extends State<CallOverlayWidget> {
  final remoteDragController = DragController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DraggableWidget(
          bottomMargin: 60,
          intialVisibility: true,
          horizontalSpace: 20,
          verticalSpace: 120,
          shadowBorderRadius: 20,
          normalShadow: const BoxShadow(
            color: Colors.transparent,
            offset: Offset(0, 0),
            blurRadius: 2,
          ),
          child: Container(
            width: 230,
            height: 170,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorDark,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    child: ListTile(
                      leading: SizedBox(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CachedImage(
                            url: context.currentUserImage ?? "",
                          ),
                        ),
                        width: 60,
                        height: 80,
                      ),
                      title: const Text(
                        "Family",
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: const Text(
                        "4 participants",
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: Icon(
                        FontAwesomeIcons.expand,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Row(
                      children: [
                        buildControl(
                          FontAwesomeIcons.volumeUp,
                          Colors.black38,
                          () {
                            print("Speaker");
                          },
                        ),
                        const SizedBox(width: 15),
                        buildControl(
                          Icons.mic_off,
                          Colors.black38,
                          () {
                            print("Mute");
                          },
                        ),
                        const SizedBox(width: 15),
                        buildControl(
                          Icons.call_end,
                          const Color(0xffff2d55),
                          () {
                            print("End Call");
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          initialPosition: AnchoringPosition.topRight,
          dragController: remoteDragController,
        ),
      ],
    );
  }

  Widget buildControl(IconData icon, Color containerColor, Function onPressed) {
    return Expanded(
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () => onPressed(),
        child: Container(
          width: 50,
          height: 50,
          child: Icon(
            icon,
            color: Colors.white,
            size: 25,
          ),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
