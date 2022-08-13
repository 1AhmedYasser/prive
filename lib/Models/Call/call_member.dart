class CallMember {
  String? id;
  String? name;
  String? image;
  String? phone;
  bool? isMicOn;
  bool? isVideoOn;
  bool? isSpeaking;

  CallMember({
    required this.id,
    required this.name,
    required this.image,
    required this.phone,
    required this.isMicOn,
    this.isVideoOn,
    this.isSpeaking = false,
  });

  CallMember.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String?;
    name = json['name'] as String?;
    image = json['image'] as String?;
    phone = json['phone'] as String?;
    isMicOn = json['isMicOn'] as bool?;
    isVideoOn = json['isVideoOn'] as bool?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['id'] = id;
    json['name'] = name;
    json['image'] = image;
    json['phone'] = phone;
    json['isMicOn'] = isMicOn;
    json['isVideoOn'] = isVideoOn;
    return json;
  }
}
