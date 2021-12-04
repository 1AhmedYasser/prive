import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:prive/Extras/resources.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utils {
  static Future<void> showImagePickerSelector(
      BuildContext context, Function getImage) async {
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
              "Pick an Image".tr(),
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
                    getImage(ImageSource.gallery);
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
                        Icons.camera_alt,
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
                    getImage(ImageSource.camera);
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
      R.images.newGroupImage: "New Group",
      R.images.newSecretChatImage: "New Secret Chat",
      R.images.newChannelImage: "New Channel",
      R.images.newCatalogImage: "New Catalog",
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
                childAspectRatio: 2.8 / 2,
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
                        Navigator.pushNamed(context, R.routes.newGroupScreen);
                        break;
                      case 3:
                        print("hi4");
                        break;
                      case 4:
                        print("hi5");
                        break;
                      case 5:
                        print("hi6");
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
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..maxConnectionsPerHost = 5;
  }
}
