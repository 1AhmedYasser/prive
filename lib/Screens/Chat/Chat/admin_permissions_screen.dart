import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prive/Models/Chat/group_admin.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:collection/collection.dart';

import '../../../UltraNetwork/ultra_loading_indicator.dart';

class AdminPermissionsScreen extends StatefulWidget {
  final Channel channel;
  final GroupAdmin admin;
  const AdminPermissionsScreen({
    Key? key,
    required this.channel,
    required this.admin,
  }) : super(key: key);

  @override
  State<AdminPermissionsScreen> createState() => _AdminPermissionsScreenState();
}

class _AdminPermissionsScreenState extends State<AdminPermissionsScreen> {
  bool pinMessages = true;
  bool addMembers = true;
  bool addAdmins = true;
  bool changeGroupInfo = true;
  bool deleteOthersMessages = true;
  bool deleteMembers = true;
  List<GroupAdmin> groupAdmins = [];

  @override
  void initState() {
    _getGroupAdmins();
    _getAdminPermissions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StreamChatTheme.of(context).colorTheme.appBg,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 56.0,
        backgroundColor: StreamChatTheme.of(context).colorTheme.barsBg,
        leading: const StreamBackButton(),
        title: Column(
          children: [
            Text(
              "${widget.admin.name?.split(" ").first} Permissions",
              style: TextStyle(
                color: StreamChatTheme.of(context).colorTheme.textHighEmphasis,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ).tr()
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamOptionListTile(
              tileColor: StreamChatTheme.of(context).colorTheme.appBg,
              separatorColor: StreamChatTheme.of(context).colorTheme.disabled,
              title: "What Can This Admin Do ?".tr(),
              titleTextStyle: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 14.5,
              ),
            ),
            _buildPermission(
              "Pin Messages",
              pinMessages,
              () {
                setState(() {
                  pinMessages = !pinMessages;
                });
                groupAdmins
                    .firstWhereOrNull(
                      (admin) => admin.id == widget.admin.id,
                    )
                    ?.groupPermissions
                    ?.pinMessages = pinMessages;
                updateAdmins(context);
              },
            ),
            _buildPermission(
              "Add Members",
              addMembers,
              () {
                setState(() {
                  addMembers = !addMembers;
                });
                groupAdmins
                    .firstWhereOrNull(
                      (admin) => admin.id == widget.admin.id,
                    )
                    ?.groupPermissions
                    ?.addMembers = addMembers;
                updateAdmins(context);
              },
              separatorColor: StreamChatTheme.of(context).colorTheme.disabled,
            ),
            _buildPermission(
              "Add Admins",
              addAdmins,
              () {
                setState(() {
                  addAdmins = !addAdmins;
                });
                groupAdmins
                    .firstWhereOrNull(
                      (admin) => admin.id == widget.admin.id,
                    )
                    ?.groupPermissions
                    ?.addAdmins = addAdmins;
                updateAdmins(context);
              },
              separatorColor: StreamChatTheme.of(context).colorTheme.disabled,
            ),
            _buildPermission(
              "Change Group Info",
              changeGroupInfo,
              () {
                setState(() {
                  changeGroupInfo = !changeGroupInfo;
                });
                groupAdmins
                    .firstWhereOrNull(
                      (admin) => admin.id == widget.admin.id,
                    )
                    ?.groupPermissions
                    ?.changeGroupInfo = changeGroupInfo;
                updateAdmins(context);
              },
              separatorColor: StreamChatTheme.of(context).colorTheme.disabled,
            ),
            _buildPermission(
              "Delete Members Messages",
              deleteOthersMessages,
              () {
                setState(() {
                  deleteOthersMessages = !deleteOthersMessages;
                });
                groupAdmins
                    .firstWhereOrNull(
                      (admin) => admin.id == widget.admin.id,
                    )
                    ?.groupPermissions
                    ?.deleteOthersMessages = deleteOthersMessages;
                updateAdmins(context);
              },
              separatorColor: StreamChatTheme.of(context).colorTheme.disabled,
            ),
            _buildPermission(
              "Delete Members",
              deleteMembers,
              () {
                setState(() {
                  deleteMembers = !deleteMembers;
                });
                groupAdmins
                    .firstWhereOrNull(
                      (admin) => admin.id == widget.admin.id,
                    )
                    ?.groupPermissions
                    ?.deleteMembers = deleteMembers;
                updateAdmins(context);
              },
              separatorColor: StreamChatTheme.of(context).colorTheme.disabled,
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: StreamChatTheme.of(context).colorTheme.disabled,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 70),
              child: ElevatedButton(
                onPressed: () {
                  groupAdmins.remove(
                    groupAdmins.firstWhereOrNull(
                      (admin) => admin.id == widget.admin.id,
                    ),
                  );
                  BotToast.removeAll("loading");
                  BotToast.showAnimationWidget(
                      toastBuilder: (context) {
                        return const IgnorePointer(
                            child: UltraLoadingIndicator());
                      },
                      animationDuration: const Duration(milliseconds: 0),
                      groupKey: "loading");
                  updateAdmins(context, goBackAfterUpdate: true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  elevation: 0,
                  minimumSize: Size(
                    MediaQuery.of(context).size.width / 2.5,
                    50,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Remove Admin",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ).tr(),
              ),
            )
          ],
        ),
      ),
    );
  }

