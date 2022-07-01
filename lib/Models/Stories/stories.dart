import 'package:prive/UltraNetwork/base_model.dart';

class Stories extends BaseModel<Stories> {
  int? statusCode;
  bool? success;
  List<StoriesData>? data;
  String? message;

  @override
  void fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'] as int?;
    success = json['success'] as bool?;
    data = (json['data'] as List?)
        ?.map((dynamic e) => StoriesData.fromJson(e as Map<String, dynamic>))
        .toList();
    message = json['message'] as String?;
  }
}

class StoriesData {
  List<StoryViewUser>? viewUser;
  String? stotyID;
  String? userID;
  String? content;
  String? type;
  String? views;
  String? lastUpdatedStory;
  String? createdAtStory;
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

  StoriesData.fromJson(Map<String, dynamic> json) {
    viewUser = (json['0'] as List?)
        ?.map((dynamic e) => StoryViewUser.fromJson(e as Map<String, dynamic>))
        .toList();
    stotyID = json['StotyID'] as String?;
    userID = json['UserID'] as String?;
    content = json['Content'] as String?;
    type = json['Type'] as String?;
    views = json['View'] as String?;
    lastUpdatedStory = json['lastUpdatedStory'] as String?;
    createdAtStory = json['CreatedAtStory'] as String?;
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

class StoryViewUser {
  String? storyReviewID;
  String? userID;
  String? storyID;
  String? lastUpdatedReview;
  String? createdAtReview;
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

  StoryViewUser.fromJson(Map<String, dynamic> json) {
    storyReviewID = json['StoryReviewID'] as String?;
    userID = json['UserID'] as String?;
    storyID = json['StoryID'] as String?;
    lastUpdatedReview = json['lastUpdatedReview'] as String?;
    createdAtReview = json['CreatedAtReview'] as String?;
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
