import 'dart:convert';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ultra_error.dart';
import 'ultra_helpers.dart';
import 'ultra_loading_indicator.dart';
import 'ultra_request.dart';

class UltraNetwork with ChangeNotifier {
  final Dio dio = Dio();
  String uploadProgress = "0";
  String uploadFileName = "";

  static Future<dynamic> request(
    BuildContext context,
    UltraRequest request, {
    Map<String, dynamic>? parameters,
    bool showLoadingIndicator = true,
    required CancelToken cancelToken,
    Function? onError,
    isList = false,
    bool showError = true,
    FormData? formData,
    bool decodeResponse = true,
  }) {
    return Provider.of<UltraNetwork>(context, listen: false)._ultraRequest(
      context,
      request,
      parameters: parameters,
      showLoadingIndicator: showLoadingIndicator,
      cancelToken: cancelToken,
      isList: isList,
      onError: onError,
      showError: showError,
      formData: formData,
      decodeResponse: decodeResponse,
    );
  }

  Future<dynamic> _ultraRequest(BuildContext context, UltraRequest request,
      {Map<String, dynamic>? parameters,
      bool showLoadingIndicator = true,
      required CancelToken cancelToken,
      Function? onError,
      isList = false,
      bool showError = true,
      FormData? formData,
      bool decodeResponse = true}) async {
    if (await Connectivity().checkConnectivity() != ConnectivityResult.none) {
      if (showLoadingIndicator) {
        BotToast.showAnimationWidget(
            toastBuilder: (context) {
              return const IgnorePointer(child: UltraLoadingIndicator());
            },
            animationDuration: const Duration(milliseconds: 0));
      }
      var response = await dio.request(
        request.path,
        queryParameters: parameters,
        data: formData,
        cancelToken: cancelToken,
        onSendProgress: (rcv, total) {
          uploadProgress = ((rcv / total) * 100).toStringAsFixed(0);
          if (formData != null && formData.files.isNotEmpty) {
            uploadFileName = formData.files[0].value.filename ?? "";
            notifyListeners();
          }
        },
        options: Options(
            headers: await UHeaders.getHeaders(context), method: "post"),
      ).catchError((error) {
        if (cancelToken.isCancelled) {
          if (showLoadingIndicator) BotToast.removeAll();
        } else {
          print((error as DioError).response?.data);
          if (showError) UltraError.handleError(context, error, onError);
        }
      });

      if (cancelToken.isCancelled == false) {
        if (showLoadingIndicator) {
          BotToast.removeAll();
        }
      }

      if (response.statusCode! >= 200 && response.statusCode! < 400) {
        if (decodeResponse) {
          (isList)
              ? request.model.fromJsonList(
                  List<Map<String, dynamic>>.from(response.data),
                )
              : request.model.fromJson(
                  Map<String, dynamic>.from(
                    (response.data is String)
                        ? json.decode(response.data)
                        : response.data,
                  ),
                );
        }
        print("Ultra Request ${request.path}");
        print("Ultra Response ${response.data}");
        return request.model;
      }
    } else {
      if (showError) {
        showOkAlertDialog(
            context: context,
            title: "Network Error",
            message: "No Internet Connection");
      }
    }
  }
}
