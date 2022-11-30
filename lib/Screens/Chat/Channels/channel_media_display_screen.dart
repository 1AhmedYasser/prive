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

  final Channel? channel;

  final ShowMessageCallback? onShowMessage;

  final StreamMessageThemeData messageTheme;

  const ChannelMediaDisplayScreen({
    Key? key,
    required this.messageTheme,
    this.sortOptions,
    required this.channel,
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
          'Photos & Videos',
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
      // body: //_buildMediaGrid(),
      body: StreamMessageSearchGridView(
        controller: messageSearchListController,
        itemBuilder: (BuildContext context, List<GetMessageResponse> values, int index) {
          final media = <_AssetPackage>[];

          for (var item in values) {
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

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StreamChannel(
                    channel: widget.channel!,
                    child: StreamFullScreenMedia(
                      mediaAttachmentPackages: media[index].message.getAttachmentPackageList(),
                      startIndex: media[index].message.attachments.indexOf(media[index].attachment),
                      userName: media[index].message.user!.name,
                      onShowMessage: widget.onShowMessage,
                    ),
                  ),
                ),
              );
            },
            child: media[index].attachment.type == 'image'
                ? IgnorePointer(
                    child: StreamImageAttachment(
                      attachment: media[index].attachment,
                      message: media[index].message,
                      showTitle: false,
                      imageThumbnailSize: Size(
                        MediaQuery.of(context).size.width * 0.8,
                        MediaQuery.of(context).size.height * 0.3,
                      ),
                      messageTheme: widget.messageTheme,
                    ),
                  )
                : VideoPlayer(media[index].videoPlayer!),
          );
        },
        loadingBuilder: (context) {
          return const Center(
            child: UltraLoadingIndicator(),
          );
        },
        emptyBuilder: (context) {
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
                  'No Media',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: StreamChatTheme.of(context).colorTheme.textHighEmphasis,
                  ),
                ).tr(),
                const SizedBox(height: 8.0),
                Text(
                  'Photos & Videos Will Appear Here',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: StreamChatTheme.of(context).colorTheme.textHighEmphasis.withOpacity(0.5),
                  ),
                ).tr(),
              ],
            ),
          );
        },
      ),
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
