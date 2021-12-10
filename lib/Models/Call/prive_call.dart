import 'package:prive/UltraNetwork/base_model.dart';

class PriveCall extends BaseModel<PriveCall> {
  int? statusCode;
  bool? success;
  String? data;
  String? message;

  @override
  void fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'] as int?;
    success = json['success'] as bool?;
    data = json['data'] as String?;
    message = json['message'] as String?;
  }
}