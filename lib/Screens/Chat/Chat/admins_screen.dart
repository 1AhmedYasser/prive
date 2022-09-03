import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:collection/collection.dart';

import '../../../Extras/resources.dart';
import '../../../Helpers/utils.dart';
import 'add_members_admins_screen.dart';

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
      body: Column(
        children: [
          StreamBuilder<List<Member>>(
            stream: widget.channel.state!.membersStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  color: StreamChatTheme.of(context).colorTheme.disabled,
                  child: const Center(child: CircularProgressIndicator()),
                );
              }

              var userMember = snapshot.data!.firstWhereOrNull(
                (e) => e.user!.id == StreamChat.of(context).currentUser!.id,
              );
              userRole = userMember?.role ?? "member";
              return _buildAdmins(snapshot.data!);
            },
          )
        ],
      ),
    );
  }

  Widget _buildAdmins(List<Member> members) {
    List<Member> groupMembers =
        members.where((e) => e.role == "owner" || e.role == "admin").toList();

    int groupMembersLength = groupMembers.length > 6 ? 6 : groupMembers.length;

    return Column(
      children: [
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
            );
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
          itemCount: groupMembersLength,
          itemBuilder: (context, index) {
            final member = groupMembers[index];
            return Material(
              color: StreamChatTheme.of(context).colorTheme.appBg,
              child: InkWell(
                onTap: () {
                  final userMember = groupMembers.firstWhereOrNull(
                    (e) => e.user!.id == StreamChat.of(context).currentUser!.id,
                  );
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
                            child: UserAvatar(
                              user: member.user!,
                              constraints: const BoxConstraints.tightFor(
                                height: 40.0,
                                width: 40.0,
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
                                FutureBuilder(
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const SizedBox.shrink();
                                    } else {
                                      return Text(
                                        snapshot.data as String? ?? "",
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }
                                  },
                                  future: _getUserName(member.user!),
                                ),
                                const SizedBox(
                                  height: 1.0,
                                ),
                                Text(
                                  _getLastSeen(member.user!),
                                  style: TextStyle(
                                      color: StreamChatTheme.of(context)
                                          .colorTheme
                                          .textHighEmphasis
                                          .withOpacity(0.5)),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Text(
                              member.role == 'owner'
                                  ? "Owner"
                                  : member.role == 'admin'
                                      ? "Admin"
                                      : "Member",
                              style: TextStyle(
                                color: StreamChatTheme.of(context)
                                    .colorTheme
                                    .textHighEmphasis
                                    .withOpacity(0.5),
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
        if (groupMembersLength != groupMembers.length)
          InkWell(
            onTap: () {},
            child: Material(
              color: StreamChatTheme.of(context).colorTheme.appBg,
              child: SizedBox(
                height: 65.0,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 21.0, vertical: 12.0),
                            child: StreamSvgIcon.down(
                              color: StreamChatTheme.of(context)
                                  .colorTheme
                                  .textLowEmphasis,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${members.length - groupMembersLength} ${"More".tr()}',
                                  style: TextStyle(
                                      color: StreamChatTheme.of(context)
                                          .colorTheme
                                          .textLowEmphasis),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 1.0,
                      color: StreamChatTheme.of(context).colorTheme.disabled,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
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
    String? myContacts = await Utils.getString(R.pref.myContacts);
    if (myContacts != null && myContacts.isNotEmpty == true) {
      List<dynamic> usersMapList =
          jsonDecode(await Utils.getString(R.pref.myContacts) ?? "");
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
}
