import 'package:flutter/material.dart';
import 'package:prive/Helpers/utils.dart';
import 'package:prive/UltraNetwork/ultra_loading_indicator.dart';
import 'package:prive/Widgets/AppWidgets/channels_empty_widgets.dart';
import 'package:prive/Widgets/ChatWidgets/channels_list_widget.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../../../Providers/channels_provider.dart';

class PriveChannelsTab extends StatefulWidget {
  const PriveChannelsTab({Key? key}) : super(key: key);

  @override
  State<PriveChannelsTab> createState() => _PriveChannelsTabState();
}

class _PriveChannelsTabState extends State<PriveChannelsTab> with TickerProviderStateMixin {
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
        shrinkWrap: true,
        controller: StreamChannelListController(
          client: StreamChat.of(context).client,
          filter: Filter.and(
            [
              Filter.equal('type', 'messaging'),
              Filter.equal('channel_type', 'Public_Channels'),
            ],
          ),
          sort: const [SortOption('last_message_at')],
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
          return channels.isEmpty
              ? ChannelsEmptyState(animationController: _animationController)
              : ChannelsListWidget(
                  channels: channels,
                  isChannel: true,
                );
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
