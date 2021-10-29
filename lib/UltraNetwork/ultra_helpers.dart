// Methods enum
import 'package:flutter/material.dart';
import 'package:prive/Extras/resources.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Methods { post, get, update, patch, delete }

// Methods enum to string
extension StringValue on Methods {
  String value() {
    return toString().split('.').last;
  }
}

// Ultra Network Methods
class UMethods {
  static String get = Methods.get.value();
  static String post = Methods.post.value();
  static String update = Methods.update.value();
  static String patch = Methods.patch.value();
  static String delete = Methods.delete.value();
}

class UHeaders {
  static Future<Map<String, dynamic>> getHeaders(BuildContext context) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var headers = {
      "Content-Type": "application/json",
      "token": "${pref.get(R.pref.token)}"
    };
    return headers;
  }
}
