import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_5.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Widgets/Common/cached_image.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

class ChatListWidget extends StatelessWidget {
  final List<Message> messages;

  const ChatListWidget({
    Key? key,
    required this.messages,
    required this.messageFocus,
    required ScrollController chatScrollController,
  })  : _chatScrollController = chatScrollController,
        super(key: key);

  final FocusNode messageFocus;
  final ScrollController _chatScrollController;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        messageFocus.unfocus();
      },
      child: GroupedListView<Message, DateTime>(
        shrinkWrap: true,
        elements: messages,
        order: GroupedListOrder.DESC,
        reverse: true,
        floatingHeader: true,
        controller: _chatScrollController,
        useStickyGroupSeparators: true,
        groupBy: (Message element) => DateTime(element.createdAt.year,
            element.createdAt.month, element.createdAt.day),
        itemComparator: (message1, message2) =>
            message1.createdAt.compareTo(message2.createdAt),
        groupHeaderBuilder: (element) => SizedBox(
          height: 60,
          child: Align(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xff1293a8),
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 7, bottom: 7),
                child: Text(
                  getHeaderDate(context, element),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ),
        itemBuilder: (context, message) {
          bool isMe = message.user?.id == context.currentUser?.id;
          return Align(
            alignment: !isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: !isMe
                  ? context.locale.languageCode == "en"
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.end
                  : context.locale.languageCode == "en"
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: !isMe
                        ? context.locale.languageCode == "en"
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.end
                        : context.locale.languageCode == "en"
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                    children: [
                      ChatBubble(
                        clipper: ChatBubbleClipper5(
                          type: isMe
                              ? BubbleType.sendBubble
                              : BubbleType.receiverBubble,
                        ),
                        backGroundColor:
                            isMe ? const Color(0xff7a8fa6) : Colors.white,
                        margin: const EdgeInsets.only(top: 12),
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 5, top: 2.5, bottom: 2.5, right: 5),
                              child: message.type == "regular"
                                  ? Text(
                                      message.text ?? "",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color:
                                            isMe ? Colors.white : Colors.black,
                                      ),
                                    )
                                  : message.type == ""
                                      ? GestureDetector(
                                          onTap: () {
                                            // Navigator.of(context).push(
                                            //   new PageRouteBuilder(
                                            //     pageBuilder:
                                            //         (BuildContext context, _,
                                            //         __) {
                                            //       return new ImageSliderWidget(
                                            //         images: [
                                            //           element.content,
                                            //         ],
                                            //         file: File(""),
                                            //         showTitle: false,
                                            //       );
                                            //     },
                                            //     transitionsBuilder: (_,
                                            //         Animation<double> animation,
                                            //         __,
                                            //         Widget child) {
                                            //       return new FadeTransition(
                                            //           opacity: animation,
                                            //           child: child);
                                            //     },
                                            //   ),
                                            // );
                                          },
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: CachedImage(
                                              url: message.text ?? "",
                                            ),
                                          ),
                                        )
                                      : Container() //_buildAudio(element),
                              ),
                        ),
                        elevation: 1,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: !isMe ? 0 : 5,
                          right: !isMe ? 5 : 0,
                        ),
                        child: Align(
                          alignment: !isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Row(
                            children: [
                              Text(
                                DateFormat('hh:mm a')
                                    .format(message.createdAt.toLocal()),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12.5,
                                ),
                              ),
                              if (isMe) const SizedBox(width: 4),
                              if (isMe)
                                Image.asset(
                                  R.images.seenImage,
                                  width: 20,
                                  color: Theme.of(context).primaryColor,
                                )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String getHeaderDate(BuildContext context, Message element) {
    final now = DateTime.now();
    DateTime messageDate = element.createdAt.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    final messageDateFormatted = DateTime(
        element.createdAt.year, element.createdAt.month, element.createdAt.day);

    if (messageDateFormatted == today) {
      return "Today";
    } else if (messageDateFormatted == yesterday) {
      return "Yesterday";
    } else {
      DateTime firstDayOfTheCurrentWeek =
          now.subtract(Duration(days: now.weekday - 1));
      if (messageDate.isBefore(firstDayOfTheCurrentWeek)) {
        return DateFormat.MMMd(context.locale.languageCode).format(messageDate);
      } else {
        return DateFormat('EEEE').format(messageDate);
      }
    }
  }
}
