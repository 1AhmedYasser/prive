import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Screens/Chat/chat_screen.dart';
import 'package:prive/Widgets/ChatWidgets/typing_indicator.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';
import 'package:easy_localization/easy_localization.dart';

class ChannelsListWidget extends StatefulWidget {
  final List<Channel> channels;

  const ChannelsListWidget({Key? key, required this.channels})
      : super(key: key);

  @override
  _ChannelsListWidgetState createState() => _ChannelsListWidgetState();
}

class _ChannelsListWidgetState extends State<ChannelsListWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: widget.channels.length,
      itemBuilder: (BuildContext context, int index) {
        return StreamChannel(
          channel: widget.channels[index],
          child: AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              horizontalOffset: 50,
              child: FadeInAnimation(
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () => Navigator.of(context).push(
                      ChatScreen.routeWithChannel(widget.channels[index])),
                  onLongPress: () {
                    print("hi");
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        right: 22, top: 30, left: 15, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            ChannelAvatar(
                              channel: widget.channels[index],
                              constraints: const BoxConstraints(
                                maxWidth: 65,
                                maxHeight: 65,
                              ),
                            ),
                            // Stack(
                            //   children: [
                            //
                            //     SizedBox(
                            //       width: 72,
                            //       height: 72,
                            //       child: CachedImage(
                            //         url: StreamManager.getChannelImage(
                            //               widget.channels[index],
                            //               context.currentUser!,
                            //             ) ??
                            //             "",
                            //         fit: BoxFit.fill,
                            //       ),
                            //     ),
                            //     if (index % 2 == 0)
                            //       Positioned(
                            //         bottom: 2,
                            //         right: 0,
                            //         child: Container(
                            //           decoration: BoxDecoration(
                            //             color: Colors.white,
                            //             borderRadius: BorderRadius.circular(50),
                            //           ),
                            //           child: const Padding(
                            //             padding: EdgeInsets.all(2),
                            //             child: CircleAvatar(
                            //               backgroundColor: Colors.green,
                            //               radius: 6,
                            //             ),
                            //           ),
                            //         ),
                            //       )
                            //   ],
                            // ),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Expanded(
                                        child: ChannelName(
                                          textStyle: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      BetterStreamBuilder<DateTime>(
                                        stream: widget.channels[index]
                                            .lastMessageAtStream,
                                        initialData: widget
                                            .channels[index].lastMessageAt,
                                        builder: (context, data) {
                                          return BetterStreamBuilder<int>(
                                            stream: widget.channels[index]
                                                .state!.unreadCountStream,
                                            initialData: widget.channels[index]
                                                    .state?.unreadCount ??
                                                0,
                                            builder: (context, count) {
                                              return Text(
                                                getLatestMessageDate(data),
                                                style: TextStyle(
                                                  color: count > 0
                                                      ? Theme.of(context)
                                                          .primaryColorDark
                                                      : Colors.black,
                                                  fontWeight: count > 0
                                                      ? FontWeight.w500
                                                      : FontWeight.w400,
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  BetterStreamBuilder<int>(
                                    stream: widget.channels[index].state!
                                        .unreadCountStream,
                                    initialData: widget.channels[index].state
                                            ?.unreadCount ??
                                        0,
                                    builder: (context, count) {
                                      return BetterStreamBuilder<Message>(
                                        stream: widget.channels[index].state!
                                            .lastMessageStream,
                                        initialData: widget
                                            .channels[index].state!.lastMessage,
                                        builder: (context, lastMessage) {
                                          return Row(
                                            children: [
                                              Expanded(
                                                child: TypingIndicatorWidget(
                                                  alternativeWidget: Text(
                                                    lastMessage.text ?? "",
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 14.5,
                                                      fontWeight: count > 0
                                                          ? FontWeight.w500
                                                          : FontWeight.w400,
                                                      color: count > 0
                                                          ? const Color(
                                                              0xff1293a8)
                                                          : Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              if (count == 0)
                                                const SizedBox(
                                                  height: 23,
                                                ),
                                              if (count > 0)
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color:
                                                        const Color(0xff53c662),
                                                  ),
                                                  child: Center(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8,
                                                              right: 8,
                                                              top: 3.5,
                                                              bottom: 3.5),
                                                      child: Text(
                                                        "$count",
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 13.5,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              if (lastMessage.user?.id ==
                                                  context.currentUser?.id)
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    right: context.locale
                                                                .languageCode ==
                                                            "en"
                                                        ? 18
                                                        : 0,
                                                    left: context.locale
                                                                .languageCode ==
                                                            "en"
                                                        ? 0
                                                        : 18,
                                                  ),
                                                  child: StreamChatTheme(
                                                    data: StreamChatThemeData
                                                        .fromTheme(
                                                      ThemeData.from(
                                                        colorScheme:
                                                            const ColorScheme.dark(),
                                                      ),
                                                    ),
                                                    child: SendingIndicator(
                                                      message: lastMessage,
                                                      size: 22.5,
                                                      isMessageRead: widget
                                                          .channels[index]
                                                          .state!
                                                          .read
                                                          .where((element) =>
                                                              element.user.id !=
                                                              widget
                                                                  .channels[
                                                                      index]
                                                                  .client
                                                                  .state
                                                                  .currentUser!
                                                                  .id)
                                                          .where((element) => element
                                                              .lastRead
                                                              .isAfter(lastMessage
                                                                  .createdAt))
                                                          .isNotEmpty,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String getLatestMessageDate(DateTime data) {
    final now = DateTime.now();
    DateTime messageDate = data.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    final messageDateFormatted =
        DateTime(messageDate.year, messageDate.month, messageDate.day);

    if (messageDateFormatted == today) {
      return DateFormat('hh:mm a').format(messageDate);
    } else if (messageDateFormatted == yesterday) {
      return "Yesterday";
    } else {
      DateTime firstDayOfTheCurrentWeek =
          now.subtract(Duration(days: now.weekday - 1));
      if (messageDate.isBefore(firstDayOfTheCurrentWeek)) {
        return DateFormat('d/MM/yyyy').format(messageDate);
      } else {
        return DateFormat('EEEE').format(messageDate);
      }
    }
  }

  String getLastSeenDate(DateTime data) {
    String lastSeen = "last seen ";
    final now = DateTime.now();
    DateTime lastSeenDate = data.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    final lastSeenDateFormatted =
        DateTime(lastSeenDate.year, lastSeenDate.month, lastSeenDate.day);

    if (lastSeenDateFormatted == today) {
      lastSeen += "today at ${DateFormat('hh:mm a').format(lastSeenDate)}";
    } else if (lastSeenDateFormatted == yesterday) {
      lastSeen += "yesterday at ${DateFormat('hh:mm a').format(lastSeenDate)}";
    } else {
      DateTime firstDayOfTheCurrentWeek =
          now.subtract(Duration(days: now.weekday - 1));
      if (lastSeenDate.isBefore(firstDayOfTheCurrentWeek)) {
        lastSeen +=
            "${DateFormat.MMMd(context.locale.languageCode).format(lastSeenDate)} at ${DateFormat('hh:mm a').format(lastSeenDate)}";
      } else {
        lastSeen +=
            "${DateFormat('EEEE').format(lastSeenDate)} at ${DateFormat('hh:mm a').format(lastSeenDate)}";
      }
    }
    return lastSeen;
  }
}
