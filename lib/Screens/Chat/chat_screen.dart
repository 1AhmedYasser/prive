import 'dart:async';
import 'package:flutter/material.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Helpers/utils.dart';
import 'package:prive/Widgets/ChatWidgets/chat_list_widget.dart';
import 'package:prive/Widgets/ChatWidgets/chat_menu_widget.dart';
import 'package:prive/Widgets/ChatWidgets/chat_send_widget.dart';
import 'package:prive/Widgets/ChatWidgets/connection_status_builder.dart';
import 'package:prive/Widgets/ChatWidgets/typing_indicator.dart';
import 'package:prive/Widgets/Common/cached_image.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io';

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
  bool? isAFile;
  String chatBackground = R.images.chatBackground1;

  @override
  void initState() {
    super.initState();
    _getChatBackground();

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
            const ChatMenuWidget(),
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
                    image: isAFile == true
                        ? DecorationImage(
                            image: FileImage(File(chatBackground)),
                            fit: BoxFit.cover,
                          )
                        : DecorationImage(
                            image: AssetImage(chatBackground),
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

    return TypingIndicatorWidget(
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

  Future<void> _getChatBackground() async {
    isAFile = await Utils.getBool(R.pref.isChosenChatBackgroundAFile);
    chatBackground = await Utils.getString(R.pref.chosenChatBackground) ??
        R.images.chatBackground1;
    setState(() {});
  }

  @override
  void dispose() {
    unreadCountSubscription.cancel();
    super.dispose();
  }
}
