import 'package:prive/Models/Call/call_member.dart';

class Call {
  String? ownerId;
  String? type;
  bool? isMuteAllEnabled;
  List<CallMember>? members;
  List<CallMember>? kickedMembers;

  Call({this.ownerId, this.type, this.members, this.kickedMembers, this.isMuteAllEnabled = false});

  Call.fromJson(Map<String, dynamic> json) {
    ownerId = json['ownerId'] as String?;
    type = json['type'] as String?;
    members = json['members'] as List<CallMember>?;
    kickedMembers = json['kickedMembers'] as List<CallMember>?;
    isMuteAllEnabled = json['isMuteAllEnabled'] as bool?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['ownerId'] = ownerId;
    json['type'] = type;
    json['members'] = members;
    json['kickedMembers'] = kickedMembers;
    json['isMuteAllEnabled'] = isMuteAllEnabled;
    return json;
  }
}
