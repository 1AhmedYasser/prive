import 'package:flutter/material.dart';
import 'package:prive/Helpers/utils.dart';
import 'package:prive/Providers/channels_provider.dart';
import 'package:prive/UltraNetwork/ultra_loading_indicator.dart';
import 'package:prive/Widgets/AppWidgets/channels_empty_widgets.dart';
import 'package:prive/Widgets/ChatWidgets/channels_list_item_widget.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:prive/Screens/Chat/Chat/chat_screen.dart';

class ChannelsTab extends StatefulWidget {
  const ChannelsTab({Key? key}) : super(key: key);

  @override
  State<ChannelsTab> createState() => _ChannelsTabState();
}

class _ChannelsTabState extends State<ChannelsTab> with TickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this);
    // Utils.showCallOverlay();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChannelsProvider>(
      builder: (context, provider, ch) {
        return StreamChannelListView(
          controller: StreamChannelListController(
            client: StreamChat.of(context).client,
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
            channelStateSort: const [SortOption('last_message_at')],
            presence: true,
            limit: 20,
          ),
          separatorBuilder: (context, channels, index) => const SizedBox.shrink(),
          emptyBuilder: (context) => ChannelsEmptyState(animationController: _animationController),
          errorBuilder: (context, widget) {
            Utils.checkForInternetConnection(context);
            return const SizedBox.shrink();
          },
          loadingBuilder: (context) => const UltraLoadingIndicator(),
          onChannelTap: (channel) {
            Navigator.of(context).push(
              ChatScreen.routeWithChannel(channel),
            );
          },
          itemBuilder: (context, channels, index, tile) {
            List<Channel> emptyChannels = channels.where((e) => e.lastMessageAt == null).toList();
            if (emptyChannels.length != channels.length) {
              return channels[index].lastMessageAt != null
                  ? ChannelListItemWidget(
                      channel: channels[index],
                    )
                  : const SizedBox.shrink();
            } else {
              return SizedBox(
                height: MediaQuery.of(context).size.height / 1.45,
                child: ChannelsEmptyState(animationController: _animationController),
              );
            }
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
