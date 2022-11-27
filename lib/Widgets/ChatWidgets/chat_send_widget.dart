import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:prive/Resources/images.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class ChatSendWidget extends StatefulWidget {
  final TextEditingController messageController;
  final FocusNode messageFocus;
  final ScrollController chatScrollController;

  const ChatSendWidget(
      {Key? key, required this.messageController, required this.messageFocus, required this.chatScrollController})
      : super(key: key);

  @override
  State<ChatSendWidget> createState() => _ChatSendWidgetState();
}

class _ChatSendWidgetState extends State<ChatSendWidget> {
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
              GestureDetector(
                onTap: () {},
                child: Image.asset(
                  Images.attachmentImage,
                  width: 21,
                  height: 21,
                  fit: BoxFit.fill,
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
                          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.only(left: 25, right: 25, top: 5, bottom: 5),
                        hintText: 'Write Your Message ...'.tr(),
                        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                      ),
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
                    StreamChannel.of(context).channel.sendMessage(
                          Message(text: widget.messageController.text),
                        );
                    widget.messageController.text = '';
                    setState(() {});
                  } else {
                    print('record');
                  }
                },
                child: widget.messageController.text.isNotEmpty
                    ? Container(
                        decoration: BoxDecoration(
                          color:
                              widget.messageController.text.isNotEmpty ? const Color(0xff37dabc) : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 12, right: 8, top: 10, bottom: 10),
                          child: Center(
                            child: Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    : Image.asset(
                        Images.recordMicImage,
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
          const SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }
}
