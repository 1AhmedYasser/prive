import 'package:flutter/material.dart';
import 'package:prive/Helpers/utils.dart';
import 'package:prive/UltraNetwork/ultra_loading_indicator.dart';
import 'package:prive/Widgets/AppWidgets/channels_empty_widgets.dart';
import 'package:prive/Widgets/ChatWidgets/channels_list_item_widget.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../../../Providers/channels_provider.dart';

class ArchiveTab extends StatefulWidget {
  const ArchiveTab({Key? key}) : super(key: key);

  @override
  State<ArchiveTab> createState() => _ArchiveTabState();
}

class _ArchiveTabState extends State<ArchiveTab> with TickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChannelsProvider>(builder: (context, provider, ch) {
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
              Filter.equal('is_archive', true),
            ],
          ),
          channelStateSort: const [SortOption('last_message_at')],
        ),
        emptyBuilder: (context) => ChannelsEmptyState(animationController: _animationController),
        errorBuilder: (context, widget) {
          Utils.checkForInternetConnection(context);
          return const SizedBox.shrink();
        },
        loadingBuilder: (
          context,
        ) =>
            const UltraLoadingIndicator(),
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
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
