import 'package:flutter/material.dart';
import 'package:prive/Screens/Chat/Chat/chat_info_screen.dart';
import 'package:prive/Screens/Chat/Chat/chat_screen.dart';
import 'package:prive/Screens/Chat/Chat/group_info_screen.dart';
import 'package:prive/Widgets/ChatWidgets/channel_item_widget.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChannelListItemWidget extends StatefulWidget {
  final Channel channel;
  final bool isChannel;
  const ChannelListItemWidget({Key? key, required this.channel, this.isChannel = false}) : super(key: key);

  @override
  State<ChannelListItemWidget> createState() => _ChannelListItemWidgetState();
}

class _ChannelListItemWidgetState extends State<ChannelListItemWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamChannel(
      channel: widget.channel,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () =>
            Navigator.of(context).push(ChatScreen.routeWithChannel(widget.channel, isChannel: widget.isChannel)),
        onLongPress: () {
          if (!widget.isChannel) {
            Channel channel = widget.channel;
            if (channel.isGroup == false) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StreamChannel(
                    channel: channel,
                    child: ChatInfoScreen(
                      messageTheme: StreamChatTheme.of(context).ownMessageTheme,
                      user: channel.state!.members
                          .where((m) => m.userId != channel.client.state.currentUser!.id)
                          .first
                          .user,
                    ),
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StreamChannel(
                    channel: channel,
                    child: GroupInfoScreen(
                      messageTheme: StreamChatTheme.of(context).ownMessageTheme,
                      channel: channel,
                    ),
                  ),
                ),
              );
            }
          }
        },
        child: ChannelItemWidget(
          channel: widget.channel,
        ),
      ),
    );
  }
}
