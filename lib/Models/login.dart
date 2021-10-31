import 'package:prive/UltraNetwork/base_model.dart';

class Login extends BaseModel<Login>{
  int? statusCode;
  bool? success;
  List<LoginData>? data;
  String? message;

  @override
  void fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'];
    success = json['success'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(LoginData.fromJson(v));
      });
    }
    message = json['message'];
  }
}

class LoginData {
  String? userID;
  String? userPhone;
  String? userFirstName;
  String? userLastName;
  String? userPhoto;
  String? userGender;
  String? userBarCode;
  String? accountState;
  String? country;
  String? token;
  String? firebaseToken;
  String? lastUpdatedUsers;
  String? createdAtUser;

  LoginData.fromJson(Map<String, dynamic> json) {
    userID = json['UserID'];
    userPhone = json['UserPhone'];
    userFirstName = json['UserFirstName'];
    userLastName = json['UserLastName'];
    userPhoto = json['UserPhoto'];
    userGender = json['UserGender'];
    userBarCode = json['UserBarCode'];
    accountState = json['AccountState'];
    country = json['Country'];
    token = json['Token'];
    firebaseToken = json['FirebaseToken'];
    lastUpdatedUsers = json['lastUpdatedUsers'];
    createdAtUser = json['CreatedAtUser'];
  }
}