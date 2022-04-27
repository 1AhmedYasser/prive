import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:flutter_swipe_action_cell/core/controller.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Widgets/ChatWidgets/search_text_field.dart';
import 'package:prive/Widgets/Common/cached_image.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({Key? key}) : super(key: key);

  @override
  _CallsScreenState createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  int currentTab = 0;
  bool isEditing = false;
  SwipeActionController controller = SwipeActionController();
  List<String> calls = ["", "", "", "", "", "", "", "", "", "", ""];

  @override
  void initState() {
    _animationController = AnimationController(vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(35),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarBrightness: Brightness.light,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimationLimiter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (widget) => SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(
                    child: widget,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: SizedBox(
                            height: 48,
                            child: Text(
                              "Calls",
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        if (isEditing)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isEditing = false;
                                calls.clear();
                              });
                            },
                            child: Text(
                              "Clear All",
                              style: TextStyle(
                                fontSize: 17,
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                          ),
                        if (calls.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isEditing = !isEditing;
                                controller.closeAllOpenCell();
                              });
                            },
                            child: Text(
                              isEditing ? "Done" : "Edit",
                              style: TextStyle(
                                fontSize: 17,
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 15),
                    child: Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 200,
                        child: CupertinoSlidingSegmentedControl(
                          groupValue: currentTab,
                          children: const <int, Widget>{
                            0: Text('All'),
                            1: Text('Missed'),
                          },
                          onValueChanged: (value) {
                            setState(() {
                              currentTab = value as int;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: SearchTextField(
                      controller: TextEditingController(),
                      showCloseButton: false,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Expanded(
            child: AnimationLimiter(
              child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      horizontalOffset: 50.0,
                      child: FadeInAnimation(
                        child: SwipeActionCell(
                          controller: controller,
                          index: index,
                          key: ValueKey(calls[index]),
                          trailingActions: [
                            SwipeAction(
                              content: Image.asset(
                                R.images.deleteChatImage,
                                width: 15,
                                color: Colors.red,
                              ),
                              color: Colors.transparent,
                              onTap: (handler) async {
                                await handler(true);
                                setState(() {
                                  calls.removeAt(index);
                                });
                              },
                            ),
                          ],
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Visibility(
                                    child: const SizedBox(width: 15),
                                    visible: isEditing,
                                  ),
                                  Visibility(
                                    visible: isEditing,
                                    child: CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      minSize: 0,
                                      child: Icon(
                                        CupertinoIcons.minus_circle_fill,
                                        color: CupertinoColors.systemRed
                                            .resolveFrom(context),
                                      ),
                                      onPressed: () {
                                        controller.openCellAt(
                                          index: index,
                                          trailing: true,
                                        );
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: isEditing ? 15 : 25,
                                        right: 10,
                                        bottom: 5,
                                        top: 5),
                                    child: SizedBox(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(30),
                                        child: const CachedImage(
                                          url:
                                              "https://cdnb.artstation.com/p/assets/images/images/032/393/609/large/anya-valeeva-annie-fan-art-2020.jpg?1606310067",
                                        ),
                                      ),
                                      height: 50,
                                      width: 50,
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Ahmed Yasser",
                                          style: TextStyle(
                                            fontSize: 17,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Image.asset(
                                              index % 2 == 0
                                                  ? R.images.outgoingCall
                                                  : R.images.missedCall,
                                              width: 17,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              index % 2 == 0
                                                  ? "Outgoing"
                                                  : "Missed",
                                              style: TextStyle(
                                                color: index % 2 == 0
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "30/12/2020",
                                    style: TextStyle(
                                      color: index % 2 == 0
                                          ? Colors.grey.shade600
                                          : Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 25),
                                ],
                              ),
                              const Divider(height: 15)
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                itemCount: calls.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
