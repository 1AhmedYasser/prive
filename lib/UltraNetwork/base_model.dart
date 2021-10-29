abstract class BaseModel<T> {
  void fromJson(Map<String, dynamic> json);
  void fromJsonList(List<Map<String, dynamic>> json){}
}