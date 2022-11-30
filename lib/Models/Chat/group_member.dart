class GroupMember {
  String? id;
  String? name;
  String? image;
  String? groupRole;
  MemberGroupPermissions? memberPermissions;

  GroupMember(
    this.id,
    this.name,
    this.image,
    this.groupRole,
    this.memberPermissions,
  );

  GroupMember.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    groupRole = json['group_role'];
    memberPermissions =
        json['members_permissions'] != null ? MemberGroupPermissions.fromJson(json['members_permissions']) : null;
  }
}

class MemberGroupPermissions {
  bool? sendMessages;
  bool? sendPhotos;
  bool? sendVideos;
  bool? sendVoiceRecords;

  MemberGroupPermissions({
    this.sendMessages,
    this.sendPhotos,
    this.sendVideos,
    this.sendVoiceRecords,
  });

  MemberGroupPermissions.fromJson(Map<String, dynamic> json) {
    sendMessages = json['send_messages'];
    sendPhotos = json['send_photos'];
    sendVideos = json['send_videos'];
    sendVoiceRecords = json['send_voice_records'];
  }
}
