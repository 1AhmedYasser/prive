import 'package:flutter/material.dart';
import 'package:prive/UltraNetwork/ultra_loading_indicator.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:easy_localization/easy_localization.dart';

class ChannelMediaDisplayScreen extends StatefulWidget {
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

  final StreamMessageThemeData messageTheme;

  const ChannelMediaDisplayScreen({
    Key? key,
    required this.messageTheme,
    this.sortOptions,
    this.paginationParams = const PaginationParams(limit: 20),
    this.emptyBuilder,
    this.onShowMessage,
  }) : super(key: key);

  @override
  State<ChannelMediaDisplayScreen> createState() => _ChannelMediaDisplayScreenState();
}

class _ChannelMediaDisplayScreenState extends State<ChannelMediaDisplayScreen> {
  Map<String?, VideoPlayerController?> controllerCache = {};

  late final messageSearchListController = StreamMessageSearchListController(
    client: StreamChatCore.of(context).client,
    filter: Filter.in_(
      'cid',
      [StreamChannel.of(context).channel.cid!],
    ),
    messageFilter: Filter.in_(
      'attachments.type',
      const ['image', 'video'],
    ),
    sort: widget.sortOptions,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StreamChatTheme.of(context).colorTheme.barsBg,
      appBar: AppBar(
        elevation: 1,
        centerTitle: true,
        title: Text(
          "Photos & Videos",
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
                StreamSvgIcon.pictures(
                  size: 136.0,
                  color: StreamChatTheme.of(context).colorTheme.disabled,
                ),
                const SizedBox(height: 16.0),
                Text(
                  "No Media",
                  style: TextStyle(
                    fontSize: 14.0,
                    color: StreamChatTheme.of(context).colorTheme.textHighEmphasis,
                  ),
                ).tr(),
                const SizedBox(height: 8.0),
                Text(
                  "Photos & Videos Will Appear Here",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: StreamChatTheme.of(context).colorTheme.textHighEmphasis.withOpacity(0.5),
                  ),
                ).tr(),
              ],
            ),
          );
        }

        final media = <_AssetPackage>[];

        for (var item in snapshot.data!) {
          item.message.attachments
              .where((e) => (e.type == 'image' || e.type == 'video') && e.ogScrapeUrl == null)
              .forEach((e) {
            VideoPlayerController? controller;
            if (e.type == 'video') {
              var cachedController = controllerCache[e.assetUrl];

              if (cachedController == null) {
                controller = VideoPlayerController.network(e.assetUrl!);
                controller.initialize();
                controllerCache[e.assetUrl] = controller;
              } else {
                controller = cachedController;
              }
            }
            media.add(_AssetPackage(e, item.message, controller));
          });
        }

        return LazyLoadScrollView(
          onEndOfPage: () => search(),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            itemBuilder: (context, position) {
              var channel = StreamChannel.of(context).channel;
              return Padding(
                padding: const EdgeInsets.all(1.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StreamChannel(
                          channel: channel,
                          child: StreamFullScreenMedia(
                            // mediaAttachments:
                            //     media.map((e) => e.attachment).toList(),
                            startIndex: position,
                            //message: media[position].message,
                            userName: media[position].message.user!.name,
                            onShowMessage: widget.onShowMessage,
                            mediaAttachmentPackages: const [],
                          ),
                        ),
                      ),
                    );
                  },
                  child: media[position].attachment.type == 'image'
                      ? IgnorePointer(
                          child: StreamImageAttachment(
                            attachment: media[position].attachment,
                            message: media[position].message,
                            showTitle: false,
                            imageThumbnailSize: Size(
                              MediaQuery.of(context).size.width * 0.8,
                              MediaQuery.of(context).size.height * 0.3,
                            ),
                            messageTheme: widget.messageTheme,
                          ),
                        )
                      : VideoPlayer(media[position].videoPlayer!),
                ),
              );
            },
            itemCount: media.length,
          ),
        );
      },
    );
  }

  search() {
    messageSearchListController.searchQuery = 'search-value';
    messageSearchListController.doInitialLoad();
  }

  @override
  void dispose() {
    messageSearchListController.dispose();
    super.dispose();
    for (var c in controllerCache.values) {
      c!.dispose();
    }
  }
}

class _AssetPackage {
  Attachment attachment;
  Message message;
  VideoPlayerController? videoPlayer;

  _AssetPackage(this.attachment, this.message, this.videoPlayer);
}
