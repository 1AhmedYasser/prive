import 'dart:io';
import 'package:country_dial_code/country_dial_code.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/UltraNetwork/ultra_constants.dart';
import 'package:prive/Widgets/AppWidgets/empty_state_widget.dart';
import 'package:quiver/iterables.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import '../UltraNetwork/ultra_network.dart';

class Utils {
  static final player = AudioPlayer();

  static Future<void> showImagePickerSelector(
      BuildContext context, Function getImage,
      {String title = "Pick an Image", bool withVideo = false}) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              side: BorderSide(color: Colors.white, width: 1.0)),
          title: Center(
            child: Text(
              title.tr(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 7,
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.photo_library,
                        color: Colors.black,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Gallery".tr(),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    getImage(ImageSource.gallery, false);
                  },
                ),
                const SizedBox(
                  height: 7,
                ),
                const Divider(),
                const SizedBox(
                  height: 7,
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.black,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Camera".tr(),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    getImage(ImageSource.camera, false);
                  },
                ),
                if (withVideo)
                  const SizedBox(
                    height: 7,
                  ),
                if (withVideo) const Divider(),
                if (withVideo)
                  const SizedBox(
                    height: 7,
                  ),
                if (withVideo)
                  InkWell(
                    splashColor: Colors.transparent,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.videocam,
                          color: Colors.black,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Video".tr(),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      getImage(ImageSource.camera, true);
                    },
                  ),
                const SizedBox(
                  height: 30,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Cancel".tr(),
                    style: const TextStyle(
                      fontSize: 17,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<dynamic> showMainMenu(BuildContext context) {
    Map<String, String> mainMenuItems = {
      R.images.addContactImage: "Add Contact",
      R.images.loadContactsListImage: "Load Contact List",
      R.images.newChannelImage: "New Channel",
      R.images.newGroupImage: "New Group",
      // R.images.newCatalogImage: "New Catalog",
    };
    return showMaterialModalBottomSheet(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(30), topLeft: Radius.circular(30))),
      context: context,
      builder: (context) =>
          StatefulBuilder(builder: (BuildContext context, setState) {
        return Padding(
          padding:
              const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 30),
          child: MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            removeTop: true,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5 / 2,
              ),
              itemBuilder: (context, index) {
                return InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    Navigator.pop(context);
                    switch (index) {
                      case 0:
                        Navigator.pushNamed(context, R.routes.addContactScreen);
                        break;
                      case 1:
                        Navigator.pushNamed(context, R.routes.contactsRoute);
                        break;
                      case 2:
                        break;
                      case 3:
                        Navigator.pushNamed(context, R.routes.newGroupScreen);
                        break;
                      case 4:
                        break;
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Image.asset(
                          mainMenuItems.keys.toList()[index],
                          width: 80,
                        ),
                        const SizedBox(height: 11),
                        Text(
                          mainMenuItems[mainMenuItems.keys.toList()[index]] ??
                              "",
                          style: const TextStyle(
                              color: Color(0xff7a8fa6), fontSize: 15),
                        )
                      ],
                    ),
                  ),
                );
              },
              itemCount: mainMenuItems.length,
            ),
          ),
        );
      }),
    );
  }

  static void logCallStart(
    BuildContext context,
    String senderId,
    String receiverID,
    bool isVideo,
  ) {
    UltraNetwork.request(
      context,
      addCall,
      showLoadingIndicator: false,
      showError: false,
      formData: FormData.fromMap(
        {
          "SenderID": senderId,
          "ReceiverID": receiverID,
          "CallType": isVideo ? "Video" : "Voice",
        },
      ),
      cancelToken: CancelToken(),
    );
  }

  static void logAnswerOrCancelCall(
    BuildContext context,
    String receiverID,
    String callStatus,
    String duration,
  ) {
    UltraNetwork.request(
      context,
      answerOrCancelCall,
      showLoadingIndicator: false,
      showError: false,
      formData: FormData.fromMap(
        {
          "ReceiverID": receiverID,
          "CallStatues": callStatus,
          "Duration": duration,
        },
      ),
      cancelToken: CancelToken(),
    );
  }

  static void playSound(String sound, {bool isLooping = false}) async {
    await player.setAsset(sound);
    player.play();
  }

  static bool isValidEmail(String email) {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(email);
  }

  static void saveString(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  static void saveBool(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  static Future<bool?> getBool(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  static Future<String?> getString(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static void checkForInternetConnection(BuildContext context) async {
    if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
      Utils.showNoInternetConnection(context);
    }
  }

  static Future<void> showNoInternetConnection(BuildContext context) async {
    return showDialog(
      barrierColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            elevation: 0,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                side: BorderSide(color: Colors.white, width: 1.0)),
            content: EmptyStateWidget(
              image: R.images.noInternetImage,
              title: "No Internet Connection".tr(),
              description: "Please check your connection or try again".tr(),
              onButtonPressed: () {
                Utils.saveBool(R.pref.internetAlert, false);
                Navigator.pop(context);
              },
              buttonText: "Try Again".tr(),
            ));
      },
    );
  }

  static String getLatestMessageDate(DateTime data) {
    final now = DateTime.now();
    DateTime messageDate = data.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    final messageDateFormatted =
        DateTime(messageDate.year, messageDate.month, messageDate.day);

    if (messageDateFormatted == today) {
      return DateFormat('hh:mm a').format(messageDate);
    } else if (messageDateFormatted == yesterday) {
      return "Yesterday";
    } else {
      DateTime firstDayOfTheCurrentWeek =
          now.subtract(Duration(days: now.weekday - 1));
      if (messageDate.isBefore(firstDayOfTheCurrentWeek)) {
        return DateFormat('d/MM/yyyy').format(messageDate);
      } else {
        return DateFormat('EEEE').format(messageDate);
      }
    }
  }

  static String getLastSeenDate(DateTime data, BuildContext context) {
    String lastSeen = "last seen ";
    final now = DateTime.now();
    DateTime lastSeenDate = data.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    final lastSeenDateFormatted =
        DateTime(lastSeenDate.year, lastSeenDate.month, lastSeenDate.day);

    if (lastSeenDateFormatted == today) {
      lastSeen += "today at ${DateFormat('hh:mm a').format(lastSeenDate)}";
    } else if (lastSeenDateFormatted == yesterday) {
      lastSeen += "yesterday at ${DateFormat('hh:mm a').format(lastSeenDate)}";
    } else {
      DateTime firstDayOfTheCurrentWeek =
          now.subtract(Duration(days: now.weekday - 1));
      if (lastSeenDate.isBefore(firstDayOfTheCurrentWeek)) {
        lastSeen +=
            "${DateFormat.MMMd(context.locale.languageCode).format(lastSeenDate)} at ${DateFormat('hh:mm a').format(lastSeenDate)}";
      } else {
        lastSeen +=
            "${DateFormat('EEEE').format(lastSeenDate)} at ${DateFormat('hh:mm a').format(lastSeenDate)}";
      }
    }
    return lastSeen;
  }

  static Future<List> fetchContacts(BuildContext context) async {
    CountryDialCode deviceDialCode = await _getCountry();
    List<User> users = [];
    List<Contact> phoneContacts = [];
    List<String> phoneNumbers = [];
    phoneContacts = await FlutterContacts.getContacts(withProperties: true);
    for (var contact in phoneContacts) {
      for (var phone in contact.phones) {
        try {
          PhoneNumber.fromRaw(phone.number.trim().replaceAll(" ", ""));
          if (phone.number.trim().replaceAll(" ", "").startsWith("011") ||
              phone.number.trim().replaceAll(" ", "").startsWith("010") ||
              phone.number.trim().replaceAll(" ", "").startsWith("012")) {
            String dialCode = deviceDialCode.dialCode == "+20"
                ? "+2"
                : deviceDialCode.dialCode;
            if (phone.number.trim().replaceAll(" ", "").startsWith("05")) {
              phoneNumbers.add(
                  "$dialCode${phone.number.trim().replaceAll(" ", "").substring(1)}");
            } else {
              phoneNumbers
                  .add("$dialCode${phone.number.trim().replaceAll(" ", "")}");
            }
          } else {
            phoneNumbers.add(phone.number.trim().replaceAll(" ", ""));
          }
        } catch (e) {
          String dialCode =
              deviceDialCode.dialCode == "+20" ? "+2" : deviceDialCode.dialCode;

          if (phone.number.trim().replaceAll(" ", "").startsWith("05")) {
            phoneNumbers.add(
                "$dialCode${phone.number.trim().replaceAll(" ", "").substring(1)}");
          } else {
            phoneNumbers
                .add("$dialCode${phone.number.trim().replaceAll(" ", "")}");
          }
        }
      }
    }

    // Handling Filters
    List<List<String>> dividedPhoneNumbers = [];
    dividedPhoneNumbers = partition(phoneNumbers, 500).toList();
    for (var phoneNumbers in dividedPhoneNumbers) {
      QueryUsersResponse usersResponse =
          await StreamChatCore.of(context).client.queryUsers(
        filter: Filter.and([
          Filter.notEqual("id", context.currentUser!.id),
          Filter.notEqual("role", "admin"),
          Filter.in_("phone", phoneNumbers)
        ]),
        sort: const [
          SortOption(
            'name',
            direction: 1,
          ),
        ],
      );
      for (var user in usersResponse.users) {
        users.add(user);
      }
    }

    return [users, phoneContacts];
  }

  static Future<CountryDialCode> _getCountry() async {
    String? deviceCountryCode =
        WidgetsBinding.instance?.window.locale.countryCode;
    CountryDialCode? deviceDialCode;
    try {
      deviceCountryCode =
          (await FlutterSimCountryCode.simCountryCode ?? "").toUpperCase();
      if (deviceCountryCode.isEmpty == true) {
        deviceCountryCode = WidgetsBinding.instance?.window.locale.countryCode;
      }
      deviceDialCode =
          CountryDialCode.fromCountryCode(deviceCountryCode ?? "US");
    } catch (e) {
      deviceCountryCode = WidgetsBinding.instance?.window.locale.countryCode;
      deviceDialCode =
          CountryDialCode.fromCountryCode(deviceCountryCode ?? "US");
    }
    return deviceDialCode;
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..maxConnectionsPerHost = 5;
  }
}
