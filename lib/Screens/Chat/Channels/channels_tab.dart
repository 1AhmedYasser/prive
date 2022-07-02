import 'package:flutter/material.dart';
import 'package:prive/Helpers/utils.dart';
import 'package:prive/UltraNetwork/ultra_loading_indicator.dart';
import 'package:prive/Widgets/AppWidgets/channels_empty_widgets.dart';
import 'package:prive/Widgets/ChatWidgets/channels_list_widget.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../Chat/chat_screen.dart';

class ChannelsTab extends StatefulWidget {
  const ChannelsTab({Key? key}) : super(key: key);

  @override
  _ChannelsTabState createState() => _ChannelsTabState();
}

class _ChannelsTabState extends State<ChannelsTab>
    with TickerProviderStateMixin {
  final channelListController = ChannelListController();
  late final AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this);
    // Utils.showCallOverlay();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChannelsBloc(
      child: ChannelListView(
        filter: Filter.and(
          [
            Filter.equal('type', 'messaging'),
            Filter.in_(
              'members',
              [
                StreamChatCore.of(context).currentUser!.id,
              ],
            ),
            Filter.equal('channel_type', 'Normal'),
          ],
        ),
        sort: const [SortOption('last_message_at')],
        presence: true,
        limit: 20,
        watch: true,
        swipeToAction: true,
        separatorBuilder: (context, index) => const SizedBox.shrink(),
        emptyBuilder: (context) =>
            ChannelsEmptyState(animationController: _animationController),
        errorBuilder: (context, widget) {
          Utils.checkForInternetConnection(context);
          return const SizedBox.shrink();
        },
        loadingBuilder: (context) => const UltraLoadingIndicator(),
        onChannelTap: (channel, w) {
          Navigator.of(context).push(
            ChatScreen.routeWithChannel(channel),
          );
        },
        listBuilder: (context, channels) {
          channels = channels
              .where((channel) => channel.state?.messages.isNotEmpty ?? false)
              .toList();
          return channels.isNotEmpty
              ? ChannelsListWidget(
                  channels: channels,
                )
              : ChannelsEmptyState(animationController: _animationController);
        },
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
