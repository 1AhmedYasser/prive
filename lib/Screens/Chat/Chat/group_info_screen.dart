import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prive/Screens/Chat/Channels/channel_file_display_screen.dart';
import 'package:prive/Screens/Chat/Channels/channel_media_display_screen.dart';
import 'package:prive/Screens/Chat/Chat/add_members_admins_screen.dart';
import 'package:prive/Screens/Chat/Chat/admins_screen.dart';
import 'package:prive/Screens/Chat/Chat/chat_screen.dart';
import 'package:prive/Screens/Chat/Chat/member_permissions_screen.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../../../Extras/resources.dart';
import '../../../Helpers/Utils.dart';
import '../../../Models/Chat/group_admin.dart';
import 'chat_info_screen.dart';
import 'pinned_messages_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prive/Helpers/stream_manager.dart';

class GroupInfoScreen extends StatefulWidget {
  final MessageThemeData messageTheme;
  final Channel channel;

  const GroupInfoScreen({
    Key? key,
    required this.messageTheme,
    required this.channel,
  }) : super(key: key);

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  final TextEditingController _nameController = TextEditingController();

  TextEditingController? _searchController;
  String _userNameQuery = '';

  Timer? _debounce;
  Function? modalSetStateCallback;
  List<User> users = [];
  List<String> usersPhoneNumbers = [];
  bool userInContacts = true;

  final FocusNode _focusNode = FocusNode();

  bool listExpanded = false;
  String userRole = "";

  // Members Permissions
  bool sendMessages = true;
  bool sendMedia = true;
  bool addMembers = true;

  // Admin Permissions
  bool pinMessages = true;
  bool adminAddMembers = true;
  bool addAdmins = true;
  bool changeGroupInfo = true;
  bool deleteOthersMessages = true;
  bool deleteMembers = true;
  List<GroupAdmin> groupAdmins = [];
  GroupAdmin? adminSelf;

  ValueNotifier<bool?> mutedBool = ValueNotifier(false);

