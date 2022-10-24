import 'package:flutter/material.dart';
import 'package:prive/Helpers/utils.dart';
import 'package:prive/UltraNetwork/ultra_loading_indicator.dart';
import 'package:prive/Widgets/AppWidgets/channels_empty_widgets.dart';
import 'package:prive/Widgets/ChatWidgets/channels_list_widget.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../../../Providers/channels_provider.dart';

class GroupsTab extends StatefulWidget {
  const GroupsTab({Key? key}) : super(key: key);

  @override
  State<GroupsTab> createState() => _GroupsTabState();
}

class _GroupsTabState extends State<GroupsTab> with TickerProviderStateMixin {
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
              Filter.equal('channel_type', 'Group'),
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
          // channels =
          //     channels.where((element) => element.lastMessageAt != null).toList();
          return channels.isEmpty
              ? ChannelsEmptyState(animationController: _animationController)
              : ChannelsListWidget(
                  channels: channels,
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
