import 'dart:async';
import 'package:flutter/material.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Helpers/stream_manager.dart';
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

  @override
  void initState() {
    super.initState();

    // unreadCountSubscription = StreamChannel.of(context)
    //     .channel
    //     .state!
    //     .unreadCountStream
    //     .listen(_unreadCountHandler);
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
              color: Colors.black,
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
            GestureDetector(
              onTap: () {},
              child: Image.asset(
                R.images.chatMoreImage,
                width: 20,
              ),
            ),
            const SizedBox(width: 15),
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
              messageListBuilder: (context, messages) => Container(),
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
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          );
        } else {
          alternativeWidget = Text(
            'Last online: ',
            //'${Jiffy(otherMember.user?.lastActive).fromNow()}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          );
        }
      }
    }

    return TypingIndicator(
      alternativeWidget: alternativeWidget,
    );
  }

  @override
  void dispose() {
    //unreadCountSubscription.cancel();
    super.dispose();
  }
}
