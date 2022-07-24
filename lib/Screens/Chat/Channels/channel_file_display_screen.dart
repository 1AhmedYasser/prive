import 'package:flutter/material.dart';
import 'package:prive/UltraNetwork/ultra_loading_indicator.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

class ChannelFileDisplayScreen extends StatefulWidget {
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

  const ChannelFileDisplayScreen({
    Key? key,
    this.sortOptions,
    this.paginationParams = const PaginationParams(limit: 20),
    this.emptyBuilder,
  }) : super(key: key);

  @override
  State<ChannelFileDisplayScreen> createState() =>
      _ChannelFileDisplayScreenState();
}

class _ChannelFileDisplayScreenState extends State<ChannelFileDisplayScreen> {
  @override
  void initState() {
    super.initState();
    final messageSearchBloc = MessageSearchBloc.of(context);
    messageSearchBloc.search(
      filter: Filter.in_(
        'cid',
        [StreamChannel.of(context).channel.cid!],
      ),
      messageFilter: Filter.in_(
        'attachments.type',
        const ['file'],
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
          "Files",
          style: TextStyle(
              color: StreamChatTheme.of(context).colorTheme.textHighEmphasis,
              fontSize: 16.0),
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
                StreamSvgIcon.files(
                  size: 136.0,
                  color: StreamChatTheme.of(context).colorTheme.disabled,
                ),
                const SizedBox(height: 16.0),
                Text(
                  "No Files",
                  style: TextStyle(
                    fontSize: 14.0,
                    color:
                        StreamChatTheme.of(context).colorTheme.textHighEmphasis,
                  ),
                ).tr(),
                const SizedBox(height: 8.0),
                Text(
                  "Files Will Appear Here",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: StreamChatTheme.of(context)
                        .colorTheme
                        .textHighEmphasis
                        .withOpacity(0.5),
                  ),
                ).tr(),
              ],
            ),
          );
        }

        final media = <Attachment, Message>{};

        for (var item in snapshot.data!) {
          item.message.attachments.where((e) => e.type == 'file').forEach((e) {
            media[e] = item.message;
          });
        }

        return LazyLoadScrollView(
          onEndOfPage: () => messageSearchBloc.search(
            filter: Filter.in_(
              'cid',
              [StreamChannel.of(context).channel.cid!],
            ),
            messageFilter: Filter.in_(
              'attachments.type',
              const ['file'],
            ),
            sort: widget.sortOptions,
            pagination: widget.paginationParams.copyWith(
              offset: messageSearchBloc.messageResponses?.length ?? 0,
            ),
          ),
          child: ListView.builder(
            itemBuilder: (context, position) {
              return Padding(
                padding: const EdgeInsets.all(1.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FileAttachment(
                    message: media.values.toList()[position],
                    attachment: media.keys.toList()[position],
                  ),
                ),
              );
            },
            itemCount: media.length,
          ),
        );
      },
      stream: messageSearchBloc.messagesStream,
    );
  }
}
