class CallMember {
  String? id;
  String? name;
  String? image;
  String? phone;
  bool? isMicOn;
  bool? hasPermissionToListen;
  bool? hasPermissionToSpeak;
  bool? isVideoOn;
  bool? isHeadphonesOn;
  bool? isSpeaking;

  CallMember({
    required this.id,
    required this.name,
    required this.image,
    required this.phone,
    required this.isMicOn,
    required this.isHeadphonesOn,
    this.hasPermissionToSpeak = true,
    this.hasPermissionToListen = true,
    this.isVideoOn,
    this.isSpeaking = false,
  });

  CallMember.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String?;
    name = json['name'] as String?;
    image = json['image'] as String?;
    phone = json['phone'] as String?;
    isHeadphonesOn = json['isHeadphonesOn'] as bool?;
    isMicOn = json['isMicOn'] as bool?;
    isVideoOn = json['isVideoOn'] as bool?;
    hasPermissionToSpeak = json['hasPermissionToSpeak'] as bool?;
    hasPermissionToListen = json['hasPermissionToListen'] as bool?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['id'] = id;
    json['name'] = name;
    json['image'] = image;
    json['phone'] = phone;
    json['isHeadphonesOn'] = isHeadphonesOn;
    json['isMicOn'] = isMicOn;
    json['isVideoOn'] = isVideoOn;
    json['hasPermissionToSpeak'] = hasPermissionToSpeak;
    json['hasPermissionToListen'] = hasPermissionToListen;
    return json;
  }
}
