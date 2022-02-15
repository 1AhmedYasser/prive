import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:prive/Screens/Chat/Chat/chat_info_screen.dart';
import 'package:prive/Screens/Chat/Chat/chat_screen.dart';
import 'package:prive/Screens/Chat/Chat/group_info_screen.dart';
import 'package:prive/Widgets/ChatWidgets/channel_item_widget.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class ChannelsListWidget extends StatefulWidget {
  final List<Channel> channels;
  const ChannelsListWidget({Key? key, required this.channels})
      : super(key: key);

  @override
  _ChannelsListWidgetState createState() => _ChannelsListWidgetState();
}

class _ChannelsListWidgetState extends State<ChannelsListWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: widget.channels.length,
      itemBuilder: (BuildContext context, int index) {
        return StreamChannel(
          channel: widget.channels[index],
          child: AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              horizontalOffset: 50,
              child: FadeInAnimation(
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () => Navigator.of(context).push(
                      ChatScreen.routeWithChannel(widget.channels[index])),
                  onLongPress: () {
                    Channel channel = widget.channels[index];
                    if (channel.memberCount == 2 && channel.isDistinct) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StreamChannel(
                            channel: channel,
                            child: ChatInfoScreen(
                              messageTheme:
                                  StreamChatTheme.of(context).ownMessageTheme,
                              user: channel.state!.members
                                  .where((m) =>
                                      m.userId !=
                                      channel.client.state.currentUser!.id)
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
                              messageTheme:
                                  StreamChatTheme.of(context).ownMessageTheme,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  child: ChannelItemWidget(
                    channel: widget.channels[index],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
