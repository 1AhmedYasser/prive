import 'package:flutter/material.dart';
import 'package:prive/UltraNetwork/ultra_loading_indicator.dart';
import 'package:prive/Widgets/AppWidgets/channels_empty_widgets.dart';
import 'package:prive/Widgets/ChatWidgets/channels_list_widget.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChannelsBloc(
      child: ChannelListView(
        filter: Filter.in_(
          'members',
          [StreamChat.of(context).currentUser!.id],
        ),
        sort: const [SortOption('last_message_at')],
        presence: true,
        limit: 20,
        channelWidget: const ChannelPage(),
        separatorBuilder: (context, index) => const SizedBox.shrink(),
        emptyBuilder: (context) =>
            ChannelsEmptyState(animationController: _animationController),
        errorBuilder: (context, error) => Center(
          child: Text(
            'Error: $error',
            textAlign: TextAlign.center,
          ),
        ),
        loadingBuilder: (context) => const UltraLoadingIndicator(),
       // channelPreviewBuilder: _channelPreviewBuilder,
        listBuilder: (context, channels) =>
            ChannelsListWidget(channels: channels),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}


class ChannelPage extends StatelessWidget {
  const ChannelPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ChannelHeader(),
      body: Column(
        children: const <Widget>[
          Expanded(
            child: MessageListView(),
          ),
          MessageInput(),
        ],
      ),
    );
  }
}
