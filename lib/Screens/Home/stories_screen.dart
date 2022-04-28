import 'package:dashed_circle/dashed_circle.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Screens/Stories/stories_viewer_screen.dart';
import 'package:prive/UltraNetwork/ultra_constants.dart';
import 'package:prive/UltraNetwork/ultra_network.dart';
import 'package:prive/Widgets/Common/cached_image.dart';
import "package:collection/collection.dart";
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';
import '../../Models/Stories/stories.dart';
import 'package:timeago/timeago.dart' as time_ago;
import 'package:intl/intl.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({Key? key}) : super(key: key);

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  List<StoriesData> stories = [];
  List<List<StoriesData>> usersStories = [];
  CancelToken cancelToken = CancelToken();

  @override
  void initState() {
    time_ago.setLocaleMessages('en', time_ago.EnMessages());
    _getStories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f1f6),
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
                      children: const [
                        Text(
                          "Stories",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 60, bottom: 20),
            child: Container(
              height: 90,
              color: Colors.white,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Stack(
                      children: [
                        SizedBox(
                          width: 70,
                          height: 70,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: CachedImage(
                              url: context.currentUserImage ?? "",
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: -1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(90),
                            ),
                            child: Icon(
                              Icons.add_circle,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "My Story",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        "Add to my story",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const Expanded(child: SizedBox()),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.grey.shade300,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        size: 25,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.grey.shade300,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.edit,
                          size: 24,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, top: 10, bottom: 20),
            child: Text(
              "Recent Updates",
              style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
            ),
          ),
          Expanded(
            child: MediaQuery.removePadding(
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
                        for (var stories in usersStories) {
                          List<StoryItem> storesStories = [];
                          for (var story in stories) {
                            if (story.type == "Photos") {
                              storesStories.add(
                                StoryItem.pageImage(
                                  url: story.content ?? "",
                                  controller: storyController,
                                  imageFit: BoxFit.fitWidth,
                                ),
                              );
                            } else if (story.type == "Videos") {
                              storesStories.add(
                                StoryItem.pageVideo(
                                  story.content ?? "",
                                  controller: storyController,
                                  imageFit: BoxFit.fitWidth,
                                ),
                              );
                            }
                          }
                          passedStories.add(storesStories);
                        }
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (BuildContext context, _, __) {
                              return StoriesViewerScreen(
                                closeOnSwipeDown: true,
                                passedStories: passedStories,
                                usersStories: usersStories,
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
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20),
                                  child: DashedCircle(
                                    child: Padding(
                                      padding: const EdgeInsets.all(3),
                                      child: SizedBox(
                                        width: 70,
                                        height: 70,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(60),
                                          child: CachedImage(
                                            url: usersStories[index][0]
                                                    .userPhoto ??
                                                "",
                                          ),
                                        ),
                                      ),
                                    ),
                                    dashes: usersStories[index].length,
                                    gapSize:
                                        usersStories[index].length == 1 ? 0 : 3,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${usersStories[index][0].userFirstName?.trim() ?? ""} ${usersStories[index][0].userLastName?.trim() ?? ""}",
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
                                          DateFormat(
                                                  "yyyy-MM-dd HH:mm:ss", "en")
                                              .parse(
                                                  usersStories[index]
                                                          .last
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
                itemCount: usersStories.length,
              ),
            ),
          )
        ],
      ),
    );
  }

  void _getStories() {
    UltraNetwork.request(
      context,
      getStories,
      formData: FormData.fromMap(
        {"Contats": "+201159050530,+201015070284,+201156161108"},
      ),
      cancelToken: cancelToken,
    ).then((value) {
      if (value != null) {
        Stories storiesResponse = value;
        if (storiesResponse.success == true) {
          setState(() {
            stories = storiesResponse.data ?? [];
            Map<String?, List<StoriesData>> usersGrouped =
                groupBy(stories, (StoriesData obj) => obj.userID);
            usersGrouped.forEach((key, value) {
              usersStories.add(value);
            });
          });
        }
      }
    });
  }
}
