import 'dart:async';
import 'dart:convert';

import 'package:app_settings/app_settings.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lottie/lottie.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Helpers/utils.dart';
import 'package:prive/Models/Chat/group_admin.dart';
import 'package:prive/Models/Chat/group_member.dart';
import 'package:prive/Resources/animations.dart';
import 'package:prive/Resources/shared_pref.dart';
import 'package:prive/UltraNetwork/ultra_loading_indicator.dart';
import 'package:prive/Widgets/AppWidgets/channels_empty_widgets.dart';
import 'package:prive/Widgets/ChatWidgets/search_text_field.dart';
import 'package:prive/Widgets/Common/cached_image.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

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

class _AddMembersAdminsScreenState extends State<AddMembersAdminsScreen> with TickerProviderStateMixin {
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
  List<GroupAdmin> groupAdmins = [];
  List<GroupMember> groupMembers = [];

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
              widget.isAddingAdmin ? 'Add Admin' : 'Add Member',
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
      body: StreamConnectionStatusBuilder(
        statusBuilder: (context, status) {
          String statusString = '';
          bool showStatus = true;

          switch (status) {
            case ConnectionStatus.connected:
              statusString = 'Connected'.tr();
              showStatus = false;
              break;
            case ConnectionStatus.connecting:
              statusString = 'Connecting'.tr();
              break;
            case ConnectionStatus.disconnected:
              statusString = 'Disconnected'.tr();
              break;
          }
          return StreamInfoTile(
            showMessage: showStatus,
            tileAnchor: Alignment.topCenter,
            childAnchor: Alignment.topCenter,
            message: statusString,
            child: NestedScrollView(
              floatHeaderSlivers: true,
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 10),
                      child: SearchTextField(
                        controller: _controller,
                        hintText: 'Search'.tr(),
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
                                    (element) =>
                                        element.name.toLowerCase().contains(_controller?.text.toLowerCase() ?? ''),
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
                                            BotToast.removeAll('loading');
                                            BotToast.showAnimationWidget(
                                              toastBuilder: (context) {
                                                return const IgnorePointer(child: UltraLoadingIndicator());
                                              },
                                              animationDuration: const Duration(milliseconds: 0),
                                              groupKey: 'loading',
                                            );
                                            List<Map<String, dynamic>> admins = [];
                                            GroupAdmin newAdmin = GroupAdmin(
                                              nonAdminUsers[index].id,
                                              nonAdminUsers[index].name,
                                              nonAdminUsers[index].image,
                                              'admin',
                                              AdminGroupPermissions(
                                                pinMessages: true,
                                                addAdmins: true,
                                                addMembers: true,
                                                changeGroupInfo: true,
                                                deleteMembers: true,
                                                deleteOthersMessages: true,
                                              ),
                                            );

                                            List<String?> groupAdminsIds = groupAdmins.map((e) => e.id).toList();

                                            if (groupAdminsIds.contains(newAdmin.id) == false) {
                                              groupAdmins.add(newAdmin);
                                              for (var admin in groupAdmins) {
                                                admins.add({
                                                  'id': admin.id,
                                                  'name': admin.name,
                                                  'image': admin.image,
                                                  'group_role': admin.groupRole,
                                                  'admin_permissions': {
                                                    'pin_messages': admin.groupPermissions?.pinMessages ?? true,
                                                    'add_members': admin.groupPermissions?.addMembers ?? true,
                                                    'add_admins': admin.groupPermissions?.addAdmins ?? true,
                                                    'change_group_info':
                                                        admin.groupPermissions?.changeGroupInfo ?? true,
                                                    'delete_others_messages':
                                                        admin.groupPermissions?.deleteOthersMessages ?? true,
                                                    'delete_members': admin.groupPermissions?.deleteMembers ?? true
                                                  },
                                                });
                                              }
                                              groupMembers.removeWhere((member) => member.id == newAdmin.id);
                                              updateMembers(context);
                                              widget.channel.updatePartial(set: {'group_admins': admins}).then((value) {
                                                if (mounted) {
                                                  Navigator.pop(context);
                                                }
                                                BotToast.removeAll('loading');
                                              });
                                            }
                                          } else {
                                            await widget.channel.addMembers(
                                              [nonMembersUsers[index].id],
                                              message: Message(
                                                text:
                                                    '${context.currentUser?.name} Added ${nonMembersUsers[index].name}',
                                              ),
                                            ).then((value) {
                                              if (mounted) {
                                                Navigator.pop(context);
                                              }
                                            });
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 0),
                                          child: Column(
                                            children: [
                                              const SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(50),
                                                    child: SizedBox(
                                                      height: 50,
                                                      width: 50,
                                                      child: CachedImage(
                                                        url: widget.isAddingAdmin
                                                            ? nonAdminUsers[index].image ?? ''
                                                            : nonMembersUsers[index].image ?? '',
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 13),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        widget.isAddingAdmin
                                                            ? nonAdminUsers[index].name
                                                            : nonMembersUsers[index].name,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w500,
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
                              itemCount: widget.isAddingAdmin ? nonAdminUsers.length : nonMembersUsers.length,
                            ),
                          ),
                        )
                      : ChannelsEmptyState(
                          animationController: _animationController,
                          title: 'No Contacts Found'.tr(),
                          message: '',
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
                                  Animations.contactsPermission,
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
                                  backgroundColor: Theme.of(context).primaryColor,
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
                                  'Go To Settings',
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
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
    String? myContacts = await Utils.getString(SharedPref.myContacts);
    if (myContacts != null && myContacts.isNotEmpty == true && myContacts != '[]') {
      List<dynamic> usersMapList = jsonDecode(await Utils.getString(SharedPref.myContacts) ?? '');
      List<User> myUsers = [];
      for (var user in usersMapList) {
        myUsers.add(
          User(
            id: user['id'],
            name: user['name'],
            image: user['image'],
            extraData: {'phone': user['phone'], 'shadow_banned': false},
          ),
        );
      }
      users = myUsers;
      allUsers = users;
      phoneContacts = users.isNotEmpty ? [Contact()] : [];
      setState(() {});
    } else {
      print('No Contacts found');
      if (!await FlutterContacts.requestPermission(readonly: true)) {
        setState(() => _permissionDenied = true);
      } else {
        List contacts = [];
        if (mounted) {
          contacts = await Utils.fetchContacts(context);
          print(users.length);
        }
        users = contacts.first;
        allUsers = users;
        phoneContacts = contacts[1];
        print(users.length);
        setState(() {});
      }
    }

    members = widget.channel.state?.members ?? [];
    membersUsers = members.map((e) => e.user ?? User(id: context.currentUser?.id ?? '')).toList();
    admins = members.where((member) => member.channelRole == 'owner' || member.channelRole == 'admin').toList();
    adminsUsers = admins.map((e) => e.user ?? User(id: context.currentUser?.id ?? '')).toList();

    List<String> membersUsersIds = membersUsers.map((e) => e.id).toList();
    List<String> usersIds = users.map((e) => e.id).toList();

    nonMembersUsers = [];
    for (var userId in usersIds) {
      if (!membersUsersIds.contains(userId)) {
        nonMembersUsers.add(users.firstWhere((user) => user.id == userId));
      }
    }

    nonAdminUsers = [];
    _getGroupAdmins();
    _getGroupMembers();
    List<String?> groupAdminsIds = groupAdmins.map((e) => e.id).toList();
    for (var userId in membersUsersIds) {
      if (!groupAdminsIds.contains(userId)) {
        User? user = users.firstWhereOrNull((user) => user.id == userId);
        if (user != null) {
          nonAdminUsers.add(user);
        }
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

  void _getGroupAdmins() {
    groupAdmins = [];
    List<dynamic>? admins = widget.channel.extraData['group_admins'] as List<dynamic>? ?? [];
    for (var admin in admins) {
      GroupAdmin groupAdmin = GroupAdmin.fromJson(admin as Map<String, dynamic>);
      groupAdmins.add(groupAdmin);
    }
    setState(() {});
  }

  void _getGroupMembers() {
    groupMembers = [];
    List<dynamic>? members = widget.channel.extraData['group_members'] as List<dynamic>? ?? [];
    for (var member in members) {
      GroupMember groupMember = GroupMember.fromJson(member as Map<String, dynamic>);
      groupMembers.add(groupMember);
    }
    setState(() {});
  }

  void updateMembers(BuildContext context, {bool goBackAfterUpdate = false}) {
    List<Map<String, dynamic>> members = [];
    for (var member in groupMembers) {
      members.add({
        'id': member.id,
        'name': member.name,
        'image': member.image,
        'group_role': member.groupRole,
        'members_permissions': {
          'send_messages': member.memberPermissions?.sendMessages ?? true,
          'send_photos': member.memberPermissions?.sendPhotos ?? true,
          'send_videos': member.memberPermissions?.sendVideos ?? true,
          'send_voice_records': member.memberPermissions?.sendVoiceRecords ?? true,
        },
      });
    }
    widget.channel.updatePartial(set: {'group_members': members}).then((value) {
      if (goBackAfterUpdate) {
        if (mounted) {
          Navigator.pop(context);
        }
      }
      BotToast.removeAll('loading');
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