  void updateAdmins(BuildContext context, {bool goBackAfterUpdate = false}) {
    List<Map<String, dynamic>> admins = [];
    for (var admin in groupAdmins) {
      admins.add({
        "id": admin.id,
        "name": admin.name,
        "image": admin.image,
        "group_role": admin.groupRole,
        "admin_permissions": {
          "pin_messages": admin.groupPermissions?.pinMessages ?? true,
          "add_members": admin.groupPermissions?.addMembers ?? true,
          "add_admins": admin.groupPermissions?.addAdmins ?? true,
          "change_group_info": admin.groupPermissions?.changeGroupInfo ?? true,
          "delete_others_messages":
              admin.groupPermissions?.deleteOthersMessages ?? true,
          "delete_members": admin.groupPermissions?.deleteMembers ?? true
        },
      });
    }
    widget.channel.updatePartial(set: {"group_admins": admins}).then((value) {
      if (goBackAfterUpdate) {
        if (mounted) {
          Navigator.pop(context);
        }
      }
      BotToast.removeAll("loading");
    });
  }

  Widget _buildPermission(
    String title,
    bool permission,
    Function onPressed, {
    Color separatorColor = Colors.transparent,
  }) {
    return StreamOptionListTile(
      tileColor: StreamChatTheme.of(context).colorTheme.appBg,
      separatorColor: separatorColor,
      title: title.tr(),
      titleTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 14.5,
      ),
      trailing: CupertinoSwitch(
        value: permission,
        onChanged: (val) {
          onPressed();
        },
      ),
    );
  }

  void _getGroupAdmins() {
    groupAdmins = [];
    List<dynamic>? admins =
        widget.channel.extraData['group_admins'] as List<dynamic>? ?? [];
    for (var admin in admins) {
      GroupAdmin groupAdmin =
          GroupAdmin.fromJson(admin as Map<String, dynamic>);
      groupAdmins.add(groupAdmin);
    }
    setState(() {});
  }

  void _getAdminPermissions() {
    AdminGroupPermissions? permissions = widget.admin.groupPermissions;
    pinMessages = permissions?.pinMessages ?? true;
    addMembers = permissions?.addMembers ?? true;
    addAdmins = permissions?.addAdmins ?? true;
    changeGroupInfo = permissions?.changeGroupInfo ?? true;
    deleteOthersMessages = permissions?.deleteOthersMessages ?? true;
    deleteMembers = permissions?.deleteMembers ?? true;
    setState(() {});
  }
}
