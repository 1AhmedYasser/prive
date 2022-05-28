import 'package:prive/UltraNetwork/base_model.dart';

class Catalog extends BaseModel<Catalog> {
  int? statusCode;
  bool? success;
  List<CatalogData>? data;
  String? message;

  @override
  void fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'] as int?;
    success = json['success'] as bool?;
    data = (json['data'] as List?)
        ?.map((dynamic e) => CatalogData.fromJson(e as Map<String, dynamic>))
        .toList();
    message = json['message'] as String?;
  }
}

class CatalogData {
  String? catalogeID;
  String? userID;
  String? catalogeName;
  String? catalogePhoto;
  String? lastUpdatedCataloge;
  String? createdAtCataloge;

  CatalogData({
    this.catalogeID,
    this.userID,
    this.catalogeName,
    this.catalogePhoto,
    this.lastUpdatedCataloge,
    this.createdAtCataloge,
  });

  CatalogData.fromJson(Map<String, dynamic> json) {
    catalogeID = json['CatalogeID'] as String?;
    userID = json['UserID'] as String?;
    catalogeName = json['CatalogeName'] as String?;
    catalogePhoto = json['CatalogePhoto'] as String?;
    lastUpdatedCataloge = json['lastUpdatedCataloge'] as String?;
    createdAtCataloge = json['CreatedAtCataloge'] as String?;
  }
}
