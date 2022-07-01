import 'package:draggable_widget/draggable_widget.dart';
import 'package:flutter/material.dart';

class CallOverlayWidget extends StatefulWidget {
  const CallOverlayWidget({Key? key}) : super(key: key);

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
          verticalSpace: 100,
          shadowBorderRadius: 20,
          normalShadow: const BoxShadow(
            color: Colors.transparent,
            offset: Offset(0, 0),
            blurRadius: 2,
          ),
          child: Container(
            width: 200,
            height: 200,
            color: Colors.deepPurple,
          ),
          initialPosition: AnchoringPosition.bottomLeft,
          dragController: remoteDragController,
        ),
      ],
    );
  }
}
