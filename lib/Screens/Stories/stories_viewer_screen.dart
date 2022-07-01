import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_slider/carousel_slider_transforms.dart';
import 'package:story_view/story_view.dart';
import 'dart:ui' as ui;
import '../../Models/Stories/stories.dart';
import '../../Widgets/Common/cached_image.dart';
import "package:collection/collection.dart";

class StoriesViewerScreen extends StatefulWidget {
  final List<List<StoryItem>> passedStories;
  final List<List<StoriesData>> usersStories;
  final int passedStoriesInitialIndex;
  final Map<String, String> parameters;
  final bool closeOnSwipeDown;
  final StoryController? storyController;

  const StoriesViewerScreen({
    Key? key,
    this.closeOnSwipeDown = false,
    this.parameters = const {},
    this.passedStoriesInitialIndex = 0,
    this.passedStories = const [],
    this.usersStories = const [],
    this.storyController,
  }) : super(key: key);

  @override
  _StoriesViewerScreenState createState() => _StoriesViewerScreenState();
}

class _StoriesViewerScreenState extends State<StoriesViewerScreen> {
  bool isLoading = true;
  List<StoriesData>? stories;
  CancelToken cancelToken = CancelToken();
  List<StoryItem> storyItems = [];
  //StoryController storyController = StoryController();
  PageController pageController = PageController();
  CarouselSliderController carouselController = CarouselSliderController();

  bool isCurrentAUrl = false;

  @override
  void initState() {
    // if (widget.storyController != null) {
    //   storyController = widget.storyController!;
    // }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: widget.passedStories.isEmpty
          ? isLoading
              ? Container()
              : _buildStory()
          : _buildCube(),
    );
  }

  Widget _buildCube() {
    return CarouselSlider.builder(
      slideTransform: const CubeTransform(),
      scrollPhysics: const ClampingScrollPhysics(),
      controller: carouselController,
      keepPage: false,
      itemCount: widget.passedStories.length,
      initialPage: widget.passedStoriesInitialIndex,
      slideBuilder: (int index) {
        return SafeArea(
          child: Directionality(
            textDirection: ui.TextDirection.ltr,
            child: Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Stack(
                children: [
                  StoryView(
                    controller: widget.storyController!,
                    repeat: false,
                    inline: true,
                    onComplete: () {
                      if (index == widget.passedStories.length - 1) {
                        Navigator.pop(context);
                      } else {
                        carouselController
                            .nextPage(const Duration(milliseconds: 500));
                      }
                    },
                    onVerticalSwipeComplete: (direction) {
                      if (direction == Direction.down) {
                        if (widget.closeOnSwipeDown) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    storyItems: widget.passedStories[index],
                  ),
                  Positioned(
                    top: 35,
                    left: 18,
                    child: InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: CachedImage(
                                url: widget.usersStories[index].firstOrNull
                                        ?.userPhoto ??
                                    "",
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "${widget.usersStories[index].firstOrNull?.userFirstName?.trim() ?? ""} ${widget.usersStories[index].firstOrNull?.userLastName?.trim() ?? ""}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStory() {
    return storyItems.isNotEmpty
        ? SafeArea(
            child: Directionality(
              textDirection: ui.TextDirection.ltr,
              child: Padding(
                padding: const EdgeInsets.only(top: 18),
                child: Stack(
                  children: [
                    StoryView(
                      controller: widget.storyController!,
                      repeat: false,
                      inline: true,
                      onComplete: () {},
                      onVerticalSwipeComplete: (direction) {
                        if (direction == Direction.down) {
                          if (widget.closeOnSwipeDown) {
                            Navigator.pop(context);
                          }
                        }
                      },
                      storyItems: storyItems,
                    ),
                    if (widget.parameters.isNotEmpty)
                      Positioned(
                        top: 35,
                        left: 18,
                        child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Row(
                            children: [
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: const CachedImage(
                                    url: "",
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  @override
  void dispose() {
    widget.storyController?.dispose();
    BotToast.removeAll("loading");
    super.dispose();
  }
}
