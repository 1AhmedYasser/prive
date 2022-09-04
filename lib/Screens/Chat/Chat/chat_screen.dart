import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:bot_toast/bot_toast.dart';
import 'package:collection/collection.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:location/location.dart';
import 'package:location/location.dart' as loc;
import 'package:lottie/lottie.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Helpers/utils.dart';
import 'package:prive/Screens/Chat/Calls/group_call_screen.dart';
import 'package:prive/Screens/Chat/Calls/single_call_screen.dart';
import 'package:prive/UltraNetwork/ultra_loading_indicator.dart';
import 'package:prive/Widgets/ChatWidgets/Audio/audio_loading_message_widget.dart';
import 'package:prive/Widgets/ChatWidgets/Audio/audio_player_message.dart';
import 'package:prive/Widgets/ChatWidgets/Audio/record_button_widget.dart';
import 'package:prive/Widgets/ChatWidgets/Location/google_map_view_widget.dart';
import 'package:prive/Widgets/ChatWidgets/Location/map_thumbnail_widget.dart';
import 'package:prive/Widgets/ChatWidgets/chat_menu_widget.dart';
import 'package:prive/Widgets/ChatWidgets/search_text_field.dart';
import 'package:prive/Widgets/ChatWidgets/typing_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../../../Models/Call/call.dart';
import '../../../Models/Call/call_member.dart';
import '../../../Widgets/ChatWidgets/Messages/catalog_message.dart';
import '../../../Widgets/Common/cached_image.dart';
import 'chat_info_screen.dart';
import 'forward_screen.dart';
import 'group_info_screen.dart';
import 'dart:ui' as ui;

class ChatScreen extends StatefulWidget {
  final Channel channel;
  final bool isChannel;

  static Route routeWithChannel(Channel channel, {bool isChannel = false}) =>
      MaterialPageRoute(
        builder: (context) => StreamChannel(
          channel: channel,
          child: ChatScreen(
            channel: channel,
            isChannel: isChannel,
          ),
        ),
      );

  const ChatScreen({Key? key, required this.channel, this.isChannel = false})
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late StreamSubscription<int> unreadCountSubscription;
  TextEditingController messageController = TextEditingController();
  FocusNode messageFocus = FocusNode();
  bool? isAFile;
  String chatBackground = R.images.chatBackground1;
  Message? _quotedMessage;
  FocusNode? _focusNode;
  loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? locationSubscription;
  final GlobalKey<MessageInputState> _messageInputKey = GlobalKey();
  bool isMessageSelectionOn = false;
  List<Message> selectedMessages = [];
  List<Message> searchedMessages = [];
  int selectedSearchIndex = 0;
  Message? initialMessage;
  late Channel channel;
  int randomNumber = Random().nextInt(15);
  bool isMessageSearchOn = false;
  final TextEditingController _messageSearchController =
      TextEditingController();
  Member? otherMember;
  Call? groupCall;
  StreamSubscription? onAddListener;
  StreamSubscription? onChangeListener;
  StreamSubscription? onDeleteListener;
  List<String> kickedCallMembersIds = [];

