import 'package:prive/UltraNetwork/base_model.dart';

class Collection extends BaseModel<Collection> {
  int? statusCode;
  bool? success;
  List<CollectionData>? data;
  String? message;

  @override
  void fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'] as int?;
    success = json['success'] as bool?;
    data = (json['data'] as List?)
        ?.map((dynamic e) => CollectionData.fromJson(e as Map<String, dynamic>))
        .toList();
    message = json['message'] as String?;
  }
}

class CollectionData {
  String? collectionID;
  String? collectionName;
  String? collectionPhoto;
  String? userID;
  String? catalogeID;

  CollectionData.fromJson(Map<String, dynamic> json) {
    collectionID = json['CollectionID'] as String?;
    collectionName = json['CollectionName'] as String?;
    collectionPhoto = json['CollectionPhoto'] as String?;
    userID = json['UserID'] as String?;
    catalogeID = json['CatalogeID'] as String?;
  }
}
