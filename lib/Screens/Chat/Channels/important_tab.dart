import 'package:flutter/material.dart';
import 'package:prive/UltraNetwork/ultra_loading_indicator.dart';
import 'package:prive/Widgets/AppWidgets/channels_empty_widgets.dart';
import 'package:prive/Widgets/ChatWidgets/channels_list_widget.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class ImportantTab extends StatefulWidget {
  const ImportantTab({Key? key}) : super(key: key);

  @override
  _ImportantTabState createState() => _ImportantTabState();
}

class _ImportantTabState extends State<ImportantTab>
    with TickerProviderStateMixin {
  final channelListController = ChannelListController();
  late final AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChannelListCore(
      channelListController: channelListController,
      filter: Filter.and(
        [
          Filter.equal('type', 'messaging'),
          Filter.in_('members', [
            StreamChatCore.of(context).currentUser!.id,
          ])
        ],
      ),
      emptyBuilder: (context) =>
          ChannelsEmptyState(animationController: _animationController),
      errorBuilder: (context, error) => Center(
        child: Text(
          'Error: $error',
          textAlign: TextAlign.center,
        ),
      ),
      loadingBuilder: (
        context,
      ) =>
          const UltraLoadingIndicator(),
      listBuilder: (context, channels) {
        channels =
            channels.where((element) => element.lastMessageAt != null).toList();
        return channels.isEmpty
            ? ChannelsEmptyState(animationController: _animationController)
            : ChannelsListWidget(channels: channels);
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}