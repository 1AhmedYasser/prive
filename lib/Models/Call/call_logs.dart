import 'package:prive/UltraNetwork/base_model.dart';

class CallLogs extends BaseModel<CallLogs> {
  int? statusCode;
  bool? success;
  List<CallLogsData>? data;
  String? message;

  @override
  void fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'] as int?;
    success = json['success'] as bool?;
    data = (json['data'] as List?)
        ?.map((dynamic e) => CallLogsData.fromJson(e as Map<String, dynamic>))
        .toList();
    message = json['message'] as String?;
  }
}

class CallLogsData {
  List<Sender>? sender;
  List<Receiver>? receiver;
  String? cALLID;
  String? senderID;
  String? receiverID;
  String? duration;
  String? callStatues;
  String? callType;
  String? lastUpdatedCalls;
  String? createdAtCalls;

  CallLogsData.fromJson(Map<String, dynamic> json) {
    sender = (json['0'] as List?)
        ?.map((dynamic e) => Sender.fromJson(e as Map<String, dynamic>))
        .toList();
    receiver = (json['1'] as List?)
        ?.map((dynamic e) => Receiver.fromJson(e as Map<String, dynamic>))
        .toList();
    cALLID = json['CALLID'] as String?;
    senderID = json['SenderID'] as String?;
    receiverID = json['ReceiverID'] as String?;
    duration = json['Duration'] as String?;
    callStatues = json['CallStatues'] as String?;
    callType = json['CallType'] as String?;
    lastUpdatedCalls = json['lastUpdatedCalls'] as String?;
    createdAtCalls = json['CreatedAtCalls'] as String?;
  }
}

class Sender {
  String? userID;
  String? userPhone;
  String? userFirstName;
  String? userLastName;
  String? userPhoto;
  String? userGender;
  String? userBarCode;
  String? accountState;
  String? country;
  String? userStatus;
  String? token;
  String? firebaseToken;
  String? lastUpdatedUsers;
  String? createdAtUser;
  String? loged;

  Sender.fromJson(Map<String, dynamic> json) {
    userID = json['UserID'] as String?;
    userPhone = json['UserPhone'] as String?;
    userFirstName = json['UserFirstName'] as String?;
    userLastName = json['UserLastName'] as String?;
    userPhoto = json['UserPhoto'] as String?;
    userGender = json['UserGender'] as String?;
    userBarCode = json['UserBarCode'] as String?;
    accountState = json['AccountState'] as String?;
    country = json['Country'] as String?;
    userStatus = json['UserStatus'] as String?;
    token = json['Token'] as String?;
    firebaseToken = json['FirebaseToken'] as String?;
    lastUpdatedUsers = json['lastUpdatedUsers'] as String?;
    createdAtUser = json['CreatedAtUser'] as String?;
    loged = json['loged'] as String?;
  }
}

class Receiver {
  String? userID;
  String? userPhone;
  String? userFirstName;
  String? userLastName;
  String? userPhoto;
  String? userGender;
  String? userBarCode;
  String? accountState;
  String? country;
  String? userStatus;
  String? token;
  String? firebaseToken;
  String? lastUpdatedUsers;
  String? createdAtUser;
  String? loged;

  Receiver.fromJson(Map<String, dynamic> json) {
    userID = json['UserID'] as String?;
    userPhone = json['UserPhone'] as String?;
    userFirstName = json['UserFirstName'] as String?;
    userLastName = json['UserLastName'] as String?;
    userPhoto = json['UserPhoto'] as String?;
    userGender = json['UserGender'] as String?;
    userBarCode = json['UserBarCode'] as String?;
    accountState = json['AccountState'] as String?;
    country = json['Country'] as String?;
    userStatus = json['UserStatus'] as String?;
    token = json['Token'] as String?;
    firebaseToken = json['FirebaseToken'] as String?;
    lastUpdatedUsers = json['lastUpdatedUsers'] as String?;
    createdAtUser = json['CreatedAtUser'] as String?;
    loged = json['loged'] as String?;
  }
}
