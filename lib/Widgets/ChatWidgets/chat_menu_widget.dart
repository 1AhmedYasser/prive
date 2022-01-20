import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:prive/Extras/resources.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChatMenuWidget extends StatefulWidget {
  final Channel channel;

  const ChatMenuWidget({
    required this.channel,
    Key? key,
  }) : super(key: key);

  @override
  State<ChatMenuWidget> createState() => _ChatMenuWidgetState();
}

class _ChatMenuWidgetState extends State<ChatMenuWidget> {
  List<Map> chatMoreMenu = [];
  List<String> chatMoreMenuTitles = [
    "Search",
    "Clear History",
    "Mute",
    "Delete Chat"
  ];
  List<String> chatMoreMenuIcons = [
    R.images.searchChatImage,
    R.images.clearHistoryImage,
    R.images.muteNotificationsImage,
    R.images.deleteChatImage
  ];

  @override
  void initState() {
    fillMenu();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CoolDropdown(
      dropdownList: chatMoreMenu,
      dropdownItemPadding: EdgeInsets.zero,
      onChange: (dropdownItem) {
        switch (dropdownItem['value']) {
          case "Search":
            break;
          case "Clear History":
            for (Message message in widget.channel.state?.messages ?? []) {
              if (message.isDeleted == false) {
                widget.channel.deleteMessage(message, hard: true);
              }
            }
            break;
          case "Mute":
            widget.channel.mute();
            break;
          case "UnMute":
            widget.channel.unmute();
            break;
          case "Delete Chat":
            _showDeleteChatDialog();
            break;
          default:
            break;
        }
      },
      resultHeight: 62,
      resultWidth: 30,
      dropdownWidth: 170,
      dropdownHeight: 150,
      dropdownItemHeight: 30,
      dropdownItemGap: 10,
      labelIconGap: 15,
      onOpen: (open) {
        if (widget.channel.isMuted) {
          setState(() {
            chatMoreMenuTitles[2] = "UnMute";
            fillMenu();
          });
        } else {
          setState(() {
            chatMoreMenuTitles[2] = "Mute";
            fillMenu();
          });
        }
      },
      dropdownItemTopGap: 0,
      resultIcon: SizedBox(
        width: 21,
        height: 21,
        child: Image.asset(R.images.chatMoreImage),
      ),
      resultBD: const BoxDecoration(color: Colors.transparent),
      resultIconLeftGap: 0,
      dropdownItemBottomGap: 0,
      resultPadding: EdgeInsets.zero,
      resultIconRotation: true,
      resultIconRotationValue: 1,
      dropdownItemReverse: true,
      isDropdownLabel: true,
      unselectedItemTS: const TextStyle(
        fontSize: 15,
        color: Color(0xff232323),
      ),
      selectedItemTS: const TextStyle(
        fontSize: 15,
        color: Color(0xff232323),
      ),
      dropdownItemMainAxis: MainAxisAlignment.start,
      isResultLabel: false,
      dropdownItemAlign: Alignment.centerLeft,
      isResultIconLabel: false,
      dropdownPadding: const EdgeInsets.all(20),
      isTriangle: false,
      selectedItemPadding: EdgeInsets.zero,
      resultAlign: Alignment.center,
      resultMainAxis: MainAxisAlignment.center,
      selectedItemBD: const BoxDecoration(color: Colors.transparent),
      triangleWidth: 0,
      triangleHeight: 0,
      triangleAlign: 'center',
      dropdownAlign: 'right',
      gap: 10,
    );
  }

  void fillMenu() {
    chatMoreMenu.clear();
    for (var i = 0; i < chatMoreMenuTitles.length; i++) {
      chatMoreMenu.add({
        'label': chatMoreMenuTitles[i],
        'value': chatMoreMenuTitles[i],
        'icon': SizedBox(
          width: 18,
          height: 18,
          child: Image.asset(
            chatMoreMenuIcons[i],
          ),
        )
      });
    }
  }

  void _showDeleteChatDialog() async {
    final res = await showConfirmationDialog(
      context,
      title: "Delete Conversation",
      okText: "Delete",
      question: "Are You Sure ?",
      cancelText: "Cancel",
      icon: StreamSvgIcon.delete(
        color: StreamChatTheme.of(context).colorTheme.accentError,
      ),
    );
    var channel = StreamChannel.of(context).channel;
    if (res == true) {
      await channel.delete().then((value) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      });
    }
  }
}
