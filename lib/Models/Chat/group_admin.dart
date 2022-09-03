class GroupAdmin {
  String? id;
  String? name;
  String? image;
  String? groupRole;
  AdminGroupPermissions? groupPermissions;

  GroupAdmin(
      this.id, this.name, this.image, this.groupRole, this.groupPermissions);

  GroupAdmin.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    groupRole = json['group_role'];
    groupPermissions = json['admin_permissions'] != null
        ? AdminGroupPermissions.fromJson(json['admin_permissions'])
        : null;
  }
}

class AdminGroupPermissions {
  bool? pinMessages;
  bool? addMembers;
  bool? addAdmins;
  bool? changeGroupInfo;
  bool? deleteOthersMessages;
  bool? deleteMembers;

  AdminGroupPermissions({
    this.pinMessages,
    this.addMembers,
    this.addAdmins,
    this.changeGroupInfo,
    this.deleteOthersMessages,
    this.deleteMembers,
  });

  AdminGroupPermissions.fromJson(Map<String, dynamic> json) {
    pinMessages = json['pin_messages'];
    addMembers = json['add_members'];
    addAdmins = json['add_admins'];
    changeGroupInfo = json['change_group_info'];
    deleteOthersMessages = json['delete_others_messages'];
    deleteMembers = json['delete_members'];
  }
}
