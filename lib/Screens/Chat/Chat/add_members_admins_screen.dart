import 'dart:async';
import 'dart:convert';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lottie/lottie.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../Extras/resources.dart';
import '../../../Helpers/utils.dart';
import '../../../UltraNetwork/ultra_loading_indicator.dart';
import '../../../Widgets/AppWidgets/channels_empty_widgets.dart';
import '../../../Widgets/ChatWidgets/search_text_field.dart';
import '../../../Widgets/Common/cached_image.dart';

class AddMembersAdminsScreen extends StatefulWidget {
  final Channel channel;
  final bool isAddingAdmin;
  const AddMembersAdminsScreen({
    Key? key,
    required this.channel,
    this.isAddingAdmin = false,
  }) : super(key: key);

  @override
  State<AddMembersAdminsScreen> createState() => _AddMembersAdminsScreenState();
}

class _AddMembersAdminsScreenState extends State<AddMembersAdminsScreen>
    with TickerProviderStateMixin {
  TextEditingController? _controller;
  List<Contact> phoneContacts = [];
  List<User> users = [];
  List<User> allUsers = [];
  late final AnimationController _animationController;
  bool _permissionDenied = false;
  Timer? _debounce;

  // Group
  List<Member> members = [];
  List<User> membersUsers = [];
  List<Member> nonMembers = [];
  List<User> nonMembersUsers = [];
  List<Member> admins = [];
  List<User> adminsUsers = [];
  List<User> nonAdminUsers = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
    _getContacts();
    _controller = TextEditingController()..addListener(_userNameListener);
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
              widget.isAddingAdmin ? "Add Admin" : "Add Member",
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
      body: ConnectionStatusBuilder(
        statusBuilder: (context, status) {
          String statusString = '';
          bool showStatus = true;

          switch (status) {
            case ConnectionStatus.connected:
              statusString = "Connected".tr();
              showStatus = false;
              break;
            case ConnectionStatus.connecting:
              statusString = "Connecting".tr();
              break;
            case ConnectionStatus.disconnected:
              statusString = "Disconnected".tr();
              break;
          }
          return InfoTile(
            showMessage: showStatus,
            tileAnchor: Alignment.topCenter,
            childAnchor: Alignment.topCenter,
            message: statusString,
            child: NestedScrollView(
              floatHeaderSlivers: true,
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 15, left: 15, right: 15, bottom: 10),
                      child: SearchTextField(
                        controller: _controller,
                        hintText: "Search".tr(),
                        showCloseButton: false,
                        onChanged: (value) {
                          if (value.isEmpty) {
                            setState(() {
                              users = allUsers;
                            });
                          } else {
                            setState(() {
                              users = allUsers
                                  .where(
                                    (element) => element.name
                                        .toLowerCase()
                                        .contains(
                                            _controller?.text.toLowerCase() ??
                                                ""),
                                  )
                                  .toList();
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ];
              },
              body: phoneContacts.isNotEmpty
                  ? users.isNotEmpty
                      ? RefreshIndicator(
                          onRefresh: () => Future.sync(() => _getContacts()),
                          child: AnimationLimiter(
                            child: ListView.separated(
                              itemBuilder: (context, index) {
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  child: SlideAnimation(
                                    horizontalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: InkWell(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          if (widget.isAddingAdmin) {
                                            List<Member> updatedMembers = [];
                                            for (var member in members) {
                                              if (member.userId ==
                                                  nonAdminUsers[index].id) {
                                                Member updatedMember = Member(
                                                    user: member.user,
                                                    role: "admin",
                                                    invited: member.invited,
                                                    channelRole:
                                                        member.channelRole,
                                                    shadowBanned:
                                                        member.shadowBanned,
                                                    isModerator:
                                                        member.isModerator,
                                                    banExpires:
                                                        member.banExpires,
                                                    banned: member.banned,
                                                    createdAt: member.createdAt,
                                                    updatedAt: member.updatedAt,
                                                    userId: member.userId,
                                                    inviteAcceptedAt:
                                                        member.inviteAcceptedAt,
                                                    inviteRejectedAt: member
                                                        .inviteRejectedAt);
                                                updatedMembers
                                                    .add(updatedMember);
                                              } else {
                                                updatedMembers.add(member);
                                              }
                                            }
                                          } else {
                                            await widget.channel.addMembers(
                                              [nonMembersUsers[index].id],
                                              Message(
                                                text:
                                                    "${context.currentUser?.name} Added ${nonMembersUsers[index].name}",
                                              ),
                                            );
                                          }
                                          if (mounted) {
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10, bottom: 0),
                                          child: Column(
                                            children: [
                                              const SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    child: SizedBox(
                                                      height: 50,
                                                      width: 50,
                                                      child: CachedImage(
                                                        url: widget
                                                                .isAddingAdmin
                                                            ? nonAdminUsers[
                                                                        index]
                                                                    .image ??
                                                                ""
                                                            : nonMembersUsers[
                                                                        index]
                                                                    .image ??
                                                                "",
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 13),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        widget.isAddingAdmin
                                                            ? nonAdminUsers[
                                                                    index]
                                                                .name
                                                            : nonMembersUsers[
                                                                    index]
                                                                .name,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 3),
                                                    ],
                                                  ),
                                                  // if (_selectedUsers
                                                  //     .contains(users[index]))
                                                  //   const Expanded(
                                                  //     child: SizedBox(),
                                                  //   ),
                                                  // if (_selectedUsers
                                                  //     .contains(users[index]))
                                                  //   Padding(
                                                  //     padding:
                                                  //     const EdgeInsets.only(
                                                  //         right: 20),
                                                  //     child: Icon(
                                                  //       Icons.check_circle,
                                                  //       color: Theme.of(context)
                                                  //           .primaryColor,
                                                  //     ),
                                                  //   )
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return Divider(
                                  height: 0,
                                  color: Colors.grey.shade300,
                                );
                              },
                              itemCount: widget.isAddingAdmin
                                  ? nonAdminUsers.length
                                  : nonMembersUsers.length,
                            ),
                          ),
                        )
                      : ChannelsEmptyState(
                          animationController: _animationController,
                          title: "No Contacts Found".tr(),
                          message: "",
                        )
                  : _permissionDenied == false
                      ? const UltraLoadingIndicator()
                      : SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(height: 100),
                              SizedBox(
                                height: 200,
                                child: Lottie.asset(
                                  R.animations.contactsPermission,
                                  repeat: false,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "${"Contacts Permission is needed".tr()}\n${"To view your contacts".tr()}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () => AppSettings.openAppSettings(),
                                style: ElevatedButton.styleFrom(
                                  primary: Theme.of(context).primaryColor,
                                  elevation: 0,
                                  minimumSize: Size(
                                    MediaQuery.of(context).size.width / 2.5,
                                    50,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  "Go To Settings",
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500),
                                ).tr(),
                              )
                            ],
                          ),
                        ),
            ),
          );
        },
      ),
    );
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
      allUsers = users;
      phoneContacts = users.isNotEmpty ? [Contact()] : [];
      setState(() {});
    } else {
      if (!await FlutterContacts.requestPermission(readonly: true)) {
        setState(() => _permissionDenied = true);
      } else {
        List contacts = [];
        if (mounted) {
          contacts = await Utils.fetchContacts(context);
        }
        users = contacts.first;
        allUsers = users;
        phoneContacts = contacts[1];
        setState(() {});
      }
    }

    members = widget.channel.state?.members ?? [];
    membersUsers = members
        .map((e) => e.user ?? User(id: context.currentUser?.id ?? ""))
        .toList();
    admins = members
        .where((member) => member.role == "owner" || member.role == "admin")
        .toList();
    adminsUsers = admins
        .map((e) => e.user ?? User(id: context.currentUser?.id ?? ""))
        .toList();

    List<String> membersUsersIds = membersUsers.map((e) => e.id).toList();
    List<String> adminUsersIds = adminsUsers.map((e) => e.id).toList();
    List<String> usersIds = users.map((e) => e.id).toList();

    nonMembersUsers = [];
    for (var userId in usersIds) {
      if (!membersUsersIds.contains(userId)) {
        nonMembersUsers.add(users.firstWhere((user) => user.id == userId));
      }
    }

    nonAdminUsers = [];
    for (var userId in membersUsersIds) {
      if (!adminUsersIds.contains(userId)) {
        nonAdminUsers.add(users.firstWhere((user) => user.id == userId));
      }
    }
  }

  void _userNameListener() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 0), () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller?.clear();
    _controller?.removeListener(_userNameListener);
    _controller?.dispose();
    super.dispose();
  }
}
