import 'dart:convert';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:collection/collection.dart';
import 'package:country_dial_code/country_dial_code.dart';
import 'package:dashed_circle/dashed_circle.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prive/Helpers/Utils.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Models/Stories/stories.dart';
import 'package:prive/Resources/shared_pref.dart';
import 'package:prive/Screens/Stories/my_stories_screen.dart';
import 'package:prive/Screens/Stories/stories_viewer_screen.dart';
import 'package:prive/Screens/Stories/text_story_editor_screen.dart';
import 'package:prive/UltraNetwork/ultra_constants.dart';
import 'package:prive/UltraNetwork/ultra_loading_indicator.dart';
import 'package:prive/UltraNetwork/ultra_network.dart';
import 'package:prive/Widgets/AppWidgets/Stories/video_thumb_viewer.dart';
import 'package:prive/Widgets/Common/cached_image.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:timeago/timeago.dart' as time_ago;
import 'package:transition_plus/transition_plus.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({Key? key}) : super(key: key);

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  List<StoriesData> stories = [];
  List<List<StoriesData>> usersStories = [];
  List<StoriesData> myStories = [];
  CancelToken cancelToken = CancelToken();
  String? deviceCountryCode = WidgetsBinding.instance.window.locale.countryCode;
  CountryDialCode? deviceDialCode;
  bool permissionDenied = false;
  var phoneContacts = [];
  List<String> phoneNumbers = [];
  List<User> users = [];
  List<String> usersPhoneNumbers = [];
  late File capturedImage = File('');
  final imagePicker = ImagePicker();
  List<String> myThumbnails = [];
  List<List<String>> usersThumbnails = [];

  @override
  void initState() {
    time_ago.setLocaleMessages('en', time_ago.EnMessages());
    BotToast.showAnimationWidget(
      toastBuilder: (context) {
        return const IgnorePointer(child: UltraLoadingIndicator());
      },
      animationDuration: const Duration(milliseconds: 0),
      groupKey: 'loading',
    );
    _getContacts();
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
                      children: [
                        const Text(
                          'Stories',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w600,
                          ),
                        ).tr(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              if (myStories.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyStoriesScreen(
                      myStories: myStories,
                    ),
                  ),
                ).then((value) {
                  setState(() {});
                });
              } else {
                Utils.showImagePickerSelector(context, getImage, title: 'Choose Story Type'.tr(), withVideo: true);
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 60, bottom: 20),
              child: Container(
                height: 90,
                color: Colors.white,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          DashedCircle(
                            dashes: myStories.length,
                            gapSize: myStories.isNotEmpty
                                ? myStories.length == 1
                                    ? 0
                                    : 3
                                : 0,
                            color: Colors.grey.shade400.withOpacity(0.8),
                            child: Padding(
                              padding: const EdgeInsets.all(3),
                              child: SizedBox(
                                width: 70,
                                height: 70,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: myStories.isNotEmpty
                                      ? myStories.lastOrNull?.type == 'Photos'
                                          ? CachedImage(
                                              url: myStories.lastOrNull?.content ?? '',
                                            )
                                          : VideoThumbViewer(
                                              videoUrl: myStories.lastOrNull?.content ?? '',
                                            )
                                      : CachedImage(
                                          url: context.currentUserImage ?? '',
                                        ),
                                ),
                              ),
                            ),
                          ),
                          if (myStories.isEmpty)
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
                          'My Story',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                          ),
                        ).tr(),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          myStories.isEmpty
                              ? 'Add to my story'.tr()
                              : time_ago.format(
                                  DateFormat('yyyy-MM-dd HH:mm:ss', 'en')
                                      .parse(myStories.last.createdAtStory ?? DateTime.now().toString(), true)
                                      .toLocal(),
                                ),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const Expanded(child: SizedBox()),
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        Utils.showImagePickerSelector(
                          context,
                          getImage,
                          title: 'Choose Story Type'.tr(),
                          withVideo: true,
                        );
                      },
                      child: Container(
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
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 20),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          Navigator.push(
                            context,
                            ScaleTransition1(
                              page: const TextStoryEditorScreen(
                                backgroundColor: Colors.purple,
                              ),
                              type: ScaleTrasitionTypes.center,
                            ),
                          ).then((value) {
                            stories.clear();
                            usersStories.clear();
                            myStories.clear();
                            _getStories(usersPhoneNumbers.join(','));
                          });
                        },
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
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (usersStories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 15, top: 10, bottom: 20),
              child: Text(
                'Recent Updates',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
              ).tr(),
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
                            if (story.type == 'Photos') {
                              storesStories.add(
                                StoryItem.pageImage(
                                  url: story.content ?? '',
                                  controller: storyController,
                                  imageFit: BoxFit.fitWidth,
                                  duration: const Duration(seconds: 10),
                                ),
                              );
                            } else if (story.type == 'Videos') {
                              storesStories.add(
                                StoryItem.pageVideo(
                                  story.content ?? '',
                                  controller: storyController,
                                  imageFit: BoxFit.fitWidth,
                                  duration: const Duration(seconds: 30),
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
                                passedStoriesInitialIndex: index,
                                storyController: storyController,
                              );
                            },
                            transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
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
                                    dashes: usersStories[index].length,
                                    gapSize: usersStories[index].length == 1 ? 0 : 3,
                                    color: Theme.of(context).primaryColor,
                                    child: Padding(
                                      padding: const EdgeInsets.all(3),
                                      child: SizedBox(
                                        width: 70,
                                        height: 70,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(60),
                                          child: usersStories[index].firstOrNull?.type == 'Photos'
                                              ? CachedImage(
                                                  url: usersStories[index].firstOrNull?.content ?? '',
                                                )
                                              : VideoThumbViewer(
                                                  videoUrl: usersStories[index].firstOrNull?.content ?? '',
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${usersStories[index].firstOrNull?.userFirstName?.trim() ?? ""} ${usersStories[index].firstOrNull?.userLastName?.trim() ?? ""}",
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
                                          DateFormat('yyyy-MM-dd HH:mm:ss', 'en')
                                              .parse(
                                                usersStories[index].last.createdAtStory ?? DateTime.now().toString(),
                                                true,
                                              )
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

  _getContacts() async {
    String? myContacts = await Utils.getString(SharedPref.myContacts);
    if (myContacts != null && myContacts.isNotEmpty == true && myContacts != '[]') {
      List<dynamic> usersMapList = jsonDecode(await Utils.getString(SharedPref.myContacts) ?? '');
      List<User> myUsers = [];
      for (var user in usersMapList) {
        myUsers.add(
          User(
            id: user['id'],
            name: user['name'],
            image: user['image'],
            extraData: {'phone': user['phone'], 'shadow_banned': false},
          ),
        );
      }
      users = myUsers;
      phoneContacts = users.isNotEmpty ? [Contact()] : [];
      usersPhoneNumbers = users
          .map(
            (e) => e.extraData['phone'] as String,
          )
          .toList();
      usersPhoneNumbers.add(context.currentUser?.extraData['phone'] as String);
      _getStories(usersPhoneNumbers.join(','));
      setState(() {});
    } else {
      if (!await FlutterContacts.requestPermission(readonly: true)) {
        // TODO: Handle Permission Denied
      } else {
        if (!mounted) return;
        List contacts = await Utils.fetchContacts(context);
        users = contacts.first;
        phoneContacts = contacts[1];
        usersPhoneNumbers = users
            .map(
              (e) => e.extraData['phone'] as String,
            )
            .toList();
        usersPhoneNumbers.add(context.currentUser?.extraData['phone'] as String);
        _getStories(usersPhoneNumbers.join(','));
        setState(() {});
      }
    }
  }

  void _getStories(String phoneNumbers) {
    print(phoneNumbers);
    UltraNetwork.request(
      context,
      getStories,
      showLoadingIndicator: false,
      showError: false,
      formData: FormData.fromMap(
        {'Contats': phoneNumbers},
      ),
      cancelToken: cancelToken,
    ).then((value) {
      BotToast.removeAll('loading');
      if (value != null) {
        Stories storiesResponse = value;
        if (storiesResponse.success == true) {
          setState(() {
            stories = storiesResponse.data ?? [];
            Map<String?, List<StoriesData>> usersGrouped = groupBy(stories, (StoriesData obj) => obj.userID);
            usersGrouped.forEach((key, value) {
              if (key != context.currentUser?.id) {
                usersStories.add(value);
              } else {
                myStories = value;
              }
            });
          });
        }
      }
    });
  }

  Future getImage(ImageSource source, bool isVideo) async {
    Navigator.of(context).pop();
    XFile? pickedFile;
    if (isVideo == false) {
      pickedFile = await imagePicker.pickImage(source: source, imageQuality: 50);
    } else {
      pickedFile = await imagePicker.pickVideo(
        source: source,
        maxDuration: const Duration(seconds: 30),
      );
    }

    if (pickedFile != null) {
      capturedImage = File(pickedFile.path);
      _addStory(isVideo);
    }
  }

  void _addStory(bool isVideo) async {
    UltraNetwork.request(
      context,
      addStory,
      showError: false,
      formData: FormData.fromMap({
        'UserID': context.currentUser?.id,
        'Type': isVideo ? 'Videos' : 'Photos',
        'Content': await MultipartFile.fromFile(
          capturedImage.path,
          filename: 'mp4',
        ),
      }),
      cancelToken: cancelToken,
    ).then((value) {
      stories.clear();
      usersStories.clear();
      myStories.clear();
      _getStories(usersPhoneNumbers.join(','));
    });
  }
}
