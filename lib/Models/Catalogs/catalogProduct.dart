import 'package:prive/UltraNetwork/base_model.dart';

class CatalogProduct extends BaseModel<CatalogProduct> {
  int? statusCode;
  bool? success;
  List<CatalogProductData>? data;
  String? message;

  @override
  void fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'] as int?;
    success = json['success'] as bool?;
    data = (json['data'] as List?)
        ?.map((dynamic e) =>
            CatalogProductData.fromJson(e as Map<String, dynamic>))
        .toList();
    message = json['message'] as String?;
  }
}

class CatalogProductData {
  String? itemID;
  String? itemName;
  String? collectionID;
  String? userID;
  String? photo1;
  String? photo2;
  String? photo3;

  CatalogProductData.fromJson(Map<String, dynamic> json) {
    itemID = json['ItemID'] as String?;
    itemName = json['ItemName'] as String?;
    collectionID = json['CollectionID'] as String?;
    userID = json['UserID'] as String?;
    photo1 = json['Photo1'] as String?;
    photo2 = json['Photo2'] as String?;
    photo3 = json['Photo3'] as String?;
  }
}
