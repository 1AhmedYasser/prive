import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prive/UltraNetwork/ultra_loading_indicator.dart';
import 'package:prive/Widgets/ChatWidgets/channel_item_widget.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

class ForwardScreen extends StatefulWidget {
  final List<Message> selectedMessages;

  const ForwardScreen({Key? key, required this.selectedMessages}) : super(key: key);

  @override
  State<ForwardScreen> createState() => _ForwardScreenState();
}

class _ForwardScreenState extends State<ForwardScreen> {
  bool isSelectedEnabled = false;
  List<Channel> selectedChannels = [];
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
        ),
        title: const Text(
          "Forward",
          style: TextStyle(color: Colors.black),
        ).tr(),
        leading: const BackButton(
          color: Color(0xff7a8ea6),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: TextButton(
              style: ButtonStyle(
                overlayColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
              ),
              onPressed: () {
                setState(() {
                  isSelectedEnabled = !isSelectedEnabled;
                });
              },
              child: Text(
                isSelectedEnabled ? "Unselect" : "Select",
                style: const TextStyle(color: Colors.black, fontSize: 17),
              ).tr(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // SearchTextField(
          //   controller: searchController,
          //   showCloseButton: searchController.text.isNotEmpty ? true : false,
          //   onChanged: (value) {
          //     setState(() {});
          //   },
          // ),
          Expanded(
            child: StreamChannelListView(
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
                    if (searchController.text.isNotEmpty) Filter.autoComplete('name', searchController.text)
                  ],
                ),
                sort: const [SortOption('last_message_at')],
                presence: true,
                limit: 20,
              ),
              emptyBuilder: (context) => const SizedBox.shrink(),
              separatorBuilder: (context, list, index) => const SizedBox.shrink(),
              errorBuilder: (context, error) => Center(
                child: Text(
                  'Error: $error',
                  textAlign: TextAlign.center,
                ),
              ),
              loadingBuilder: (context) => const UltraLoadingIndicator(),
              itemBuilder: (context, channels, index, tile) {
                return InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    if (isSelectedEnabled) {
                      setState(() {
                        if (selectedChannels.contains(channels[index])) {
                          selectedChannels.remove(channels[index]);
                        } else {
                          selectedChannels.add(channels[index]);
                        }
                      });
                    } else {
                      for (var message in widget.selectedMessages) {
                        channels[index].sendMessage(
                          Message(
                            text: message.text,
                            type: message.type,
                            attachments: message.attachments,
                            mentionedUsers: message.mentionedUsers,
                            quotedMessage: message.quotedMessage,
                            quotedMessageId: message.quotedMessageId,
                            extraData: const {
                              'isMessageForwarded': true,
                            },
                          ),
                        );
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: isSelectedEnabled
                      ? Row(
                          children: [
                            Expanded(
                              child: ChannelItemWidget(
                                channel: channels[index],
                                isForward: true,
                              ),
                            ),
                            IgnorePointer(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 23, right: 10),
                                child: Checkbox(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  value: selectedChannels.contains(channels[index]) ? true : false,
                                  onChanged: (value) {},
                                ),
                              ),
                            )
                          ],
                        )
                      : ChannelItemWidget(
                          channel: channels[index],
                          isForward: true,
                        ),
                );
              },
            ),
          ),

          if (isSelectedEnabled)
            Padding(
              padding: const EdgeInsets.only(bottom: 45),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: selectedChannels.isNotEmpty ? Theme.of(context).primaryColorDark : Colors.grey,
                  elevation: 0,
                  minimumSize: Size(MediaQuery.of(context).size.width - 100, 50),
                ),
                onPressed: () {
                  if (selectedChannels.isNotEmpty) {
                    for (var channel in selectedChannels) {
                      for (var message in widget.selectedMessages) {
                        channel.sendMessage(
                          Message(
                            text: message.text,
                            type: message.type,
                            attachments: message.attachments,
                            mentionedUsers: message.mentionedUsers,
                            quotedMessage: message.quotedMessage,
                            quotedMessageId: message.quotedMessageId,
                            extraData: const {
                              'isMessageForwarded': true,
                            },
                          ),
                        );
                      }
                    }
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  "Forward",
                  style: TextStyle(
                    fontSize: 17.5,
                  ),
                ).tr(),
              ),
            )
        ],
      ),
    );
  }
}
