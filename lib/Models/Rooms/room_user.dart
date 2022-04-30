class RoomUser {
  String? id;
  String? name;
  String? image;
  bool? isOwner;
  bool? isSpeaker;
  bool? isListener;
  String? phone;
  bool? isHandRaised;
  bool? isMicOn;

  RoomUser(
      {required this.id,
      required this.name,
      required this.image,
      required this.isOwner,
      required this.isSpeaker,
      required this.isListener,
      required this.phone,
      required this.isHandRaised,
      required this.isMicOn});

  RoomUser.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String?;
    name = json['name'] as String?;
    image = json['image'] as String?;
    isOwner = json['isOwner'] as bool?;
    isSpeaker = json['isSpeaker'] as bool?;
    isListener = json['isListener'] as bool?;
    phone = json['phone'] as String?;
    isHandRaised = json['isHandRaised'] as bool?;
    isMicOn = json['isMicOn'] as bool?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['id'] = id;
    json['name'] = name;
    json['image'] = image;
    json['isOwner'] = isOwner;
    json['isSpeaker'] = isSpeaker;
    json['isListener'] = isListener;
    json['phone'] = phone;
    json['isHandRaised'] = isHandRaised;
    json['isMicOn'] = isMicOn;
    return json;
  }
}
