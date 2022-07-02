import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_slider/carousel_slider_transforms.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prive/Providers/stories_provider.dart';
import 'package:prive/UltraNetwork/ultra_constants.dart';
import 'package:provider/provider.dart';
import 'package:story_view/story_view.dart';
import 'dart:ui' as ui;
import '../../Models/Stories/stories.dart';
import '../../UltraNetwork/ultra_network.dart';
import '../../Widgets/Common/cached_image.dart';
import "package:collection/collection.dart";
import 'package:prive/Helpers/stream_manager.dart';

class StoriesViewerScreen extends StatefulWidget {
  final List<List<StoryItem>> passedStories;
  final List<List<StoriesData>> usersStories;
  final int passedStoriesInitialIndex;
  final Map<String, String> parameters;
  final bool closeOnSwipeDown;
  final bool showViewers;
  final StoryController? storyController;

  const StoriesViewerScreen({
    Key? key,
    this.closeOnSwipeDown = false,
    this.parameters = const {},
    this.passedStoriesInitialIndex = 0,
    this.passedStories = const [],
    this.usersStories = const [],
    this.showViewers = false,
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
  PageController pageController = PageController();
  CarouselSliderController carouselController = CarouselSliderController();

  bool isCurrentAUrl = false;

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
                    onStoryShow: (story) {
                      WidgetsBinding.instance?.addPostFrameCallback(
                        (_) =>
                            Provider.of<StoriesProvider>(context, listen: false)
                                .setCurrentShownIndex(
                          widget.passedStories[index].indexOf(story),
                        ),
                      );
                      if (widget.showViewers == false) {
                        int storyIndex =
                            widget.passedStories[index].indexOf(story);
                        if (storyIndex != -1) {
                          _viewStory(
                              widget.usersStories[index][storyIndex].stotyID ??
                                  "0");
                        }
                      }
                    },
                    onComplete: () {
                      if (index == widget.passedStories.length - 1) {
                        Navigator.pop(context);
                      } else {
                        carouselController.nextPage(
                          const Duration(milliseconds: 500),
                        );
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
                  if (widget.showViewers)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            FontAwesomeIcons.chevronUp,
                            color: Colors.white,
                            size: 27,
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.remove_red_eye,
                                color: Colors.white,
                                size: 25,
                              ),
                              const SizedBox(width: 7),
                              Consumer<StoriesProvider>(
                                builder: (context, provider, ch) {
                                  return Text(
                                    provider.currentShowIndex != -1
                                        ? "${widget.usersStories[index][provider.currentShowIndex].views}"
                                        : "0",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                },
                              )
                            ],
                          )
                        ],
                      ),
                    )
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

  void _viewStory(String storyId) {
    UltraNetwork.request(
      context,
      viewStory,
      showError: false,
      showLoadingIndicator: false,
      formData: FormData.fromMap(
        {
          "UserID": context.currentUser?.id,
          "StoryID": storyId,
        },
      ),
      cancelToken: cancelToken,
    );
  }

  @override
  void dispose() {
    widget.storyController?.dispose();
    BotToast.removeAll("loading");
    super.dispose();
  }
}
