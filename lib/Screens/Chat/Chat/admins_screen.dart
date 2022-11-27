import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Widgets/Common/cached_image.dart';
import 'package:collection/collection.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../../../Helpers/utils.dart';
import '../../../Models/Chat/group_admin.dart';
import '../../../Resources/shared_pref.dart';
import 'add_members_admins_screen.dart';
import 'admin_permissions_screen.dart';

class AdminsScreen extends StatefulWidget {
  final Channel channel;
  const AdminsScreen({
    Key? key,
    required this.channel,
  }) : super(key: key);

  @override
  State<AdminsScreen> createState() => _AdminsScreenState();
}

class _AdminsScreenState extends State<AdminsScreen> {
  List<User> users = [];
  List<String> usersPhoneNumbers = [];
  bool userInContacts = true;
  String userRole = "";
  List<GroupAdmin> groupAdmins = [];
  GroupAdmin? adminSelf;

  @override
  void initState() {
    _getGroupAdmins();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StreamChatTheme.of(context).colorTheme.appBg,
      appBar: AppBar(
        elevation: 0.5,
        toolbarHeight: 56.0,
        backgroundColor: StreamChatTheme.of(context).colorTheme.barsBg,
        leading: const StreamBackButton(),
        title: Column(
          children: [
            Text(
              "Administrators",
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
      body: StreamBuilder<ChannelState>(
          stream: widget.channel.state?.channelStateStream,
          builder: (context, state) {
            _getGroupAdmins();
            return Column(
              children: [
                if (adminSelf?.groupPermissions?.addAdmins == true)
                  StreamOptionListTile(
                    tileColor: StreamChatTheme.of(context).colorTheme.appBg,
                    separatorColor: Colors.transparent,
                    title: "Add Admins".tr(),
                    titleTextStyle: TextStyle(color: Theme.of(context).primaryColor),
                    leading: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Icon(
                        Icons.person_add_rounded,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddMembersAdminsScreen(
                            channel: widget.channel,
                            isAddingAdmin: true,
                          ),
                        ),
                      ).then((value) => _getGroupAdmins());
                    },
                  ),
                Divider(
                  thickness: 1,
                  height: 1,
                  color: StreamChatTheme.of(context).colorTheme.disabled,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: groupAdmins.length,
                  itemBuilder: (context, index) {
                    GroupAdmin admin = groupAdmins[index];
                    return Material(
                      color: StreamChatTheme.of(context).colorTheme.appBg,
                      child: InkWell(
                        onTap: () {
                          if (groupAdmins[index].groupRole == "admin" && userRole == "owner") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdminPermissionsScreen(
                                  channel: widget.channel,
                                  admin: groupAdmins[index],
                                ),
                              ),
                            ).then((value) => _getGroupAdmins());
                          }
                        },
                        child: SizedBox(
                          height: 65.0,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 12.0,
                                    ),
                                    child: SizedBox(
                                      height: 40.0,
                                      width: 40.0,
                                      child: CachedImage(
                                        url: admin.image ?? "",
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // Text(
                                        //   member.user!.name,
                                        //   style: const TextStyle(
                                        //     fontWeight: FontWeight.bold,
                                        //   ),
                                        // ),
                                        Text(
                                          admin.name ?? "",
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20),
                                    child: Text(
                                      admin.groupRole == "owner"
                                          ? "Owner"
                                          : admin.groupRole == "admin"
                                              ? "Admin"
                                              : "Member",
                                      style: TextStyle(
                                        color: StreamChatTheme.of(context).colorTheme.textHighEmphasis.withOpacity(0.5),
                                      ),
                                    ).tr(),
                                  ),
                                ],
                              ),
                              Container(
                                height: 1.0,
                                color: StreamChatTheme.of(context).colorTheme.disabled,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          }),
    );
  }

  Future<String?> _getUserName(User user) async {
    await _getContacts();
    if (usersPhoneNumbers.contains(user.extraData["phone"] as String?)) {
      userInContacts = true;
      return user.name;
    } else {
      userInContacts = false;
      return user.extraData["phone"] as String? ?? "";
    }
  }

  _getContacts() async {
    String? myContacts = await Utils.getString(SharedPref.myContacts);
    if (myContacts != null && myContacts.isNotEmpty == true) {
      List<dynamic> usersMapList = jsonDecode(await Utils.getString(SharedPref.myContacts) ?? "");
      List<User> myUsers = [];
      for (var user in usersMapList) {
        myUsers.add(User(
          id: user['id'],
          name: user['name'],
          image: user['image'],
          extraData: {'phone': user['phone'], 'shadow_banned': false},
        ));
      }
      users = myUsers;
      usersPhoneNumbers = users
          .map(
            (e) => e.extraData['phone'] as String,
          )
          .toList();
      usersPhoneNumbers.add(context.currentUser?.extraData['phone'] as String);
    }
  }

  String _getLastSeen(User user) {
    if (user.online) {
      return "Online".tr();
    } else {
      return '${"Last Seen".tr()} ${Jiffy(user.lastActive).fromNow()}';
    }
  }

  void _getGroupAdmins() {
    groupAdmins = [];
    List<dynamic>? admins = widget.channel.extraData['group_admins'] as List<dynamic>;
    for (var admin in admins) {
      GroupAdmin groupAdmin = GroupAdmin.fromJson(admin as Map<String, dynamic>);
      groupAdmins.add(groupAdmin);
    }
    userRole = groupAdmins
            .firstWhereOrNull(
              (admin) => admin.id == context.currentUser?.id,
            )
            ?.groupRole ??
        "member";

    adminSelf = groupAdmins.firstWhereOrNull((admin) => admin.id == context.currentUser?.id);
  }
}
