import 'package:prive/UltraNetwork/base_model.dart';

class StatusResponse extends BaseModel<StatusResponse> {
  int? statusCode;
  bool? success;
  String? message;

  @override
  void fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'] as int?;
    success = json['success'] as bool?;
    message = json['message'] as String?;
  }
}