  @override
  void initState() {
    super.initState();
    channel = StreamChannel.of(context).channel;
    otherMember = widget.channel.state?.members
        .where((element) => element.userId != context.currentUser?.id)
        .firstOrNull;
    Utils.checkForInternetConnection(context);
    _focusNode = FocusNode();
    _getChatBackground();
    unreadCountSubscription = StreamChannel.of(context)
        .channel
        .state!
        .unreadCountStream
        .listen(_unreadCountHandler);
    _listenToFirebaseChanges();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(!isMessageSelectionOn ? 65 : 55),
        child: AppBar(
          toolbarHeight: 90,
          centerTitle: false,
          backgroundColor: Colors.white,
          elevation: 0,
          leadingWidth: 40,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: !isMessageSelectionOn
                ? BackButton(
                    color: const Color(0xff7a8ea6),
                    onPressed: () => Navigator.of(context).popUntil(
                      (route) => route.isFirst,
                    ),
                  )
                : GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedMessages.clear();
                        isMessageSelectionOn = false;
                      });
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.black,
                    ),
                  ),
          ),
          title: !isMessageSelectionOn && !isMessageSearchOn
              ? Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (widget.isChannel == false) {
                          var channel = StreamChannel.of(context).channel;

                          if (channel.isGroup == false) {
                            final currentUser =
                                StreamChat.of(context).currentUser;
                            final otherUser =
                                channel.state!.members.firstWhereOrNull(
                              (element) => element.user!.id != currentUser!.id,
                            );
                            if (otherUser != null) {
                              final pop = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StreamChannel(
                                    channel: channel,
                                    child: ChatInfoScreen(
                                      messageTheme: StreamChatTheme.of(context)
                                          .ownMessageTheme,
                                      user: otherUser.user,
                                    ),
                                  ),
                                ),
                              );

                              if (pop == true) {
                                Navigator.pop(context);
                              }
                            }
                          } else {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StreamChannel(
                                  channel: channel,
                                  child: GroupInfoScreen(
                                    messageTheme: StreamChatTheme.of(context)
                                        .ownMessageTheme,
                                    channel: channel,
                                  ),
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: StreamChannelAvatar(
                        borderRadius: BorderRadius.circular(50),
                        channel: channel,
                        constraints: const BoxConstraints(
                          minWidth: 50,
                          minHeight: 50,
                          maxWidth: 50,
                          maxHeight: 50,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            StreamManager.getChannelName(
                              channel,
                              context.currentUser!,
                            ),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 15, color: Colors.black),
                          ),
                          const SizedBox(height: 2),
                          BetterStreamBuilder<List<Member>>(
                            stream: channel.state!.membersStream,
                            initialData: channel.state!.members,
                            builder: (context, data) => ConnectionStatusBuilder(
                              statusBuilder: (context, status) {
                                switch (status) {
                                  case ConnectionStatus.connected:
                                    return _buildConnectedTitleState(
                                        context, data);
                                  case ConnectionStatus.connecting:
                                    return const Text(
                                      'Connecting',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ).tr();
                                  case ConnectionStatus.disconnected:
                                    return const Text(
                                      'Offline',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ).tr();
                                  default:
                                    return const SizedBox.shrink();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              : isMessageSearchOn == true
                  ? Row(
                      children: [
                        Expanded(
                          child: SearchTextField(
                            controller: _messageSearchController,
                            autoFocus: true,
                            closeOnSearch: false,
                            onChanged: (keyword) async {
                              searchedMessages.clear();
                              if (keyword.isNotEmpty) {
                                SearchMessagesResponse response =
                                    await channel.search(query: keyword);
                                for (var value in response.results) {
                                  searchedMessages.add(value.message);
                                }
                                if (searchedMessages.isNotEmpty) {
                                  searchedMessages
                                      .sortBy((element) => element.createdAt);
                                  initialMessage = searchedMessages.last;
                                  setState(() {});
                                }
                              }
                            },
                            showCloseButton:
                                _messageSearchController.text.isNotEmpty
                                    ? true
                                    : false,
                          ),
                        ),
                      ],
                    )
                  : selectedMessages.isNotEmpty
                      ? Row(
                          children: [
                            Text(
                              "${selectedMessages.length}",
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 17),
                            ),
                          ],
                        )
                      : const Text(
                          "Select Messages",
                          style: TextStyle(color: Colors.black, fontSize: 17),
                        ).tr(),
          actions: isMessageSelectionOn == false && isMessageSearchOn == false
              ? [
                  if (widget.isChannel == false)
                    if (groupCall == null)
                      GestureDetector(
                        onTap: () async {
                          await startCall();
                        },
                        child: Image.asset(
                          R.images.videoCallImage,
                          width: 25,
                        ),
                      ),
                  const SizedBox(width: 20),
                  if (widget.isChannel == false)
                    if (groupCall == null)
                      GestureDetector(
                        onTap: () async {
                          await startCall(isVideo: false);
                        },
                        child: Image.asset(
                          R.images.voiceCallImage,
                          width: 22,
                        ),
                      ),
                  const SizedBox(width: 20),
                  if (widget.isChannel == false)
                    ChatMenuWidget(
                      channel: widget.channel,
                      onOptionSelected: (option) {
                        if (option == 1) {
                          setState(() {
                            _messageSearchController.text = "";
                            isMessageSearchOn = true;
                          });
                        }
                      },
                    ),
                  const SizedBox(width: 20),
                ]
              : isMessageSearchOn
                  ? [
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  initialMessage = null;
                                  isMessageSearchOn = false;
                                });
                              },
                              child: Text(
                                "Cancel".tr(),
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ]
                  : [
                      GestureDetector(
                        child: Icon(
                          Icons.ios_share,
                          color: selectedMessages.isEmpty
                              ? Colors.grey.withOpacity(0.4)
                              : const Color(0xff7a8fa6),
                        ),
                        onTap: () {
                          if (selectedMessages.isNotEmpty) {
                            String shareText = "";
                            for (var message in selectedMessages) {
                              shareText +=
                                  "${message.user?.name}, [${DateFormat('MMM dd, yyyy').format(message.createdAt.toLocal())} at ${DateFormat('hh:mm a').format(message.createdAt.toLocal())}]\n${message.text}\n\n";
                            }
                            Share.share(shareText);
                          }
                        },
                      ),
                      const SizedBox(width: 25),
                      GestureDetector(
                        child: Image.asset(
                          R.images.forwardIcon,
                          color: selectedMessages.isEmpty
                              ? Colors.grey.withOpacity(0.4)
                              : null,
                          width: 20.5,
                        ),
                        onTap: () {
                          if (selectedMessages.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForwardScreen(
                                  selectedMessages: selectedMessages,
                                ),
                              ),
                            ).then((value) {
                              setState(() {
                                selectedMessages.clear();
                                isMessageSelectionOn = false;
                              });
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 30),
                      GestureDetector(
                        child: Image.asset(
                          R.images.deleteChatImage,
                          color: selectedMessages.isEmpty
                              ? Colors.grey.withOpacity(0.4)
                              : null,
                          width: 16.5,
                        ),
                        onTap: () {
                          if (selectedMessages.isNotEmpty) {
                            for (var message in selectedMessages) {
                              widget.channel.deleteMessage(message);
                            }
                            setState(() {
                              selectedMessages.clear();
                              isMessageSelectionOn = false;
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 25),
                    ],
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).popUntil(
            (route) => route.isFirst,
          );
          return false;
        },
        child: StreamChannel(
          channel: channel,
          initialMessageId:
              initialMessage != null ? initialMessage?.id ?? "" : null,
          child: Column(
            children: [
              if (groupCall != null && groupCall?.members?.isNotEmpty == true)
                Container(
                  height: 65,
                  color: Colors.grey.shade300.withOpacity(0.7),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20, left: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              groupCall?.type == "Video"
                                  ? "Video Call"
                                  : "Voice Call",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ).tr(),
                            const SizedBox(height: 5),
                            Text(
                              "${groupCall?.members?.length ?? "0"} ${groupCall?.members?.length == 1 ? "Participant".tr() : "Participants".tr()}",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 100,
                        ),
                        if (groupCall?.members?.isNotEmpty == true)
                          Stack(
                            clipBehavior: Clip.none,
                            children: <Widget>[
                              if ((groupCall?.members?.length ?? 0) >= 1)
                                SizedBox(
                                  height: 44,
                                  width: 44,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: CachedImage(
                                      url:
                                          groupCall?.members?.first.image ?? "",
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              if ((groupCall?.members?.length ?? 0) > 1)
                                Positioned(
                                  right: 25.0,
                                  child: SizedBox(
                                    height: 44,
                                    width: 44,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: CachedImage(
                                        url: groupCall?.members?[1].image ?? "",
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                              if ((groupCall?.members?.length ?? 0) > 2)
                                Positioned(
                                  right: 50.0,
                                  child: SizedBox(
                                    height: 44,
                                    width: 44,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: CachedImage(
                                        url: groupCall?.members?[2].image ?? "",
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        const Expanded(child: SizedBox()),
                        ElevatedButton(
                          onPressed: () async {
                            if (kickedCallMembersIds
                                .contains(context.currentUser?.id)) {
                              Utils.showAlert(
                                context,
                                message: "You Have Been Kicked Out Of This Call"
                                    .tr(),
                                alertImage: R.images.alertInfoImage,
                              );
                            } else {
                              BotToast.removeAll("call_overlay");
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) {
                                  return DraggableScrollableSheet(
                                    minChildSize: 0.5,
                                    initialChildSize: 0.6,
                                    maxChildSize: 0.95,
                                    builder: (_, controller) {
                                      return GroupCallScreen(
                                        isVideo: groupCall?.type == "Video"
                                            ? true
                                            : false,
                                        isJoining: true,
                                        channel: channel,
                                        scrollController: controller,
                                      );
                                    },
                                  );
                                },
                              ).then((value) => checkForGroupCall());
                            }
                            // await Future.delayed(
                            //     const Duration(milliseconds: 300), () {
                            //   setState(() {
                            //     groupCall = null;
                            //   });
                            // });
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).primaryColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("Join").tr(),
                        )
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    MessageListCore(
                      loadingBuilder: (context) {
                        return const UltraLoadingIndicator();
                      },
                      emptyBuilder: (context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          decoration: BoxDecoration(
                            image: isAFile == true
                                ? DecorationImage(
                                    image: FileImage(File(chatBackground)),
                                    fit: BoxFit.fill,
                                  )
                                : DecorationImage(
                                    image: AssetImage(chatBackground),
                                    fit: BoxFit.fill,
                                  ),
                          ),
                          child: isMessageSearchOn
                              ? const SizedBox.shrink()
                              : Center(
                                  child: IgnorePointer(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width /
                                          1.8,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .primaryColorDark
                                            .withOpacity(0.65),
                                        borderRadius: BorderRadius.circular(17),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              "No Messages Yet!",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 18,
                                              ),
                                            ).tr(),
                                            const SizedBox(height: 20),
                                            SizedBox(
                                              width: 120,
                                              height: 120,
                                              child: _buildLottieAnimation(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        );
                      },
                      errorBuilder: (context, error) => Container(),
                      messageListBuilder: (context, messages) {
                        return Directionality(
                          textDirection: ui.TextDirection.ltr,
                          child: StreamMessageListViewTheme(
                            data:
                                StreamMessageListViewTheme.of(context).copyWith(
                              backgroundImage: isAFile == true
                                  ? DecorationImage(
                                      image: FileImage(File(chatBackground)),
                                      fit: BoxFit.cover,
                                    )
                                  : DecorationImage(
                                      image: AssetImage(chatBackground),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            child: StreamMessageListView(
                              key: isMessageSearchOn ? UniqueKey() : null,
                              highlightInitialMessage: true,
                              dateDividerBuilder: (date) {
                                return SizedBox(
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
                                            left: 10,
                                            right: 10,
                                            top: 7,
                                            bottom: 7),
                                        child: Text(
                                          getHeaderDate(context, date),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              messageHighlightColor: Colors.grey.shade300,
                              onMessageSwiped: _reply,
                              messageFilter: defaultFilter,
                              messageBuilder:
                                  (context, details, messages, defaultMessage) {
                                return isMessageSelectionOn
                                    ? Container(
                                        color: selectedMessages.contains(
                                                defaultMessage.message)
                                            ? Colors.green.withOpacity(0.4)
                                            : Colors.transparent,
                                        child: Theme(
                                          data: ThemeData(
                                            checkboxTheme: CheckboxThemeData(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              IgnorePointer(
                                                child: Checkbox(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  value:
                                                      selectedMessages.contains(
                                                              defaultMessage
                                                                  .message)
                                                          ? true
                                                          : false,
                                                  onChanged: (value) {},
                                                ),
                                              ),
                                              Expanded(
                                                child: _buildChatMessage(
                                                  defaultMessage,
                                                  details,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : _buildChatMessage(
                                        defaultMessage, details);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (isMessageSearchOn)
                Container(
                  height: 50,
                  color: const Color(0xffd0d4da).withOpacity(0.7),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 30, right: 15),
                        child: GestureDetector(
                          onTap: () {
                            if (searchedMessages.isNotEmpty &&
                                searchedMessages.length > 1) {
                              if (initialMessage != null) {
                                int index =
                                    searchedMessages.indexOf(initialMessage!);
                                if (index > 0) {
                                  setState(() {
                                    initialMessage =
                                        searchedMessages[index - 1];
                                  });
                                }
                              }
                            }
                          },
                          child: Icon(
                            FontAwesomeIcons.chevronUp,
                            color: _messageSearchController.text.isNotEmpty
                                ? Theme.of(context).primaryColorDark
                                : Colors.grey.shade400,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_messageSearchController.text.isNotEmpty &&
                              searchedMessages.length > 1) {
                            if (initialMessage != null) {}
                            int index =
                                searchedMessages.indexOf(initialMessage!);
                            if (index < searchedMessages.length - 1) {
                              setState(() {
                                initialMessage = searchedMessages[index + 1];
                              });
                            }
                          }
                        },
                        child: Icon(
                          FontAwesomeIcons.chevronDown,
                          color: _messageSearchController.text.isNotEmpty &&
                                  searchedMessages.length > 1
                              ? Theme.of(context).primaryColorDark
                              : Colors.grey.shade400,
                        ),
                      ),
                      if (searchedMessages.isNotEmpty)
                        const SizedBox(width: 40),
                      if (searchedMessages.isNotEmpty)
                        Text(
                          "${initialMessage != null ? searchedMessages.indexOf(initialMessage!) + 1 : 0} of ${searchedMessages.length} Matches",
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey.shade700),
                        )
                    ],
                  ),
                ),
              if (isMessageSearchOn == false)
                MessageInput(
                  showCommandsButton: false,
                  key: _messageInputKey,
                  focusNode: _focusNode,
                  quotedMessage: _quotedMessage,
                  actions: [
                    GestureDetector(
                      onTap: () => onLocationRequestPressed(),
                      child: const Icon(
                        Icons.location_history,
                      ),
                    ),
                  ],
                  onQuotedMessageCleared: () {
                    if (_quotedMessage != null) {
                      setState(() => _quotedMessage = null);
                    }
                  },
                  idleSendButton: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: RecordButton(
                      recordingFinishedCallback: _recordingFinishedCallback,
                    ),
                  ),
                  preMessageSending: (message) {
                    Utils.playSound(R.sounds.sendMessage);
                    return message;
                  },
                  activeSendButton: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xff37dabc),
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
                        ),
                      ),
                    ),
                  ),
                  attachmentThumbnailBuilders: {
                    'location': (context, attachment) => MapThumbnailWidget(
                          lat: attachment.extraData['lat'] as double,
                          long: attachment.extraData['long'] as double,
                        ),
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> startCall({bool isVideo = true}) async {
    if (widget.channel.isGroup) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) {
          return DraggableScrollableSheet(
            minChildSize: 0.5,
            initialChildSize: 0.6,
            maxChildSize: 0.95,
            builder: (_, controller) {
              return GroupCallScreen(
                isVideo: isVideo,
                channel: channel,
                scrollController: controller,
              );
            },
          );
        },
      ).then((value) => checkForGroupCall());
    } else {
      final ref = FirebaseDatabase.instance.ref('Users/${otherMember?.userId}');
      final snapshot = await ref.get();
      if (snapshot.exists) {
        if (snapshot.value as String == "Ended") {
          Utils.logCallStart(
            context,
            context.currentUser?.id ?? "",
            otherMember?.userId ?? "",
            isVideo,
          );
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (BuildContext context, _, __) {
                return SingleCallScreen(
                  channel: channel,
                  isVideo: isVideo,
                );
              },
              transitionsBuilder:
                  (_, Animation<double> animation, __, Widget child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (_) => CupertinoAlertDialog(
              title: const Text("Prive"),
              content: Text(
                  "${otherMember?.user?.name ?? "Member".tr()} ${"is on another call".tr()}"),
              actions: [
                CupertinoDialogAction(
                  child: const Text("Ok").tr(),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          );
        }
      } else {
        Utils.logCallStart(
          context,
          context.currentUser?.id ?? "",
          otherMember?.userId ?? "",
          isVideo,
        );
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (BuildContext context, _, __) {
              return SingleCallScreen(
                channel: channel,
                isVideo: isVideo,
              );
            },
            transitionsBuilder:
                (_, Animation<double> animation, __, Widget child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      }
    }
  }

  Widget _buildLottieAnimation() {
    switch (randomNumber) {
      case 0:
        return Lottie.asset(R.animations.chatHello1);
      case 1:
        return Lottie.asset(R.animations.chatHello2);
      case 2:
        return Lottie.asset(R.animations.chatHello3);
      case 3:
        return Lottie.asset(R.animations.chatHello4);
      case 4:
        return Lottie.asset(R.animations.chatHello5);
      case 5:
        return Lottie.asset(R.animations.chatHello6);
      case 6:
        return Lottie.asset(R.animations.chatHello7);
      case 7:
        return Lottie.asset(R.animations.chatHello8);
      case 8:
        return Lottie.asset(R.animations.chatHello9);
      case 9:
        return Lottie.asset(R.animations.chatHello10);
      case 10:
        return Lottie.asset(R.animations.chatHello11);
      case 11:
        return Lottie.asset(R.animations.chatHello12);
      case 12:
        return Lottie.asset(R.animations.chatHello13);
      case 13:
        return Lottie.asset(R.animations.chatHello14);
      case 14:
        return Lottie.asset(R.animations.chatHello15);
      default:
        return Lottie.asset(R.animations.chatHello1);
    }
  }

  MessageThemeData getMessageTheme(
      BuildContext context, MessageDetails details) {
    return StreamChatTheme.of(context).ownMessageTheme.copyWith(
          messageBackgroundColor:
              details.isMyMessage ? const Color(0xff7a8fa6) : Colors.white,
          messageTextStyle: TextStyle(
            color: details.isMyMessage ? Colors.white : Colors.black,
          ),
        );
  }

  void _recordingFinishedCallback(String path) {
    final uri = Uri.parse(path);
    File file = File(uri.path);
    file.length().then(
      (fileSize) {
        StreamChannel.of(context).channel.sendMessage(
              Message(
                attachments: [
                  Attachment(
                    type: 'voicenote',
                    file: AttachmentFile(
                      size: fileSize,
                      path: uri.path,
                    ),
                  )
                ],
              ),
            );
      },
    );
  }

  Widget _buildChatMessage(
      MessageWidget defaultMessage, MessageDetails details) {
    return defaultMessage.copyWith(
      showUsername: true,
      messageTheme: getMessageTheme(context, details),
      onReplyTap: _reply,
      showReplyMessage: true,
      showPinButton: true,
      showDeleteMessage: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(7),
          topRight: const Radius.circular(7),
          bottomLeft: Radius.circular(details.isMyMessage ? 7 : 0),
          bottomRight: Radius.circular(details.isMyMessage ? 0 : 7),
        ),
        side: BorderSide(
          color: defaultMessage.messageTheme.messageBorderColor ?? Colors.grey,
          width: 0.3,
        ),
      ),
      usernameBuilder: (context, message) {
        if (defaultMessage.message.extraData["isMessageForwarded"] == true) {
          return Row(
            children: [
              Image.asset(
                R.images.forwardIcon,
                width: 15,
              ),
              const SizedBox(width: 10),
              const Text(
                "Forwarded",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ).tr(),
            ],
          );
        } else if (message.user?.id != context.currentUser?.id &&
            widget.isChannel) {
          return Text(
            message.user?.name ?? "",
            style: const TextStyle(fontSize: 11),
          );
        } else if (channel.isGroup) {
          Map<String, dynamic>? nameColors =
              channel.extraData['name_colors'] as Map<String, dynamic>?;
          return Text(
            message.user?.name ?? "",
            overflow: TextOverflow.ellipsis,
            textWidthBasis: TextWidthBasis.longestLine,
            textScaleFactor: 0.95,
            style: TextStyle(
              fontSize: 11,
              color: nameColors != null
                  ? parseColor(nameColors[message.user?.id] as String)
                  : Colors.black,
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
      onMessageTap: (message) {
        if (isMessageSelectionOn) {
          setState(() {
            if (selectedMessages.contains(defaultMessage.message)) {
              selectedMessages.remove(defaultMessage.message);
            } else {
              final isDeletedOrShadowed =
                  defaultMessage.message.isDeleted == true ||
                      defaultMessage.message.shadowed == true;
              if (!isDeletedOrShadowed) {
                selectedMessages.add(defaultMessage.message);
              }
            }
          });
        }
      },
      deletedBottomRowBuilder: (context, message) {
        return const StreamVisibleFootnote();
      },
      customActions: [
        StreamMessageAction(
          leading: Padding(
            padding: const EdgeInsets.only(right: 3),
            child: Image.asset(
              R.images.deleteChatImage,
              width: 15,
              color: Colors.red,
            ),
          ),
          title: const Text(
            'Delete Message',
            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.red),
          ).tr(),
          onTap: (message) {
            Navigator.pop(context);
            showDeletePopup(message);
          },
        ),
        MessageAction(
          leading: const Icon(
            CommunityMaterialIcons.share_outline,
            color: Color(0xff7e7e7e),
          ),
          title: const Text(
            'Forward',
            style: TextStyle(fontWeight: FontWeight.w500),
          ).tr(),
          onTap: (message) {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ForwardScreen(
                  selectedMessages: [message],
                ),
              ),
            );
          },
        ),
        StreamMessageAction(
          leading: const Icon(
            Icons.check_circle_outlined,
            color: Color(0xff7e7e7e),
          ),
          title: const Text(
            'Select',
            style: TextStyle(fontWeight: FontWeight.w500),
          ).tr(),
          onTap: (message) {
            Navigator.pop(context);
            setState(() {
              selectedMessages.add(message);
              isMessageSelectionOn = true;
            });
          },
        ),
      ],
      customAttachmentBuilders: {
        'voicenote': (context, defaultMessage, attachments) {
          final url = attachments.first.assetUrl;
          if (url == null) {
            return const AudioLoadingMessage();
          }
          return AudioPlayerMessage(
            source: AudioSource.uri(Uri.parse(url)),
            id: defaultMessage.id,
          );
        },
        'location': _buildLocationMessage,
        'product': (context, defaultMessage, attachments) {
          return CatalogMessage(
            context: context,
            details: defaultMessage,
          );
        },
        'catalog': (context, defaultMessage, attachments) {
          return CatalogMessage(
            context: context,
            details: defaultMessage,
          );
        },
      },
    );
  }

  void showDeletePopup(Message message) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: Text(
              "Delete Message",
              style: TextStyle(color: Theme.of(context).primaryColorDark),
            ).tr(),
            onPressed: () {
              Navigator.pop(context);
              widget.channel.deleteMessage(message);
            },
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.red),
          ).tr(),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Future<void> _unreadCountHandler(int count) async {
    if (count > 0) {
      await StreamChannel.of(context).channel.markRead();
    }
  }

  Color parseColor(String color) {
    String hex = color.replaceAll("#", "");
    if (hex.isEmpty) hex = "ffffff";
    if (hex.length == 3) {
      hex =
          '${hex.substring(0, 1)}${hex.substring(0, 1)}${hex.substring(1, 2)}${hex.substring(1, 2)}${hex.substring(2, 3)}${hex.substring(2, 3)}';
    }
    Color col = Color(int.parse(hex, radix: 16)).withOpacity(1.0);
    return col;
  }

  Widget _buildConnectedTitleState(
    BuildContext context,
    List<Member>? members,
  ) {
    Widget? alternativeWidget;
    final channel = StreamChannel.of(context).channel;
    final memberCount = channel.memberCount;
    if (memberCount != null && memberCount > 2) {
      var text = 'Members: $memberCount';
      final watcherCount = channel.state?.watcherCount ?? 0;
      if (watcherCount > 0) {
        text = 'watchers $watcherCount';
      }
      alternativeWidget = Text(
        text,
      );
    } else {
      final userId = StreamChatCore.of(context).currentUser?.id;
      final otherMember = members?.firstWhereOrNull(
        (element) => element.userId != userId,
      );

      if (otherMember != null) {
        if (otherMember.user?.online == true) {
          alternativeWidget = const Text(
            'Online',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.green,
            ),
          ).tr();
        } else {
          alternativeWidget = Text(
            getLastSeenDate(
                otherMember.user?.lastActive?.toLocal() ?? DateTime.now()),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          );
        }
      }
    }

    return TypingIndicatorWidget(
      alternativeWidget: alternativeWidget,
    );
  }

  String getLastSeenDate(DateTime data) {
    String lastSeen = "last seen ".tr();
    final now = DateTime.now();
    DateTime lastSeenDate = data.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    final lastSeenDateFormatted =
        DateTime(lastSeenDate.year, lastSeenDate.month, lastSeenDate.day);

    if (lastSeenDateFormatted == today) {
      lastSeen +=
          "${"today at".tr()} ${DateFormat('hh:mm a').format(lastSeenDate)}";
    } else if (lastSeenDateFormatted == yesterday) {
      lastSeen +=
          "${"yesterday at".tr()} ${DateFormat('hh:mm a').format(lastSeenDate)}";
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

  Future<void> _getChatBackground() async {
    isAFile = await Utils.getBool(R.pref.isChosenChatBackgroundAFile);
    chatBackground = await Utils.getString(R.pref.chosenChatBackground) ??
        R.images.chatBackground1;
    setState(() {});
  }

  String getHeaderDate(BuildContext context, DateTime element) {
    final now = DateTime.now();
    DateTime messageDate = element.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    final messageDateFormatted =
        DateTime(element.year, element.month, element.day);

    if (messageDateFormatted == today) {
      return "Today".tr();
    } else if (messageDateFormatted == yesterday) {
      return "Yesterday".tr();
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

  void _reply(Message message) {
    setState(() => _quotedMessage = message);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _focusNode!.requestFocus();
    });
  }

  bool defaultFilter(Message m) {
    var _currentUser = StreamChat.of(context).currentUser;
    final isMyMessage = m.user?.id == _currentUser?.id;
    final isDeletedOrShadowed = m.isDeleted == true || m.shadowed == true;
    if (isDeletedOrShadowed && !isMyMessage) return false;
    return true;
  }

  @override
  void dispose() {
    unreadCountSubscription.cancel();
    locationSubscription?.cancel();
    _focusNode!.dispose();
    onAddListener?.cancel();
    onChangeListener?.cancel();
    onDeleteListener?.cancel();
    super.dispose();
  }

  Future<void> onLocationRequestPressed() async {
    LocationData _locationData = await location.getLocation();
    _messageInputKey.currentState?.addAttachment(
      Attachment(
        type: 'location',
        uploadState: const UploadState.success(),
        extraData: {
          'lat': _locationData.latitude,
          'long': _locationData.longitude,
        },
      ),
    );
    return;
  }

  Future<void> startLocationTracking(
    String messageId,
    String attachmentId,
  ) async {
    locationSubscription = location.onLocationChanged.listen(
      (loc.LocationData event) {
        widget.channel.sendEvent(
          Event(
            type: 'location_update',
            extraData: {
              'lat': event.latitude,
              'long': event.longitude,
            },
          ),
        );
      },
    );

    return;
  }

  void cancelLocationSubscription() => locationSubscription?.cancel();

  Widget _buildLocationMessage(
    BuildContext context,
    Message details,
    List<Attachment> _,
  ) {
    final username = details.user!.name;
    final lat = details.attachments.first.extraData['lat'] as double;
    final long = details.attachments.first.extraData['long'] as double;
    return InkWell(
      onTap: () {
        Utils.openMapsSheet(context, lat, long, () {
          Navigator.pop(context);
          startLocationTracking(details.id, details.attachments.first.id);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => GoogleMapsViewWidget(
                onBack: cancelLocationSubscription,
                message: details,
                channelName: username,
                channel: widget.channel,
              ),
            ),
          );
        });
      },
      child: wrapAttachmentWidget(
        context,
        MapThumbnailWidget(
          lat: lat,
          long: long,
        ),
        const RoundedRectangleBorder(),
        true,
      ),
    );
  }

  void checkForGroupCall() async {
    final databaseReference =
        FirebaseDatabase.instance.ref("GroupCalls/${widget.channel.id}");

    final snapshot = await databaseReference.get();
    if (snapshot.exists) {
      Map<dynamic, dynamic>? groupCallResponse = {};
      groupCallResponse = (snapshot.value as Map<dynamic, dynamic>);

      String? ownerId = groupCallResponse['ownerId'];
      String? type = groupCallResponse['type'];
      List<CallMember>? members = [];
      List<CallMember>? kickedMembers = [];

      Map<dynamic, dynamic>? membersList =
          (groupCallResponse['members'] as Map<dynamic, dynamic>?) ?? {};
      membersList.forEach((key, value) {
        members.add(
          CallMember(
            id: value['id'],
            name: value['name'],
            image: value['image'],
            phone: value['phone'],
            isHeadphonesOn: value['isHeadphonesOn'],
            hasPermissionToSpeak: value['hasPermissionToSpeak'],
            isMicOn: value['isMicOn'],
            isVideoOn: value['isVideoOn'],
          ),
        );
      });

      Map<dynamic, dynamic>? kickedMembersList =
          (groupCallResponse['kickedMembers'] as Map<dynamic, dynamic>?) ?? {};
      kickedMembersList.forEach((key, value) {
        kickedMembers.add(
          CallMember(
            id: value['id'],
            name: value['name'],
            image: value['image'],
            phone: value['phone'],
            isMicOn: value['isMicOn'],
            isHeadphonesOn: value['isHeadphonesOn'],
            hasPermissionToSpeak: value['hasPermissionToSpeak'],
            isVideoOn: value['isVideoOn'],
          ),
        );
      });

      if (membersList.isEmpty == true) {
        groupCall = null;
      } else {
        groupCall = Call(
          ownerId: ownerId,
          type: type,
          members: members,
          kickedMembers: kickedMembers,
        );
        kickedCallMembersIds =
            groupCall?.kickedMembers?.map((e) => e.id ?? "").toList() ?? [];
      }
      setState(() {});
    } else {
      groupCall = null;
      setState(() {});
    }
  }

  void _listenToFirebaseChanges() {
    final databaseReference =
        FirebaseDatabase.instance.ref("GroupCalls/${widget.channel.id}");
    onAddListener = databaseReference.onChildAdded.listen((event) {
      checkForGroupCall();
    });
    onChangeListener = databaseReference.onChildChanged.listen((event) {
      checkForGroupCall();
    });
    onChangeListener = databaseReference.onChildRemoved.listen((event) {
      checkForGroupCall();
    });
  }
}
