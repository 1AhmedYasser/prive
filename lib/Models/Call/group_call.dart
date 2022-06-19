import 'package:prive/Models/Call/group_call_member.dart';

class GroupCall {
  String? ownerId;
  String? type;
  List<GroupCallMember>? members;

  GroupCall({
    this.ownerId,
    this.type,
    this.members,
  });

  GroupCall.fromJson(Map<String, dynamic> json) {
    ownerId = json['ownerId'] as String?;
    type = json['type'] as String?;
    members = json['members'] as List<GroupCallMember>?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['ownerId'] = ownerId;
    json['type'] = type;
    json['members'] = members;
    return json;
  }
}
