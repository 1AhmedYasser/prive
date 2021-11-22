import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prive/Extras/resources.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

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
