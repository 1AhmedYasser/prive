import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Helpers/utils.dart';
import 'package:prive/Resources/animations.dart';
import 'package:prive/Resources/shared_pref.dart';
import 'package:prive/Widgets/ChatWidgets/typing_indicator.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:collection/collection.dart';

class ChannelItemWidget extends StatefulWidget {
  final Channel channel;
  final bool isForward;

  const ChannelItemWidget({
    Key? key,
    required this.channel,
    this.isForward = false,
  }) : super(key: key);

  @override
  State<ChannelItemWidget> createState() => _ChannelItemWidgetState();
}

class _ChannelItemWidgetState extends State<ChannelItemWidget> {
  List<User> users = [];
  List<String> usersPhoneNumbers = [];
  bool hasGroupCall = false;
  @override
  void initState() {
    if (widget.channel.isGroup) {
      checkForGroupCall();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 22, top: 30, left: 15, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  StreamChannelAvatar(
                    channel: widget.channel,
                    borderRadius: BorderRadius.circular(50),
                    constraints: const BoxConstraints(
                      minWidth: 65,
                      minHeight: 65,
                      maxWidth: 65,
                      maxHeight: 65,
                    ),
                  ),
                  if (widget.channel.isGroup && hasGroupCall)
                    Positioned(
                      bottom: -3,
                      right: -3,
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                        child: Lottie.asset(Animations.groupCallIndicator, repeat: true, reverse: true),
                      ),
                    )
                ],
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: BetterStreamBuilder<String>(
                            stream: widget.channel.nameStream,
                            initialData: widget.channel.name,
                            builder: (context, channelName) {
                              return Text(
                                channelName,
                                style: const TextStyle(color: Colors.black),
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                            noDataBuilder: (context) {
                              return FutureBuilder(
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const SizedBox.shrink();
                                  } else {
                                    return Text(
                                      snapshot.data as String? ?? '',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    );
                                  }
                                },
                                future: _getChannelName(),
                              );
                              // return LayoutBuilder(
                              //   builder: (context, constraints) {
                              //     String channelName = "";
                              //     if (widget.channel.isGroup) {
                              //       channelName = widget.channel.name ?? "";
                              //     } else {
                              //       final otherMember = widget
                              //           .channel.state!.members
                              //           .firstWhere(
                              //         (member) =>
                              //             member.userId !=
                              //             context.currentUser?.id,
                              //       );
                              //       _getContacts();
                              //       if (usersPhoneNumbers.contains(otherMember
                              //           .user?.extraData["phone"] as String?)) {
                              //         channelName =
                              //             otherMember.user?.name ?? "";
                              //       } else {
                              //         channelName = otherMember.user
                              //                 ?.extraData["phone"] as String? ??
                              //             "";
                              //       }
                              //     }
                              //
                              //     return Text(
                              //       channelName,
                              //       style: textStyle,
                              //       overflow: TextOverflow.ellipsis,
                              //     );
                              //   },
                              // );
                            },
                          ),
                        ),
                        if (!widget.isForward)
                          const SizedBox(
                            width: 10,
                          ),
                        if (!widget.isForward)
                          BetterStreamBuilder<DateTime>(
                            stream: widget.channel.lastMessageAtStream,
                            initialData: widget.channel.lastMessageAt,
                            builder: (context, data) {
                              return BetterStreamBuilder<int>(
                                stream: widget.channel.state!.unreadCountStream,
                                initialData: widget.channel.state?.unreadCount ?? 0,
                                builder: (context, count) {
                                  return Text(
                                    Utils.getLatestMessageDate(data),
                                    style: TextStyle(
                                      color: count > 0 ? Theme.of(context).primaryColorDark : Colors.black,
                                      fontWeight: count > 0 ? FontWeight.w500 : FontWeight.w400,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                      ],
                    ),
                    if (!widget.isForward)
                      const SizedBox(
                        height: 5,
                      ),
                    if (!widget.isForward)
                      BetterStreamBuilder<int>(
                        stream: widget.channel.state!.unreadCountStream,
                        initialData: widget.channel.state?.unreadCount ?? 0,
                        builder: (context, count) {
                          return BetterStreamBuilder<Message>(
                            stream: widget.channel.state!.lastMessageStream,
                            initialData: widget.channel.state!.lastMessage,
                            builder: (context, lastMessage) {
                              final lastMessage = widget.channel.state?.messages.lastWhereOrNull(
                                (m) => !m.isDeleted && !m.shadowed,
                              );
                              return Row(
                                children: [
                                  Expanded(
                                    child: TypingIndicatorWidget(
                                      alternativeWidget: Align(
                                        alignment: context.locale.languageCode == 'en'
                                            ? Alignment.centerLeft
                                            : Alignment.centerRight,
                                        child: Text(
                                          lastMessage?.text ?? '',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: count > 0 ? FontWeight.w500 : FontWeight.w400,
                                            color: count > 0 ? const Color(0xff1293a8) : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  if (count == 0)
                                    const SizedBox(
                                      height: 23,
                                    ),
                                  if (count > 0)
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: const Color(0xff53c662),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 8, right: 8, top: 3.5, bottom: 3.5),
                                          child: Text(
                                            '$count',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (lastMessage?.user?.id == context.currentUser?.id)
                                    Padding(
                                      padding: EdgeInsets.only(
                                        right: context.locale.languageCode == 'en' ? 18 : 0,
                                        left: context.locale.languageCode == 'en' ? 0 : 18,
                                      ),
                                      child: StreamChatTheme(
                                        data: StreamChatThemeData.fromTheme(
                                          ThemeData.from(
                                            colorScheme: const ColorScheme.dark(),
                                          ),
                                        ),
                                        child: StreamSendingIndicator(
                                          message: lastMessage ?? Message(),
                                          size: 22.5,
                                          isMessageRead: widget.channel.state!.read
                                              .where(
                                                (element) =>
                                                    element.user.id != widget.channel.client.state.currentUser!.id,
                                              )
                                              .where(
                                                (element) =>
                                                    element.lastRead.isAfter(lastMessage?.createdAt ?? DateTime.now()),
                                              )
                                              .isNotEmpty,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          );
                        },
                      )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String?> _getChannelName() async {
    if (widget.channel.isGroup) {
      return widget.channel.name ?? '';
    } else {
      final otherMember = widget.channel.state!.members.firstWhere(
        (member) => member.userId != context.currentUser?.id,
      );
      await _getContacts();
      if (usersPhoneNumbers.contains(otherMember.user?.extraData['phone'] as String?)) {
        return otherMember.user?.name ?? '';
      } else {
        return otherMember.user?.extraData['phone'] as String? ?? '';
      }
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

  void checkForGroupCall() async {
    final databaseReference = FirebaseDatabase.instance.ref('GroupCalls/${widget.channel.id}');

    final snapshot = await databaseReference.get();
    if (snapshot.exists) {
      setState(() {
        hasGroupCall = true;
      });
    } else {
      setState(() {
        hasGroupCall = false;
      });
    }
  }
}
