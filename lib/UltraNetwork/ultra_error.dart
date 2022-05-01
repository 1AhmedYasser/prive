import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../Extras/resources.dart';
import '../Helpers/utils.dart';

class UltraError {
  static CancelToken cancelToken = CancelToken();

  static void handleError(
      BuildContext context, DioError error, Function? okError) {
    if (error.response != null) {
      switch (error.response!.statusCode) {
        case 500:
          _showErrorMessage(context,
              "We Encountered an error, please try again or contact the admin");
          break;
        default:
          _showErrorMessage(
              context, jsonDecode(error.response?.data)['message']);
          break;
      }
    }
  }

  static void _showErrorMessage(BuildContext context, String message,
      {String title = "Prive"}) {
    Utils.showAlert(
      context,
      message: message,
      alertTitle: title,
      alertImage: R.images.alertErrorImage,
    );
  }
}
