import 'package:flutter/material.dart';
import 'package:prive/UltraNetwork/ultra_loading_indicator.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:easy_localization/easy_localization.dart';

class PinnedMessagesScreen extends StatefulWidget {
  /// The sorting used for the channels matching the filters.
  /// Sorting is based on field and direction, multiple sorting options can be provided.
  /// You can sort based on last_updated, last_message_at, updated_at, created_at or member_count.
  /// Direction can be ascending or descending.
  final List<SortOption>? sortOptions;

  /// Pagination parameters
  /// limit: the number of users to return (max is 30)
  /// offset: the offset (max is 1000)
  /// message_limit: how many messages should be included to each channel
  final PaginationParams paginationParams;

  /// The builder used when the file list is empty.
  final WidgetBuilder? emptyBuilder;

  final ShowMessageCallback? onShowMessage;

  final MessageThemeData messageTheme;

  const PinnedMessagesScreen({
    Key? key,
    required this.messageTheme,
    this.sortOptions,
    this.paginationParams = const PaginationParams(limit: 20),
    this.emptyBuilder,
    this.onShowMessage,
  }) : super(key: key);

  @override
  _PinnedMessagesScreenState createState() => _PinnedMessagesScreenState();
}

class _PinnedMessagesScreenState extends State<PinnedMessagesScreen> {
  Map<String?, VideoPlayerController?> controllerCache = {};

  @override
  void initState() {
    super.initState();
    final messageSearchBloc = MessageSearchBloc.of(context);
    messageSearchBloc.search(
      filter: Filter.in_(
        'cid',
        [StreamChannel.of(context).channel.cid!],
      ),
      messageFilter: Filter.equal(
        'pinned',
        true,
      ),
      sort: widget.sortOptions,
      pagination: widget.paginationParams,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StreamChatTheme.of(context).colorTheme.barsBg,
      appBar: AppBar(
        elevation: 1,
        centerTitle: true,
        title: Text(
          "Pinned Messages",
          style: TextStyle(
            color: StreamChatTheme.of(context).colorTheme.textHighEmphasis,
            fontSize: 16.0,
          ),
        ).tr(),
        leading: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: BackButton(
            color: Color(0xff7a8ea6),
          ),
        ),
        backgroundColor: StreamChatTheme.of(context).colorTheme.barsBg,
      ),
      body: _buildMediaGrid(),
    );
  }

  Widget _buildMediaGrid() {
    final messageSearchBloc = MessageSearchBloc.of(context);

    return StreamBuilder<List<GetMessageResponse>>(
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return const Center(
            child: UltraLoadingIndicator(),
          );
        }

        if (snapshot.data!.isEmpty) {
          if (widget.emptyBuilder != null) {
            return widget.emptyBuilder!(context);
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StreamSvgIcon.pin(
                  size: 136.0,
                  color: StreamChatTheme.of(context).colorTheme.disabled,
                ),
                const SizedBox(height: 16.0),
                Text(
                  "No Pinned Messages",
                  style: TextStyle(
                    fontSize: 17.0,
                    color:
                        StreamChatTheme.of(context).colorTheme.textHighEmphasis,
                    fontWeight: FontWeight.bold,
                  ),
                ).tr(),
              ],
            ),
          );
        }

        var data = snapshot.data ?? [];

        return LazyLoadScrollView(
          onEndOfPage: () => messageSearchBloc.search(
            filter: Filter.in_(
              'cid',
              [StreamChannel.of(context).channel.cid!],
            ),
            messageFilter: Filter.equal(
              'pinned',
              true,
            ),
            sort: widget.sortOptions,
            pagination: widget.paginationParams.copyWith(
              offset: messageSearchBloc.messageResponses?.length ?? 0,
            ),
          ),
          child: ListView.builder(
            itemBuilder: (context, position) {
              var user = data[position].message.user!;
              var attachments = data[position].message.attachments;
              var text = data[position].message.text ?? '';

              return ListTile(
                leading: UserAvatar(
                  user: user,
                  constraints: const BoxConstraints.tightFor(
                    width: 40.0,
                    height: 40.0,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                title: Text(
                  user.name,
                  style: TextStyle(
                      color: StreamChatTheme.of(context)
                          .colorTheme
                          .textHighEmphasis,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  text != ''
                      ? text
                      : (attachments.isNotEmpty
                          ? '${attachments.length} ${attachments.length > 1 ? "Attachments".tr() : "Attachment".tr()}'
                          : ''),
                ),
                onTap: () {
                  widget.onShowMessage?.call(data[position].message,
                      StreamChannel.of(context).channel);
                },
              );
            },
            itemCount: snapshot.data!.length,
          ),
        );
      },
      stream: messageSearchBloc.messagesStream,
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (var c in controllerCache.values) {
      c!.dispose();
    }
  }
}
