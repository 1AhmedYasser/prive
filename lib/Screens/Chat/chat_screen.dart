import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Helpers/utils.dart';
import 'package:prive/UltraNetwork/ultra_loading_indicator.dart';
import 'package:prive/Widgets/ChatWidgets/Audio/audio_loading_message_widget.dart';
import 'package:prive/Widgets/ChatWidgets/Audio/audio_player_message.dart';
import 'package:prive/Widgets/ChatWidgets/chat_menu_widget.dart';
import 'package:prive/Widgets/ChatWidgets/Location/google_map_view_widget.dart';
import 'package:prive/Widgets/ChatWidgets/Location/map_thumbnail_widget.dart';
import 'package:prive/Widgets/ChatWidgets/Audio/record_button_widget.dart';
import 'package:prive/Widgets/ChatWidgets/typing_indicator.dart';
import 'package:prive/Widgets/Common/cached_image.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatScreen extends StatefulWidget {
  final Channel channel;

  static Route routeWithChannel(Channel channel) => MaterialPageRoute(
        builder: (context) => StreamChannel(
          channel: channel,
          child: ChatScreen(
            channel: channel,
          ),
        ),
      );

  const ChatScreen({Key? key, required this.channel}) : super(key: key);

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
  loc.Location? location;
  StreamSubscription<loc.LocationData>? locationSubscription;
  final GlobalKey<MessageInputState> _messageInputKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _getChatBackground();

    unreadCountSubscription = StreamChannel.of(context)
        .channel
        .state!
        .unreadCountStream
        .listen(_unreadCountHandler);
  }

  @override
  Widget build(BuildContext context) {
    final channel = StreamChannel.of(context).channel;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: AppBar(
          toolbarHeight: 90,
          centerTitle: false,
          backgroundColor: Colors.white,
          elevation: 0,
          leadingWidth: 40,
          leading: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: BackButton(
              color: Color(0xff7a8ea6),
            ),
          ),
          title: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: CachedImage(
                    url: StreamManager.getChannelImage(
                          channel,
                          context.currentUser!,
                        ) ??
                        "",
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
                      style: const TextStyle(fontSize: 15, color: Colors.black),
                    ),
                    const SizedBox(height: 2),
                    BetterStreamBuilder<List<Member>>(
                      stream: channel.state!.membersStream,
                      initialData: channel.state!.members,
                      builder: (context, data) => ConnectionStatusBuilder(
                        statusBuilder: (context, status) {
                          switch (status) {
                            case ConnectionStatus.connected:
                              return _buildConnectedTitleState(context, data);
                            case ConnectionStatus.connecting:
                              return const Text(
                                'Connecting',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              );
                            case ConnectionStatus.disconnected:
                              return const Text(
                                'Offline',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              );
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
          ),
          actions: [
            GestureDetector(
              onTap: () {},
              child: Image.asset(
                R.images.videoCallImage,
                width: 25,
              ),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: () {},
              child: Image.asset(
                R.images.voiceCallImage,
                width: 22,
              ),
            ),
            const SizedBox(width: 20),
            const ChatMenuWidget(),
            const SizedBox(width: 20),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: MessageListCore(
              loadingBuilder: (context) {
                return const UltraLoadingIndicator();
              },
              emptyBuilder: (context) {
                return isAFile == true
                    ? SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Image.file(
                          File(chatBackground),
                          fit: BoxFit.fill,
                        ),
                      )
                    : SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Image.asset(
                          chatBackground,
                          fit: BoxFit.fill,
                        ),
                      );
              },
              errorBuilder: (context, error) => Container(),
              messageListBuilder: (context, messages) {
                return MessageListViewTheme(
                  data: MessageListViewTheme.of(context).copyWith(
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
                  child: MessageListView(
                    highlightInitialMessage: false,
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
                                  left: 10, right: 10, top: 7, bottom: 7),
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
                    messageHighlightColor: Colors.transparent,
                    onMessageSwiped: _reply,
                    messageFilter: defaultFilter,
                    messageBuilder:
                        (context, details, messages, defaultMessage) {
                      return defaultMessage.copyWith(
                        showUsername: false,
                        messageTheme: getMessageTheme(context, details),
                        onReplyTap: _reply,
                        showUserAvatar: DisplayWidget.gone,
                        showReplyMessage: true,
                        showPinButton: true,
                        deletedBottomRowBuilder: (context, message) {
                          return const VisibleFootnote();
                        },
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
                          'location': _buildLocationMessage
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
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
              setState(() => _quotedMessage = null);
              _focusNode!.unfocus();
            },
            idleSendButton: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: RecordButton(
                recordingFinishedCallback: _recordingFinishedCallback,
              ),
            ),
            activeSendButton: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xff37dabc),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Padding(
                  padding:
                      EdgeInsets.only(left: 12, right: 8, top: 10, bottom: 10),
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
                  )
            },
          ),
        ],
      ),
    );
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

  Future<void> _unreadCountHandler(int count) async {
    if (count > 0) {
      await StreamChannel.of(context).channel.markRead();
    }
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
          );
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

  void _reply(Message message) {
    setState(() => _quotedMessage = message);
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
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
    _focusNode!.dispose();
    super.dispose();
  }

  Future<bool> setupLocation() async {
    location ??= loc.Location();
    var _serviceEnabled = await location!.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location!.requestService();
      if (!_serviceEnabled) {
        return false;
      }
    }

    var _permissionGranted = await location!.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location!.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  Future<void> onLocationRequestPressed() async {
    final canSendLocation = await setupLocation();
    if (canSendLocation != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "We can't access your location at this time. Did you allow location access?"),
        ),
      );
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    //final locationData = loc.Location();
    _messageInputKey.currentState?.addAttachment(
      Attachment(
        type: 'location',
        uploadState: const UploadState.success(),
        extraData: {
          'lat': position.latitude,
          'long': position.longitude,
        },
      ),
    );
    return;
  }

  Future<void> startLocationTracking(
    String messageId,
    String attachmentId,
  ) async {
    final canSendLocation = await setupLocation();
    if (canSendLocation != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "We can't access your location at this time. Did you allow location access?"),
        ),
      );
    }

    locationSubscription = location!.onLocationChanged.listen(
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
}
