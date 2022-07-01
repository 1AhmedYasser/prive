import 'dart:convert';
import 'package:bot_toast/bot_toast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../Extras/resources.dart';
import '../Helpers/utils.dart';
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
            animationDuration: const Duration(milliseconds: 0),
            groupKey: "loading");
      }
      try {
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
        );
        if (showLoadingIndicator) BotToast.removeAll("loading");
        if (response.statusCode! >= 200 && response.statusCode! < 400) {
          try {
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
          } catch (e) {
            print("Can't Decode $e");
            if (showLoadingIndicator) BotToast.removeAll("loading");
          }
          print("Ultra Request ${request.path}");
          print("Ultra Response ${response.data}");
          return request.model;
        }
      } on DioError catch (error) {
        if (showLoadingIndicator) BotToast.removeAll("loading");
        if (cancelToken.isCancelled == false) {
          if (showError) UltraError.handleError(context, error, onError);
        }
      }
    } else {
      if (showError) {
        bool? isAlertAlreadyOn = await Utils.getBool(R.pref.internetAlert);
        if (isAlertAlreadyOn == false || isAlertAlreadyOn == null) {
          Utils.showNoInternetConnection(context);
          Utils.saveBool(R.pref.internetAlert, true);
        }
      }
    }
  }
}
