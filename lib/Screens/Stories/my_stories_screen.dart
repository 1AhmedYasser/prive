import 'package:dashed_circle/dashed_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prive/Screens/Stories/stories_viewer_screen.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';
import 'package:timeago/timeago.dart' as time_ago;
import 'package:intl/intl.dart';
import '../../Models/Stories/stories.dart';
import "package:collection/collection.dart";

import '../../Widgets/Common/cached_image.dart';

//ignore: must_be_immutable
class MyStoriesScreen extends StatefulWidget {
  List<StoriesData> myStories;
  MyStoriesScreen({Key? key, required this.myStories}) : super(key: key);

  @override
  State<MyStoriesScreen> createState() => _MyStoriesScreenState();
}

class _MyStoriesScreenState extends State<MyStoriesScreen> {
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
          ),
        ),
      ),
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: ListView.builder(
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return Container(
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
                        ),
                      );
                    } else if (widget.myStories[i].type == "Videos") {
                      storesStories.add(
                        StoryItem.pageVideo(
                          widget.myStories[i].content ?? "",
                          controller: storyController,
                          imageFit: BoxFit.fitWidth,
                          shown: index != i ? true : false,
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
                          passedStories: passedStories,
                          usersStories: [widget.myStories],
                        );
                      },
                      transitionsBuilder:
                          (_, Animation<double> animation, __, Widget child) {
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
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: DashedCircle(
                              child: Padding(
                                padding: const EdgeInsets.all(3),
                                child: SizedBox(
                                  width: 70,
                                  height: 70,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(60),
                                    child: CachedImage(
                                      url:
                                          widget.myStories[index].content ?? "",
                                    ),
                                  ),
                                ),
                              ),
                              dashes: 0,
                              gapSize: 0,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${widget.myStories.firstOrNull?.userFirstName?.trim() ?? ""} ${widget.myStories.firstOrNull?.userLastName?.trim() ?? ""}",
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  time_ago.format(
                                    DateFormat("yyyy-MM-dd HH:mm:ss", "en")
                                        .parse(
                                            widget.myStories[index]
                                                    .createdAtStory ??
                                                DateTime.now().toString(),
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
            );
          },
          itemCount: widget.myStories.length,
        ),
      ),
    );
  }
}
