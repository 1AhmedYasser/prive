import 'dart:async';
import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Widgets/ChatWidgets/chat_list_widget.dart';
import 'package:prive/Widgets/ChatWidgets/chat_send_widget.dart';
import 'package:prive/Widgets/ChatWidgets/connection_status_builder.dart';
import 'package:prive/Widgets/ChatWidgets/typing_indicator.dart';
import 'package:prive/Widgets/Common/cached_image.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';

class ChatScreen extends StatefulWidget {
  static Route routeWithChannel(Channel channel) => MaterialPageRoute(
        builder: (context) => StreamChannel(
          channel: channel,
          child: const ChatScreen(),
        ),
      );

  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late StreamSubscription<int> unreadCountSubscription;
  TextEditingController messageController = TextEditingController();
  FocusNode messageFocus = FocusNode();
  final ScrollController _chatScrollController = ScrollController();
  List<Map> chatMoreMenu = [];
  List<String> chatMoreMenuTitles = [
    "Search",
    "Clear History",
    "Mute Notifications",
    "Delete Chat"
  ];

  @override
  void initState() {
    super.initState();

    for (var i = 0; i < chatMoreMenuTitles.length; i++) {
      chatMoreMenu.add({
        'label': chatMoreMenuTitles[i],
        'value': chatMoreMenuTitles[i],
        'icon': SizedBox(
          height: 25,
          width: 25,
          child: Image.asset(
            R.images.chatMoreImage,
            width: 22,
          ),
        ),
      });
    }

    unreadCountSubscription = StreamChannel.of(context)
        .channel
        .state!
        .unreadCountStream
        .listen(_unreadCountHandler);
  }

