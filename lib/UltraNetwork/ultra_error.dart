import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

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
        case 404:
          _showErrorMessage(context,
              "We Encountered an error, please try again or contact the admin");
          break;
        default:
          break;
      }
    }
  }

  static void _showErrorMessage(BuildContext context, String message,
      {String title = "Jibler"}) {
    showOkAlertDialog(
      context: context,
      title: title,
      message: message,
    );
  }
}
