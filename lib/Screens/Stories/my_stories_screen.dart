import 'package:dashed_circle/dashed_circle.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:flutter_swipe_action_cell/core/controller.dart';
import 'package:prive/Screens/Stories/stories_viewer_screen.dart';
import 'package:prive/UltraNetwork/ultra_network.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';
import 'package:timeago/timeago.dart' as time_ago;
import '../../Extras/resources.dart';
import '../../Models/Stories/stories.dart';
import '../../UltraNetwork/ultra_constants.dart';
import '../../Widgets/AppWidgets/Stories/video_thumb_viewer.dart';
import '../../Widgets/Common/cached_image.dart';
import 'package:easy_localization/easy_localization.dart';

//ignore: must_be_immutable
class MyStoriesScreen extends StatefulWidget {
  List<StoriesData> myStories;
  MyStoriesScreen({Key? key, required this.myStories}) : super(key: key);

  @override
  State<MyStoriesScreen> createState() => _MyStoriesScreenState();
}

class _MyStoriesScreenState extends State<MyStoriesScreen> {
  SwipeActionController controller = SwipeActionController();
  bool isEditing = false;
  CancelToken cancelToken = CancelToken();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f1f6),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: Colors.grey.shade100,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarBrightness: Brightness.light,
          ),
          leading: const BackButton(
            color: Color(0xff7a8fa6),
          ),
          title: const Text(
            "My Updates",
            style: TextStyle(
              fontSize: 23,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ).tr(),
          actions: [
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
              ).tr(),
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MediaQuery.removePadding(
              context: context,
              removeTop: true,
              removeBottom: true,
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return SwipeActionCell(
                    controller: controller,
                    index: index,
                    key: ValueKey(widget.myStories[index]),
                    trailingActions: [
                      SwipeAction(
                        content: Image.asset(
                          R.images.deleteChatImage,
                          width: 15,
                          color: Colors.red,
                        ),
                        color: Colors.white,
                        onTap: (handler) async {
                          await handler(true);
                          _deleteStory(widget.myStories[index].stotyID ?? "");
                          setState(() {
                            widget.myStories.removeAt(index);
                          });
                          if (widget.myStories.isEmpty) {
                            if (mounted) {
                              Navigator.pop(context);
                            }
                          }
                        },
                      ),
                    ],
                    child: Container(
                      color: Colors.white,
                      child: InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          final List<List<StoryItem>> passedStories = [];
                          StoryController storyController = StoryController();
                          List<StoryItem> storesStories = [];
                          for (int i = 0; i < widget.myStories.length; i++) {
                            if (widget.myStories[i].type == "Photos") {
                              storesStories.add(
                                StoryItem.pageImage(
                                  url: widget.myStories[i].content ?? "",
                                  controller: storyController,
                                  imageFit: BoxFit.fitWidth,
                                  shown: index != i ? true : false,
                                  duration: const Duration(seconds: 10),
                                ),
                              );
                            } else if (widget.myStories[i].type == "Videos") {
                              storesStories.add(
                                StoryItem.pageVideo(
                                  widget.myStories[i].content ?? "",
                                  controller: storyController,
                                  imageFit: BoxFit.fitWidth,
                                  shown: index != i ? true : false,
                                  duration: const Duration(seconds: 30),
                                ),
                              );
                            }
                          }
                          passedStories.add(storesStories);
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (BuildContext context, _, __) {
                                return StoriesViewerScreen(
                                  closeOnSwipeDown: true,
                                  showViewers: true,
                                  passedStories: passedStories,
                                  usersStories: [widget.myStories],
                                  storyController: storyController,
                                );
                              },
                              transitionsBuilder: (_,
                                  Animation<double> animation,
                                  __,
                                  Widget child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Visibility(
                                    visible: isEditing,
                                    child: const SizedBox(width: 15),
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
                                    padding: const EdgeInsets.only(
                                      left: 20,
                                      right: 20,
                                    ),
                                    child: DashedCircle(
                                      dashes: 0,
                                      gapSize: 0,
                                      color: Theme.of(context).primaryColor,
                                      child: Padding(
                                        padding: const EdgeInsets.all(3),
                                        child: SizedBox(
                                          width: 70,
                                          height: 70,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(60),
                                            child: widget.myStories[index]
                                                        .type ==
                                                    "Photos"
                                                ? CachedImage(
                                                    url: widget.myStories[index]
                                                            .content ??
                                                        "",
                                                  )
                                                : VideoThumbViewer(
                                                    videoUrl: widget
                                                            .myStories[index]
                                                            .content ??
                                                        ""),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.myStories[index].views != "0"
                                              ? widget.myStories[index].views !=
                                                      "1"
                                                  ? "${widget.myStories[index].views} ${"Views"}"
                                                  : "1 ${"View"}"
                                              : "No Views Yet".tr(),
                                          style: const TextStyle(
                                            fontSize: 16.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          time_ago.format(
                                            DateFormat(
                                                    "yyyy-MM-dd HH:mm:ss", "en")
                                                .parse(
                                                    widget.myStories[index]
                                                            .createdAtStory ??
                                                        DateTime.now()
                                                            .toString(),
                                                    true)
                                                .toLocal(),
                                          ),
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.grey.shade600,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              const Padding(
                                padding: EdgeInsets.only(left: 110),
                                child: Divider(height: 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                itemCount: widget.myStories.length,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 17, top: 13, right: 20, bottom: 35),
              child: Text(
                "Your story updates will disappear after 24 hours.",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ).tr(),
            )
          ],
        ),
      ),
    );
  }

  void _deleteStory(String storyId) {
    UltraNetwork.request(
      context,
      deleteStory,
      showLoadingIndicator: false,
      showError: false,
      formData: FormData.fromMap(
        {"StoryID": storyId},
      ),
      cancelToken: cancelToken,
    );
  }
}