  @override
  Widget build(BuildContext context) {
    final channel = StreamChannel.of(context).channel;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: AppBar(
          toolbarHeight: 90,
          centerTitle: false,
          backgroundColor: Colors.white,
          elevation: 0,
          leadingWidth: 40,
          leading: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: BackButton(
              color: Color(0xff7a8ea6),
            ),
          ),
          title: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CircleAvatar(
                  child: CachedImage(
                    url: StreamManager.getChannelImage(
                          channel,
                          context.currentUser!,
                        ) ??
                        "",
                  ),
                  radius: 27,
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      StreamManager.getChannelName(
                        channel,
                        context.currentUser!,
                      ),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, color: Colors.black),
                    ),
                    const SizedBox(height: 2),
                    BetterStreamBuilder<List<Member>>(
                      stream: channel.state!.membersStream,
                      initialData: channel.state!.members,
                      builder: (context, data) => ConnectionStatusBuilder(
                        statusBuilder: (context, status) {
                          switch (status) {
                            case ConnectionStatus.connected:
                              return _buildConnectedTitleState(context, data);
                            case ConnectionStatus.connecting:
                              return const Text(
                                'Connecting',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              );
                            case ConnectionStatus.disconnected:
                              return const Text(
                                'Offline',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              );
                            default:
                              return const SizedBox.shrink();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          actions: [
            GestureDetector(
              onTap: () {},
              child: Image.asset(
                R.images.videoCallImage,
                width: 25,
              ),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: () {},
              child: Image.asset(
                R.images.voiceCallImage,
                width: 22,
              ),
            ),
            const SizedBox(width: 20),
            CoolDropdown(
              dropdownList: chatMoreMenu,
              dropdownItemPadding: EdgeInsets.zero,
              onChange: (dropdownItem) {},
              resultHeight: 62,
              resultWidth: 30,
              dropdownWidth: 80,
              dropdownHeight: 180,
              dropdownItemHeight: 30,
              dropdownItemGap: 10,
              resultIcon: SizedBox(
                width: 21,
                height: 21,
                child: Image.asset(
                  R.images.chatMoreImage,
                ),
              ),
              resultBD: const BoxDecoration(color: Colors.transparent),
              resultIconLeftGap: 0,
              dropdownItemBottomGap: 0,
              resultPadding: EdgeInsets.zero,
              resultIconRotation: true,
              resultIconRotationValue: 1,
              isDropdownLabel: false,
              isResultLabel: false,
              isResultIconLabel: false,
              dropdownPadding: const EdgeInsets.all(20),
              isTriangle: false,
              selectedItemPadding: EdgeInsets.zero,
              resultAlign: Alignment.center,
              resultMainAxis: MainAxisAlignment.center,
              selectedItemBD: const BoxDecoration(color: Colors.transparent),
              triangleWidth: 0,
              triangleHeight: 0,
              triangleAlign: 'center',
              dropdownAlign: 'center',
              gap: 20,
            ),
            const SizedBox(width: 20),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: MessageListCore(
              loadingBuilder: (context) {
                return const Center(child: CircularProgressIndicator());
              },
              emptyBuilder: (context) => const SizedBox.shrink(),
              errorBuilder: (context, error) => Container(),
              messageListBuilder: (context, messages) {
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(R.images.chatBackground1),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: ChatListWidget(
                    messages: messages,
                    messageFocus: messageFocus,
                    chatScrollController: _chatScrollController,
                  ),
                );
              },
            ),
          ),
          ChatSendWidget(
            messageController: messageController,
            messageFocus: messageFocus,
            chatScrollController: _chatScrollController,
          ),
        ],
      ),
    );
  }

  Future<void> _unreadCountHandler(int count) async {
    if (count > 0) {
      await StreamChannel.of(context).channel.markRead();
    }
  }

  Widget _buildConnectedTitleState(
    BuildContext context,
    List<Member>? members,
  ) {
    Widget? alternativeWidget;
    final channel = StreamChannel.of(context).channel;
    final memberCount = channel.memberCount;
    if (memberCount != null && memberCount > 2) {
      var text = 'Members: $memberCount';
      final watcherCount = channel.state?.watcherCount ?? 0;
      if (watcherCount > 0) {
        text = 'watchers $watcherCount';
      }
      alternativeWidget = Text(
        text,
      );
    } else {
      final userId = StreamChatCore.of(context).currentUser?.id;
      final otherMember = members?.firstWhereOrNull(
        (element) => element.userId != userId,
      );

      if (otherMember != null) {
        if (otherMember.user?.online == true) {
          alternativeWidget = const Text(
            'Online',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.green,
            ),
          );
        } else {
          alternativeWidget = Text(
            getLastSeenDate(
                otherMember.user?.lastActive?.toLocal() ?? DateTime.now()),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          );
        }
      }
    }

    return TypingIndicator(
      alternativeWidget: alternativeWidget,
    );
  }

  String getLastSeenDate(DateTime data) {
    String lastSeen = "last seen ";
    final now = DateTime.now();
    DateTime lastSeenDate = data.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    final lastSeenDateFormatted =
        DateTime(lastSeenDate.year, lastSeenDate.month, lastSeenDate.day);

    if (lastSeenDateFormatted == today) {
      lastSeen += "today at ${DateFormat('hh:mm a').format(lastSeenDate)}";
    } else if (lastSeenDateFormatted == yesterday) {
      lastSeen += "yesterday at ${DateFormat('hh:mm a').format(lastSeenDate)}";
    } else {
      DateTime firstDayOfTheCurrentWeek =
          now.subtract(Duration(days: now.weekday - 1));
      if (lastSeenDate.isBefore(firstDayOfTheCurrentWeek)) {
        lastSeen +=
            "${DateFormat.MMMd(context.locale.languageCode).format(lastSeenDate)} at ${DateFormat('hh:mm a').format(lastSeenDate)}";
      } else {
        lastSeen +=
            "${DateFormat('EEEE').format(lastSeenDate)} at ${DateFormat('hh:mm a').format(lastSeenDate)}";
      }
    }
    return lastSeen;
  }

  @override
  void dispose() {
    unreadCountSubscription.cancel();
    super.dispose();
  }
}