  void _userNameListener() {
    if (_searchController!.text == _userNameQuery) {
      return;
    }
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted && modalSetStateCallback != null) {
        modalSetStateCallback!(() {
          _userNameQuery = _searchController!.text;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.channel.name ?? "";
    mutedBool = ValueNotifier(StreamChannel.of(context).channel.isMuted);
    _getMembersPermissions();
    _getGroupAdmins();
  }

  @override
  Widget build(BuildContext context) {
    var channel = StreamChannel.of(context);

    return StreamBuilder<List<Member>>(
        stream: channel.channel.state!.membersStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              color: StreamChatTheme.of(context).colorTheme.disabled,
              child: const Center(child: CircularProgressIndicator()),
            );
          }
          _getGroupAdmins();
          _getMembersPermissions();

          return Scaffold(
            backgroundColor: StreamChatTheme.of(context).colorTheme.appBg,
            appBar: AppBar(
              elevation: 1.0,
              toolbarHeight: 56.0,
              backgroundColor: StreamChatTheme.of(context).colorTheme.barsBg,
              leading: const StreamBackButton(),
              title: Column(
                children: [
                  StreamBuilder<ChannelState>(
                      stream: channel.channelStateStream,
                      builder: (context, state) {
                        if (!state.hasData) {
                          return Text(
                            "Loading",
                            style: TextStyle(
                              color: StreamChatTheme.of(context)
                                  .colorTheme
                                  .textHighEmphasis,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ).tr();
                        }

                        return Text(
                          _getChannelName(
                            2 * MediaQuery.of(context).size.width / 3,
                            members: snapshot.data,
                            extraData: state.data!.channel!.extraData,
                            maxFontSize: 16.0,
                          )!,
                          style: TextStyle(
                            color: StreamChatTheme.of(context)
                                .colorTheme
                                .textHighEmphasis,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      }),
                  const SizedBox(
                    height: 3.0,
                  ),
                  Text(
                    '${channel.channel.memberCount} ${channel.channel.memberCount == 1 ? "Member".tr() : "Members".tr()}, ${snapshot.data?.where((e) => e.user!.online).length ?? 0} ${"Online".tr()}',
                    style: TextStyle(
                      color: StreamChatTheme.of(context)
                          .colorTheme
                          .textHighEmphasis
                          .withOpacity(0.5),
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
              centerTitle: true,
            ),
            body: ListView(
              children: [
                _buildMembers(snapshot.data!),
                Container(
                  height: 8.0,
                  color: StreamChatTheme.of(context).colorTheme.disabled,
                ),
                _buildNameTile(),
                _buildOptionListTiles(),
              ],
            ),
          );
        });
  }

  Widget _buildMembers(List<Member> members) {
    final groupMembers = members
      ..sort((prev, curr) {
        if (curr.role == 'owner') return 1;
        return 0;
      });

    int groupMembersLength;

    if (listExpanded) {
      groupMembersLength = groupMembers.length;
    } else {
      groupMembersLength = groupMembers.length > 6 ? 6 : groupMembers.length;
    }

    List<String?> groupAdminsIds = groupAdmins.map((e) => e.id).toList();

    return Column(
      children: [
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
                  _showUserInfoModal(member.user, userMember?.role == 'owner');
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
                                      : groupAdminsIds.contains(member.userId)
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
            onTap: () {
              setState(() {
                listExpanded = true;
              });
            },
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

  Widget _buildOptionListTiles() {
    var channel = StreamChannel.of(context);
    return Column(
      children: [
        if (userRole == "owner" ||
            (userRole == "admin" &&
                adminSelf?.groupPermissions?.addMembers == true) ||
            (userRole == "member" && addMembers == true))
          StreamOptionListTile(
            tileColor: StreamChatTheme.of(context).colorTheme.appBg,
            separatorColor: StreamChatTheme.of(context).colorTheme.disabled,
            title: "Add Members".tr(),
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
                  ),
                ),
              );
            },
          ),
        StreamBuilder<bool>(
            stream: StreamChannel.of(context).channel.isMutedStream,
            builder: (context, snapshot) {
              mutedBool.value = snapshot.data;

              return StreamOptionListTile(
                tileColor: StreamChatTheme.of(context).colorTheme.appBg,
                separatorColor: StreamChatTheme.of(context).colorTheme.disabled,
                title: "Mute Group".tr(),
                titleTextStyle: StreamChatTheme.of(context).textTheme.body,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: StreamSvgIcon.mute(
                    size: 24.0,
                    color: StreamChatTheme.of(context)
                        .colorTheme
                        .textHighEmphasis
                        .withOpacity(0.5),
                  ),
                ),
                trailing: snapshot.data == null
                    ? const CircularProgressIndicator()
                    : ValueListenableBuilder<bool?>(
                        valueListenable: mutedBool,
                        builder: (context, value, _) {
                          return CupertinoSwitch(
                            value: value!,
                            onChanged: (val) {
                              mutedBool.value = val;

                              if (snapshot.data!) {
                                channel.channel.unmute();
                              } else {
                                channel.channel.mute();
                              }
                            },
                          );
                        }),
                onTap: () {},
              );
            }),
        StreamOptionListTile(
          title: "Pinned Messages".tr(),
          tileColor: StreamChatTheme.of(context).colorTheme.appBg,
          titleTextStyle: StreamChatTheme.of(context).textTheme.body,
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: StreamSvgIcon.pin(
              size: 24.0,
              color: StreamChatTheme.of(context)
                  .colorTheme
                  .textHighEmphasis
                  .withOpacity(0.5),
            ),
          ),
          trailing: StreamSvgIcon.right(
            color: StreamChatTheme.of(context).colorTheme.textLowEmphasis,
          ),
          onTap: () {
            final channel = StreamChannel.of(context).channel;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StreamChannel(
                  channel: channel,
                  child: MessageSearchBloc(
                    child: PinnedMessagesScreen(
                      messageTheme: widget.messageTheme,
                      sortOptions: const [
                        SortOption(
                          'created_at',
                          direction: SortOption.ASC,
                        ),
                      ],
                      onShowMessage: (m, c) async {
                        // final client = StreamChat.of(context).client;
                        // final message = m;
                        // final channel = client.channel(
                        //   c.type,
                        //   id: c.id,
                        // );
                        // if (channel.state == null) {
                        //   await channel.watch();
                        // }
                        // Navigator.pushNamed(
                        //   context,
                        //   Routes.CHANNEL_PAGE,
                        //   arguments: ChannelPageArgs(
                        //     channel: channel,
                        //     initialMessage: message,
                        //   ),
                        // );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        StreamOptionListTile(
          tileColor: StreamChatTheme.of(context).colorTheme.appBg,
          separatorColor: StreamChatTheme.of(context).colorTheme.disabled,
          title: "Photo & Videos".tr(),
          titleTextStyle: StreamChatTheme.of(context).textTheme.body,
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: StreamSvgIcon.pictures(
              size: 32.0,
              color: StreamChatTheme.of(context)
                  .colorTheme
                  .textHighEmphasis
                  .withOpacity(0.5),
            ),
          ),
          trailing: StreamSvgIcon.right(
            color: StreamChatTheme.of(context).colorTheme.textLowEmphasis,
          ),
          onTap: () {
            var channel = StreamChannel.of(context).channel;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StreamChannel(
                  channel: channel,
                  child: MessageSearchBloc(
                    child: ChannelMediaDisplayScreen(
                      messageTheme: widget.messageTheme,
                      sortOptions: const [
                        SortOption(
                          'created_at',
                          direction: SortOption.ASC,
                        ),
                      ],
                      paginationParams: const PaginationParams(limit: 20),
                      onShowMessage: (m, c) async {
                        // final client = StreamChat.of(context).client;
                        // final message = m;
                        // final channel = client.channel(
                        //   c.type,
                        //   id: c.id,
                        // );
                        // if (channel.state == null) {
                        //   await channel.watch();
                        // }
                        // await Navigator.pushNamed(
                        //   context,
                        //   Routes.CHANNEL_PAGE,
                        //   arguments: ChannelPageArgs(
                        //     channel: channel,
                        //     initialMessage: message,
                        //   ),
                        // );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        StreamOptionListTile(
          tileColor: StreamChatTheme.of(context).colorTheme.appBg,
          separatorColor: StreamChatTheme.of(context).colorTheme.disabled,
          title: "Files".tr(),
          titleTextStyle: StreamChatTheme.of(context).textTheme.body,
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: StreamSvgIcon.files(
              size: 32.0,
              color: StreamChatTheme.of(context)
                  .colorTheme
                  .textHighEmphasis
                  .withOpacity(0.5),
            ),
          ),
          trailing: StreamSvgIcon.right(
            color: StreamChatTheme.of(context).colorTheme.textLowEmphasis,
          ),
          onTap: () {
            var channel = StreamChannel.of(context).channel;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StreamChannel(
                  channel: channel,
                  child: const MessageSearchBloc(
                    child: ChannelFileDisplayScreen(
                      sortOptions: [
                        SortOption(
                          'created_at',
                          direction: SortOption.ASC,
                        ),
                      ],
                      paginationParams: PaginationParams(limit: 20),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (userRole == "owner" || userRole == "admin")
          StreamOptionListTile(
            tileColor: StreamChatTheme.of(context).colorTheme.appBg,
            separatorColor: StreamChatTheme.of(context).colorTheme.disabled,
            title: "Permissions".tr(),
            titleTextStyle: StreamChatTheme.of(context).textTheme.body,
            leading: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Icon(
                Icons.vpn_key_rounded,
                color: StreamChatTheme.of(context)
                    .colorTheme
                    .textHighEmphasis
                    .withOpacity(0.5),
              ),
            ),
            trailing: StreamSvgIcon.right(
              color: StreamChatTheme.of(context).colorTheme.textLowEmphasis,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MemberPermissionsScreen(
                    channel: widget.channel,
                  ),
                ),
              ).then((value) => _getMembersPermissions());
            },
          ),
        if (userRole == "owner" || userRole == "admin")
          StreamOptionListTile(
            tileColor: StreamChatTheme.of(context).colorTheme.appBg,
            separatorColor: StreamChatTheme.of(context).colorTheme.disabled,
            title: "Administrators".tr(),
            titleTextStyle: StreamChatTheme.of(context).textTheme.body,
            leading: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Icon(
                Icons.admin_panel_settings,
                color: StreamChatTheme.of(context)
                    .colorTheme
                    .textHighEmphasis
                    .withOpacity(0.5),
              ),
            ),
            trailing: StreamSvgIcon.right(
              color: StreamChatTheme.of(context).colorTheme.textLowEmphasis,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminsScreen(
                    channel: widget.channel,
                  ),
                ),
              ).then((value) => _getGroupAdmins());
            },
          ),
        if (!channel.channel.isDistinct)
          StreamOptionListTile(
            tileColor: StreamChatTheme.of(context).colorTheme.appBg,
            separatorColor: StreamChatTheme.of(context).colorTheme.disabled,
            title: "Leave Group".tr(),
            titleTextStyle: StreamChatTheme.of(context).textTheme.body,
            leading: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(
                Icons.exit_to_app_rounded,
                color: StreamChatTheme.of(context)
                    .colorTheme
                    .textHighEmphasis
                    .withOpacity(0.5),
              ),
            ),
            trailing: const SizedBox(
              height: 24.0,
              width: 24.0,
            ),
            onTap: () async {
              final res = await showConfirmationDialog(
                context,
                title: "Leave Group".tr(),
                okText: "Leave".tr(),
                question: "Are You Sure ?".tr(),
                cancelText: "Cancel".tr(),
                icon: Icon(
                  Icons.exit_to_app_rounded,
                  color: StreamChatTheme.of(context)
                      .colorTheme
                      .textHighEmphasis
                      .withOpacity(0.5),
                ),
              );
              if (res == true) {
                if (mounted) {
                  final channel = StreamChannel.of(context).channel;
                  await channel
                      .removeMembers([StreamChat.of(context).currentUser!.id]);
                  if (mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                }
              }
            },
          ),
        if (userRole == "owner")
          StreamOptionListTile(
            tileColor: StreamChatTheme.of(context).colorTheme.appBg,
            separatorColor: StreamChatTheme.of(context).colorTheme.disabled,
            title: "Delete Group".tr(),
            titleTextStyle: StreamChatTheme.of(context).textTheme.body,
            leading: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Icon(
                Icons.delete_forever,
                color: StreamChatTheme.of(context)
                    .colorTheme
                    .textHighEmphasis
                    .withOpacity(0.5),
              ),
            ),
            onTap: () async {
              final res = await showConfirmationDialog(
                context,
                title: "Delete Group".tr(),
                okText: "Delete".tr(),
                question: "Are You Sure ?".tr(),
                cancelText: "Cancel".tr(),
                icon: Icon(
                  Icons.delete_forever,
                  color: StreamChatTheme.of(context)
                      .colorTheme
                      .textHighEmphasis
                      .withOpacity(0.5),
                ),
              );
              if (res == true) {
                if (mounted) {
                  final channel = StreamChannel.of(context).channel;
                  await channel.delete();
                  if (mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                }
              }
            },
          ),
      ],
    );
  }

  void _buildAddUserModal(context) {
    var channel = StreamChannel.of(context).channel;

    showDialog(
      useRootNavigator: false,
      context: context,
      barrierColor: StreamChatTheme.of(context).colorTheme.overlay,
      builder: (context) {
        return StatefulBuilder(builder: (context, modalSetState) {
          modalSetStateCallback = modalSetState;
          return Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
            child: Material(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
              clipBehavior: Clip.antiAlias,
              child: Scaffold(
                body: UsersBloc(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildTextInputSection(modalSetState),
                      ),
                      Expanded(
                        child: UserListView(
                          selectedUsers: const {},
                          onUserTap: (user, _) async {
                            _searchController!.clear();

                            await channel.addMembers([user.id]);
                            if (mounted) {
                              Navigator.pop(context);
                            }
                            setState(() {});
                          },
                          crossAxisCount: 4,
                          limit: 25,
                          filter: Filter.and(
                            [
                              if (_searchController!.text.isNotEmpty)
                                Filter.autoComplete('name', _userNameQuery),
                              Filter.notIn(
                                'id',
                                [
                                  StreamChat.of(context).currentUser!.id,
                                  ...channel.state!.members
                                      .map<String?>(
                                        ((e) => e.userId),
                                      )
                                      .whereType<String>(),
                                ],
                              ),
                              Filter.notEqual("role", "admin"),
                            ],
                          ),
                          sort: const [
                            SortOption(
                              'name',
                              direction: 1,
                            ),
                          ],
                          emptyBuilder: (_) {
                            return LayoutBuilder(
                              builder: (context, viewportConstraints) {
                                return SingleChildScrollView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: viewportConstraints.maxHeight,
                                    ),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(24),
                                            child: StreamSvgIcon.search(
                                              size: 96,
                                              color: StreamChatTheme.of(context)
                                                  .colorTheme
                                                  .textLowEmphasis,
                                            ),
                                          ),
                                          const Text(
                                                  "No User Match this keyword")
                                              .tr(),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildTextInputSection(modalSetState) {
    final theme = StreamChatTheme.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(
                height: 36,
                child: TextField(
                  controller: _searchController,
                  cursorColor: theme.colorTheme.textHighEmphasis,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "Search".tr(),
                    hintStyle: theme.textTheme.body.copyWith(
                      color: theme.colorTheme.textLowEmphasis,
                    ),
                    prefixIconConstraints:
                        BoxConstraints.tight(const Size(40, 24)),
                    prefixIcon: StreamSvgIcon.search(
                      color: theme.colorTheme.textHighEmphasis,
                      size: 24,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      borderSide: BorderSide(
                        color: theme.colorTheme.borders,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        borderSide: BorderSide(
                          color: theme.colorTheme.borders,
                        )),
                    contentPadding: const EdgeInsets.all(0),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            IconButton(
              icon: StreamSvgIcon.closeSmall(
                color: theme.colorTheme.textLowEmphasis,
              ),
              constraints: const BoxConstraints.tightFor(
                height: 24,
                width: 24,
              ),
              padding: EdgeInsets.zero,
              splashRadius: 24,
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      ],
    );
  }

  void _showUserInfoModal(User? user, bool isUserAdmin) {
    var channel = StreamChannel.of(context).channel;
    final color = StreamChatTheme.of(context).colorTheme.barsBg;

    showModalBottomSheet(
      useRootNavigator: false,
      context: context,
      clipBehavior: Clip.antiAlias,
      isScrollControlled: true,
      backgroundColor: color,
      builder: (context) {
        return SafeArea(
          child: StreamChannel(
            channel: channel,
            child: Material(
              color: color,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 24.0,
                  ),
                  Center(
                    child: Text(
                      user!.name,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  _buildConnectedTitleState(user)!,
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: StreamUserAvatar(
                        user: user,
                        constraints: const BoxConstraints.tightFor(
                          height: 64.0,
                          width: 64.0,
                        ),
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                    ),
                  ),
                  // if (StreamChat.of(context).currentUser!.id != user.id)
                  // _buildModalListTile(
                  //   context,
                  //   StreamSvgIcon.user(
                  //     color: StreamChatTheme.of(context)
                  //         .colorTheme
                  //         .textLowEmphasis,
                  //     size: 24.0,
                  //   ),
                  //   "View Info".tr(),
                  //   () async {
                  //     var client = StreamChat.of(context).client;
                  //
                  //     var c = client.channel('messaging', extraData: {
                  //       'members': [
                  //         user.id,
                  //         StreamChat.of(context).currentUser!.id,
                  //       ],
                  //     });
                  //
                  //     await c.watch();
                  //
                  //     if (mounted) {
                  //       await Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (context) => StreamChannel(
                  //             channel: c,
                  //             child: ChatInfoScreen(
                  //               messageTheme: widget.messageTheme,
                  //               user: user,
                  //             ),
                  //           ),
                  //         ),
                  //       );
                  //     }
                  //   },
                  // ),
                  if (StreamChat.of(context).currentUser!.id != user.id)
                    _buildModalListTile(
                      context,
                      StreamSvgIcon.message(
                        color: StreamChatTheme.of(context)
                            .colorTheme
                            .textLowEmphasis,
                        size: 24.0,
                      ),
                      "Message".tr(),
                      () async {
                        var client = StreamChat.of(context).client;

                        var c = client.channel('messaging', extraData: {
                          'members': [
                            user.id,
                            StreamChat.of(context).currentUser!.id,
                          ],
                        });

                        await c.watch();

                        if (mounted) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StreamChannel(
                                channel: c,
                                child: ChatScreen(
                                  channel: c,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  // if (!channel.isDistinct &&
                  //     StreamChat.of(context).user!.id != user.id &&
                  //     isUserAdmin)
                  //   _buildModalListTile(
                  //       context,
                  //       StreamSvgIcon.iconUserSettings(
                  //         color: StreamChatTheme.of(context).colorTheme.textLowEmphasis,
                  //         size: 24.0,
                  //       ),
                  //       'Make Owner', () {
                  //     // TODO: Add make owner implementation (Remaining from backend)
                  //   }),
                  if (!channel.isDistinct &&
                          StreamChat.of(context).currentUser!.id != user.id &&
                          isUserAdmin ||
                      (adminSelf?.groupPermissions?.deleteMembers == true &&
                          StreamChat.of(context).currentUser!.id != user.id))
                    _buildModalListTile(
                        context,
                        StreamSvgIcon.userRemove(
                          color: StreamChatTheme.of(context)
                              .colorTheme
                              .accentError,
                          size: 24.0,
                        ),
                        "Remove From Group".tr(), () async {
                      final res = await showConfirmationDialog(
                        context,
                        title: "Remove Member".tr(),
                        okText: "Remove".tr(),
                        question: "Are You Sure ?".tr(),
                        cancelText: "Cancel".tr(),
                      );

                      if (res == true) {
                        await channel.removeMembers(
                          [user.id],
                          Message(
                            text:
                                "${context.currentUser?.name} Removed ${user.name}",
                          ),
                        );
                      }
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
                        color:
                            StreamChatTheme.of(context).colorTheme.accentError),
                  _buildModalListTile(
                      context,
                      StreamSvgIcon.closeSmall(
                        color: StreamChatTheme.of(context)
                            .colorTheme
                            .textLowEmphasis,
                        size: 24.0,
                      ),
                      "Cancel".tr(), () {
                    Navigator.pop(context);
                  }),
                ],
              ),
            ),
          ),
        );
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
    );
  }

  Widget? _buildConnectedTitleState(User? user) {
    var alternativeWidget;

    final otherMember = user;

    if (otherMember != null) {
      if (otherMember.online) {
        alternativeWidget = Text(
          "Online".tr(),
          style: TextStyle(
              color: StreamChatTheme.of(context)
                  .colorTheme
                  .textHighEmphasis
                  .withOpacity(0.5)),
        );
      } else {
        alternativeWidget = Text(
          '${"Last Seen".tr()} ${Jiffy(otherMember.lastActive).fromNow()}',
          style: TextStyle(
            color: StreamChatTheme.of(context)
                .colorTheme
                .textHighEmphasis
                .withOpacity(0.5),
          ),
        );
      }
    }

    return alternativeWidget;
  }

  Widget _buildModalListTile(
      BuildContext context, Widget leading, String title, VoidCallback onTap,
      {Color? color}) {
    color ??= StreamChatTheme.of(context).colorTheme.textHighEmphasis;

    return Material(
      color: StreamChatTheme.of(context).colorTheme.barsBg,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              height: 1.0,
              color: StreamChatTheme.of(context).colorTheme.disabled,
            ),
            SizedBox(
              height: 64.0,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: leading,
                  ),
                  Expanded(
                    child: Text(
                      title,
                      style:
                          TextStyle(color: color, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
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

  String? _getChannelName(
    double width, {
    List<Member>? members,
    required Map extraData,
    double? maxFontSize,
  }) {
    String? title;
    var client = StreamChat.of(context);
    if (extraData['name'] == null) {
      final otherMembers =
          members!.where((member) => member.user!.id != client.currentUser!.id);
      if (otherMembers.isNotEmpty) {
        final maxWidth = width;
        final maxChars = maxWidth / maxFontSize!;
        var currentChars = 0;
        final currentMembers = <Member>[];
        for (var element in otherMembers) {
          final newLength = currentChars + element.user!.name.length;
          if (newLength < maxChars) {
            currentChars = newLength;
            currentMembers.add(element);
          }
        }

        final exceedingMembers = otherMembers.length - currentMembers.length;
        title =
            '${currentMembers.map((e) => e.user!.name).join(', ')} ${exceedingMembers > 0 ? '+ $exceedingMembers' : ''}';
      } else {
        title = "No Title".tr();
      }
    } else {
      title = extraData['name'];
    }
    return title;
  }

  String _getLastSeen(User user) {
    if (user.online) {
      return "Online".tr();
    } else {
      return '${"Last Seen".tr()} ${Jiffy(user.lastActive).fromNow()}';
    }
  }

  Widget _buildNameTile() {
    return Material(
      color: StreamChatTheme.of(context).colorTheme.appBg,
      child: Container(
        height: 56.0,
        alignment: Alignment.center,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(
                FontAwesomeIcons.tag,
                color: StreamChatTheme.of(context)
                    .colorTheme
                    .textHighEmphasis
                    .withOpacity(0.5),
              ),
            ),
            Expanded(
              child: TextField(
                focusNode: _focusNode,
                enabled: adminSelf?.groupPermissions?.changeGroupInfo == true,
                controller: _nameController,
                cursorColor:
                    StreamChatTheme.of(context).colorTheme.textHighEmphasis,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration.collapsed(
                    hintText: "Add A Group Name",
                    hintStyle: StreamChatTheme.of(context)
                        .textTheme
                        .bodyBold
                        .copyWith(
                            color: StreamChatTheme.of(context)
                                .colorTheme
                                .textHighEmphasis
                                .withOpacity(0.5))),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  height: 0.82,
                ),
              ),
            ),
            if (_focusNode.hasFocus)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    child: StreamSvgIcon.closeSmall(),
                    onTap: () {
                      setState(() {
                        _nameController.text = widget.channel.name ?? "";
                        _focusNode.unfocus();
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0, left: 8.0),
                    child: InkWell(
                      child: StreamSvgIcon.check(
                        color: StreamChatTheme.of(context)
                            .colorTheme
                            .accentPrimary,
                        size: 24.0,
                      ),
                      onTap: () {
                        widget.channel.updatePartial(set: {
                          "name": _nameController.text.trim()
                        }).then((value) {
                          setState(() {
                            _nameController.text = widget.channel.name ?? "";
                            _focusNode.unfocus();
                          });
                        });
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
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

    adminSelf = groupAdmins
        .firstWhereOrNull((admin) => admin.id == context.currentUser?.id);

    if (adminSelf != null) {
      _getAdminPermissions(adminSelf);
    }

    userRole = groupAdmins
            .firstWhereOrNull(
              (admin) => admin.id == context.currentUser?.id,
            )
            ?.groupRole ??
        "member";
  }

  void _getMembersPermissions() {
    Map<String, dynamic>? membersPermissions = widget.channel
            .extraData['members_permissions'] as Map<String, dynamic>? ??
        {};
    sendMessages = membersPermissions['send_messages'] as bool? ?? true;
    sendMedia = membersPermissions['send_media'] as bool? ?? true;
    addMembers = membersPermissions['add_members'] as bool? ?? true;
  }

  void _getAdminPermissions(GroupAdmin? admin) {
    AdminGroupPermissions? permissions = admin?.groupPermissions;
    pinMessages = permissions?.pinMessages ?? true;
    addMembers = permissions?.addMembers ?? true;
    addAdmins = permissions?.addAdmins ?? true;
    changeGroupInfo = permissions?.changeGroupInfo ?? true;
    deleteOthersMessages = permissions?.deleteOthersMessages ?? true;
    deleteMembers = permissions?.deleteMembers ?? true;
  }
}
