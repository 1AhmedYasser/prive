import 'dart:convert';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prive/Helpers/Utils.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Resources/shared_pref.dart';
import 'package:prive/Screens/Chat/Channels/channel_file_display_screen.dart';
import 'package:prive/Screens/Chat/Channels/channel_media_display_screen.dart';
import 'package:prive/Screens/Chat/Chat/pinned_messages_screen.dart';
import 'package:prive/UltraNetwork/ultra_loading_indicator.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// Detail screen for a 1:1 chat correspondence
class ChatInfoScreen extends StatefulWidget {
  /// User in consideration
  final User? user;

  final StreamMessageThemeData messageTheme;

  const ChatInfoScreen({
    Key? key,
    required this.messageTheme,
    this.user,
  }) : super(key: key);

  @override
  State<ChatInfoScreen> createState() => _ChatInfoScreenState();
}

class _ChatInfoScreenState extends State<ChatInfoScreen> {
  ValueNotifier<bool?> mutedBool = ValueNotifier(false);
  List<User> users = [];
  List<String> usersPhoneNumbers = [];
  bool userInContacts = true;

  @override
  void initState() {
    super.initState();
    mutedBool = ValueNotifier(StreamChannel.of(context).channel.isMuted);
  }

  @override
  Widget build(BuildContext context) {
    final channel = StreamChannel.of(context).channel;
    return Scaffold(
      backgroundColor: StreamChatTheme.of(context).colorTheme.appBg,
      body: ListView(
        children: [
          _buildUserHeader(),
          Container(
            height: 8.0,
            color: StreamChatTheme.of(context).colorTheme.disabled,
          ),
          _buildOptionListTiles(),
          Container(
            height: 8.0,
            color: StreamChatTheme.of(context).colorTheme.disabled,
          ),
          if ([
            'admin',
            'owner',
          ].contains(
            channel.state!.members
                .firstWhereOrNull((m) => m.userId == channel.client.state.currentUser!.id)
                ?.channelRole,
          ))
            _buildDeleteListTile(),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return Material(
      color: StreamChatTheme.of(context).colorTheme.appBg,
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: StreamUserAvatar(
                    user: widget.user!,
                    constraints: const BoxConstraints.tightFor(
                      width: 72.0,
                      height: 72.0,
                    ),
                    borderRadius: BorderRadius.circular(36.0),
                    showOnlineStatus: false,
                  ),
                ),
                FutureBuilder(
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    } else {
                      if (userInContacts) {
                        return Column(
                          children: [
                            Text(
                              snapshot.data as String? ?? '',
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 7.0),
                          ],
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }
                  },
                  future: _getUserName(widget.user!),
                ),
                Text(
                  widget.user!.extraData['phone'] as String? ?? '',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 7.0),
                _buildConnectedTitleState(),
                const SizedBox(height: 15.0),
                // OptionListTile(
                //   title: '@${widget.user!.id}',
                //   tileColor: StreamChatTheme.of(context).colorTheme.appBg,
                //   trailing: Padding(
                //     padding: const EdgeInsets.symmetric(horizontal: 8.0),
                //     child: Text(
                //       widget.user!.name,
                //       style: TextStyle(
                //           color: StreamChatTheme.of(context)
                //               .colorTheme
                //               .textHighEmphasis
                //               .withOpacity(0.5),
                //           fontSize: 16.0),
                //     ),
                //   ),
                //   onTap: () {},
                // ),
              ],
            ),
            const Positioned(
              top: 15,
              left: 0,
              width: 58,
              child: Padding(
                padding: EdgeInsets.only(left: 10),
                child: BackButton(
                  color: Color(0xff7a8ea6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionListTiles() {
    var channel = StreamChannel.of(context);

    return Column(
      children: [
        // _OptionListTile(
        //   title: 'Notifications',
        //   leading: StreamSvgIcon.Icon_notification(
        //     size: 24.0,
        //     color: StreamChatTheme.of(context).colorTheme.textHighEmphasis.withOpacity(0.5),
        //   ),
        //   trailing: CupertinoSwitch(
        //     value: true,
        //     onChanged: (val) {},
        //   ),
        //   onTap: () {},
        // ),
        StreamBuilder<bool>(
          stream: StreamChannel.of(context).channel.isMutedStream,
          builder: (context, snapshot) {
            mutedBool.value = snapshot.data;

            return StreamOptionListTile(
              tileColor: StreamChatTheme.of(context).colorTheme.appBg,
              title: 'Mute User'.tr(),
              titleTextStyle: StreamChatTheme.of(context).textTheme.body,
              leading: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22.0),
                child: StreamSvgIcon.mute(
                  size: 24.0,
                  color: StreamChatTheme.of(context).colorTheme.textHighEmphasis.withOpacity(0.5),
                ),
              ),
              trailing: snapshot.data == null
                  ? const UltraLoadingIndicator()
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
                      },
                    ),
              onTap: () {},
            );
          },
        ),
        // _OptionListTile(
        //   title: 'Block User',
        //   leading: StreamSvgIcon.Icon_user_delete(
        //     size: 24.0,
        //     color: StreamChatTheme.of(context).colorTheme.textHighEmphasis.withOpacity(0.5),
        //   ),
        //   trailing: CupertinoSwitch(
        //     value: widget.user.banned,
        //     onChanged: (val) {
        //       if (widget.user.banned) {
        //         channel.channel.shadowBan(widget.user.id, {});
        //       } else {
        //         channel.channel.unbanUser(widget.user.id);
        //       }
        //     },
        //   ),
        //   onTap: () {},
        // ),
        StreamOptionListTile(
          title: 'Pinned Messages'.tr(),
          tileColor: StreamChatTheme.of(context).colorTheme.appBg,
          titleTextStyle: StreamChatTheme.of(context).textTheme.body,
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22.0),
            child: StreamSvgIcon.pin(
              size: 24.0,
              color: StreamChatTheme.of(context).colorTheme.textHighEmphasis.withOpacity(0.5),
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
                  child: PinnedMessagesScreen(
                    messageTheme: widget.messageTheme,
                    sortOptions: const [
                      SortOption(
                        'created_at',
                        direction: SortOption.ASC,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        StreamOptionListTile(
          title: 'Photos & Videos'.tr(),
          tileColor: StreamChatTheme.of(context).colorTheme.appBg,
          titleTextStyle: StreamChatTheme.of(context).textTheme.body,
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: StreamSvgIcon.pictures(
              size: 36.0,
              color: StreamChatTheme.of(context).colorTheme.textHighEmphasis.withOpacity(0.5),
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
                  child: ChannelMediaDisplayScreen(
                    messageTheme: widget.messageTheme,
                    channel: channel,
                    sortOptions: const [
                      SortOption(
                        'created_at',
                        direction: SortOption.ASC,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        StreamOptionListTile(
          title: 'Files'.tr(),
          tileColor: StreamChatTheme.of(context).colorTheme.appBg,
          titleTextStyle: StreamChatTheme.of(context).textTheme.body,
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: StreamSvgIcon.files(
              size: 32.0,
              color: StreamChatTheme.of(context).colorTheme.textHighEmphasis.withOpacity(0.5),
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
                  child: const ChannelFileDisplayScreen(
                    sortOptions: [
                      SortOption(
                        'created_at',
                        direction: SortOption.ASC,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        // OptionListTile(
        //   title: "Shared Groups",
        //   tileColor: StreamChatTheme.of(context).colorTheme.appBg,
        //   titleTextStyle: StreamChatTheme.of(context).textTheme.body,
        //   leading: Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 22.0),
        //     child: StreamSvgIcon.iconGroup(
        //       size: 24.0,
        //       color: StreamChatTheme.of(context)
        //           .colorTheme
        //           .textHighEmphasis
        //           .withOpacity(0.5),
        //     ),
        //   ),
        //   trailing: StreamSvgIcon.right(
        //     color: StreamChatTheme.of(context).colorTheme.textLowEmphasis,
        //   ),
        //   onTap: () {
        //     Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //             builder: (context) => _SharedGroupsScreen(
        //                 StreamChat.of(context).currentUser, widget.user)));
        //   },
        // ),
      ],
    );
  }

  Widget _buildDeleteListTile() {
    return StreamOptionListTile(
      title: 'Delete Conversation'.tr(),
      tileColor: StreamChatTheme.of(context).colorTheme.appBg,
      titleTextStyle: StreamChatTheme.of(context).textTheme.body.copyWith(
            color: StreamChatTheme.of(context).colorTheme.accentError,
          ),
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22.0),
        child: StreamSvgIcon.delete(
          color: StreamChatTheme.of(context).colorTheme.accentError,
          size: 24.0,
        ),
      ),
      onTap: () {
        _showDeleteDialog();
      },
      titleColor: StreamChatTheme.of(context).colorTheme.accentError,
    );
  }

  void _showDeleteDialog() async {
    final res = await showConfirmationBottomSheet(
      context,
      title: 'Delete Conversation'.tr(),
      okText: 'Delete'.tr(),
      question: 'Are You Sure ?'.tr(),
      cancelText: 'Cancel'.tr(),
      icon: StreamSvgIcon.delete(
        color: StreamChatTheme.of(context).colorTheme.accentError,
      ),
    );
    if (mounted) {
      var channel = StreamChannel.of(context).channel;
      if (res == true) {
        await channel.delete().then((value) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        });
      }
    }
  }

  Widget _buildConnectedTitleState() {
    Text alternativeWidget = const Text('');

    final otherMember = widget.user;

    if (otherMember != null) {
      if (otherMember.online) {
        alternativeWidget = Text(
          'Online',
          style: TextStyle(color: StreamChatTheme.of(context).colorTheme.textHighEmphasis.withOpacity(0.5)),
        ).tr();
      } else {
        alternativeWidget = Text(
          '${"Last Seen".tr()} ${Jiffy(otherMember.lastActive).fromNow()}',
          style: TextStyle(color: StreamChatTheme.of(context).colorTheme.textHighEmphasis.withOpacity(0.5)),
        );
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.user!.online)
          Material(
            type: MaterialType.circle,
            color: StreamChatTheme.of(context).colorTheme.barsBg,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              constraints: const BoxConstraints.tightFor(
                width: 24,
                height: 12,
              ),
              child: Material(
                shape: const CircleBorder(),
                color: StreamChatTheme.of(context).colorTheme.accentInfo,
              ),
            ),
          ),
        alternativeWidget,
        if (widget.user!.online)
          const SizedBox(
            width: 24.0,
          ),
      ],
    );
  }

  Future<String?> _getUserName(User user) async {
    await _getContacts();
    if (usersPhoneNumbers.contains(user.extraData['phone'] as String?)) {
      userInContacts = true;
      return user.name;
    } else {
      userInContacts = false;
      return user.extraData['phone'] as String? ?? '';
    }
  }

  _getContacts() async {
    String? myContacts = await Utils.getString(SharedPref.myContacts);
    if (myContacts != null && myContacts.isNotEmpty == true) {
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
      usersPhoneNumbers = users
          .map(
            (e) => e.extraData['phone'] as String,
          )
          .toList();
      usersPhoneNumbers.add(context.currentUser?.extraData['phone'] as String);
    }
  }
}

class _SharedGroupsScreen extends StatefulWidget {
  final User? mainUser;
  final User? otherUser;

  const _SharedGroupsScreen(this.mainUser, this.otherUser);

  @override
  __SharedGroupsScreenState createState() => __SharedGroupsScreenState();
}

class __SharedGroupsScreenState extends State<_SharedGroupsScreen> {
  @override
  Widget build(BuildContext context) {
    var chat = StreamChat.of(context);

    return Scaffold(
      backgroundColor: StreamChatTheme.of(context).colorTheme.appBg,
      appBar: AppBar(
        elevation: 1,
        centerTitle: true,
        title: Text(
          'Shared Groups'.tr(),
          style: TextStyle(color: StreamChatTheme.of(context).colorTheme.textHighEmphasis, fontSize: 16.0),
        ),
        leading: const StreamBackButton(),
        backgroundColor: StreamChatTheme.of(context).colorTheme.barsBg,
      ),
      body: StreamBuilder<List<Channel>>(
        stream: chat.client.queryChannels(
          filter: Filter.and([
            Filter.in_('members', [widget.otherUser!.id]),
            Filter.in_('members', [widget.mainUser!.id]),
          ]),
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StreamSvgIcon.message(
                    size: 136.0,
                    color: StreamChatTheme.of(context).colorTheme.disabled,
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'No Shared Groups'.tr(),
                    style: TextStyle(
                      fontSize: 14.0,
                      color: StreamChatTheme.of(context).colorTheme.textHighEmphasis,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Groups Shared With User Appear Here'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: StreamChatTheme.of(context).colorTheme.textHighEmphasis.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          final channels = snapshot.data!
              .where(
                (c) =>
                    c.state!.members.any((m) => m.userId != widget.mainUser!.id && m.userId != widget.otherUser!.id) ||
                    !c.isDistinct,
              )
              .toList();

          return ListView.builder(
            itemCount: channels.length,
            itemBuilder: (context, position) {
              return StreamChannel(
                channel: channels[position],
                child: _buildListTile(channels[position]),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildListTile(Channel channel) {
    var extraData = channel.extraData;
    var members = channel.state!.members;

    var textStyle = const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold);

    return SizedBox(
      height: 64.0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          String? title;
          if (extraData['name'] == null) {
            final otherMembers = members.where((member) => member.userId != StreamChat.of(context).currentUser!.id);
            if (otherMembers.isNotEmpty) {
              final maxWidth = constraints.maxWidth;
              final maxChars = maxWidth / textStyle.fontSize!;
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
              title = 'No title';
            }
          } else {
            title = extraData['name'] as String;
          }

          return Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: StreamChannelAvatar(
                        channel: channel,
                        constraints: const BoxConstraints(maxWidth: 40.0, maxHeight: 40.0, minHeight: 40, minWidth: 40),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        title,
                        style: textStyle,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${channel.memberCount} ${channel.memberCount == 1 ? "Member".tr() : "Members".tr()}',
                        style:
                            TextStyle(color: StreamChatTheme.of(context).colorTheme.textHighEmphasis.withOpacity(0.5)),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 1.0,
                color: StreamChatTheme.of(context).colorTheme.textHighEmphasis.withOpacity(.08),
              ),
            ],
          );
        },
      ),
    );
  }
}
