import 'base_model.dart';

class UltraRequest {
  String path;
  String method;
  BaseModel model;

  UltraRequest(this.path,this.method,this.model);
}