import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:prive/Extras/resources.dart';
import 'dart:io';

class ChatSendWidget extends StatefulWidget {
  final TextEditingController messageController;
  final FocusNode messageFocus;
  final ScrollController chatScrollController;

  const ChatSendWidget(
      {Key? key,
      required this.messageController,
      required this.messageFocus,
      required this.chatScrollController})
      : super(key: key);

  @override
  _ChatSendWidgetState createState() => _ChatSendWidgetState();
}

class _ChatSendWidgetState extends State<ChatSendWidget> {
  bool isEmojisShown = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Divider(
            height: 1,
            color: Colors.grey.shade500,
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            children: [
              const SizedBox(width: 20),
              if (widget.messageController.text.isEmpty)
                GestureDetector(
                  onTap: () {},
                  child: Image.asset(
                    R.images.attachmentImage,
                    width: 21,
                    height: 21,
                    fit: BoxFit.fill,
                  ),
                ),
              if (widget.messageController.text.isEmpty)
                const SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isEmojisShown = !isEmojisShown;
                  });
                },
                child: Image.asset(
                  R.images.emojiImage,
                  width: 21,
                  height: 21,
                  fit: BoxFit.fill,
                  color:
                      isEmojisShown ? Theme.of(context).primaryColorDark : null,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, right: 8),
                  child: Focus(
                    onFocusChange: (focusStatus) {
                      if (focusStatus) {
                        widget.chatScrollController.animateTo(
                          0.0,
                          curve: Curves.easeOut,
                          duration: const Duration(milliseconds: 300),
                        );
                      }
                    },
                    child: TextField(
                      controller: widget.messageController,
                      focusNode: widget.messageFocus,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(
                                  color: Colors.grey.shade300, width: 1.5)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(
                                  color: Colors.grey.shade300, width: 1.5)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(
                                  color: Colors.grey.shade300, width: 1.5)),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(
                                  color: Colors.grey.shade300, width: 1.5)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(
                                  color: Colors.grey.shade300, width: 1.5)),
                          contentPadding: const EdgeInsets.only(
                              left: 25, right: 25, top: 5, bottom: 5),
                          hintText: "Write Your Message ...".tr(),
                          hintStyle: TextStyle(
                              color: Colors.grey.shade500, fontSize: 15)),
                      style: const TextStyle(fontSize: 15),
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.next,
                      minLines: 1,
                      maxLines: 4,
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ),
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  if (widget.messageController.text.isNotEmpty) {
                    widget.messageFocus.unfocus();
                    print("send message");
                    widget.messageController.text = "";
                    setState(() {});
                  } else {
                    print("record");
                  }
                },
                child: widget.messageController.text.isNotEmpty
                    ? Container(
                        decoration: BoxDecoration(
                          color: widget.messageController.text.isNotEmpty
                              ? const Color(0xff37dabc)
                              : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Padding(
                            padding: EdgeInsets.only(
                                left: 12, right: 8, top: 10, bottom: 10),
                            child: Center(
                              child: Icon(
                                Icons.send,
                                color: Colors.white,
                              ),
                            )),
                      )
                    : Image.asset(
                        R.images.recordMicImage,
                        width: 44,
                        height: 44,
                        fit: BoxFit.fill,
                      ),
              ),
              const SizedBox(
                width: 20,
              ),
            ],
          ),
          SizedBox(
            height: isEmojisShown ? 10 : 40,
          ),
          if (isEmojisShown)
            SizedBox(
              height: 250,
              child: EmojiPicker(
                onEmojiSelected: (category, emoji) {
                  print("Enoji: ${emoji.emoji}");
                  widget.messageController.text = emoji.emoji;
                },
                onBackspacePressed: () {
                 setState(() {
                   isEmojisShown = false;
                 });
                },
                config: Config(
                  columns: 7,
                  emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                  verticalSpacing: 0,
                  horizontalSpacing: 0,
                  initCategory: Category.RECENT,
                  bgColor: Colors.grey.shade100,
                  indicatorColor: Colors.blue,
                  iconColor: Colors.grey,
                  iconColorSelected: Colors.blue,
                  progressIndicatorColor: Colors.blue,
                  showRecentsTab: true,
                  recentsLimit: 28,
                  noRecentsText: "No Recents",
                  noRecentsStyle:
                      const TextStyle(fontSize: 20, color: Colors.black26),
                  tabIndicatorAnimDuration: kTabScrollDuration,
                  // categoryIcons: const CategoryIcons(),
                ),
              ),
            )
        ],
      ),
    );
  }
}
