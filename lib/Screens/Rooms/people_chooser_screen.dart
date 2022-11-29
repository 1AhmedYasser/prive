import 'dart:async';
import 'dart:convert';

import 'package:app_settings/app_settings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lottie/lottie.dart';
import 'package:prive/Helpers/Utils.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Models/Rooms/room.dart';
import 'package:prive/Models/Rooms/room_user.dart';
import 'package:prive/Resources/animations.dart';
import 'package:prive/Resources/shared_pref.dart';
import 'package:prive/Screens/MainMenu/new_group_screen.dart';
import 'package:prive/Screens/Rooms/room_screen.dart';
import 'package:prive/UltraNetwork/ultra_loading_indicator.dart';
import 'package:prive/Widgets/AppWidgets/channels_empty_widgets.dart';
import 'package:prive/Widgets/ChatWidgets/search_text_field.dart';
import 'package:prive/Widgets/Common/cached_image.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class PeopleChooserScreen extends StatefulWidget {
  final String roomName;
  final String roomDescription;
  final bool isNow;
  final DateTime? selectedDateTime;
  const PeopleChooserScreen({
    Key? key,
    this.roomName = '',
    this.roomDescription = '',
    this.isNow = true,
    this.selectedDateTime,
  }) : super(key: key);

  @override
  State<PeopleChooserScreen> createState() => _PeopleChooserScreenState();
}

class _PeopleChooserScreenState extends State<PeopleChooserScreen> with TickerProviderStateMixin {
  TextEditingController? _controller;
  final _selectedUsers = <User>{};
  bool _permissionDenied = false;
  Timer? _debounce;
  List<Contact> phoneContacts = [];
  List<User> users = [];
  List<User> allUsers = [];
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
    _getContacts();
    _controller = TextEditingController()..addListener(_userNameListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StreamChatTheme.of(context).colorTheme.appBg,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
        ),
        leading: const BackButton(
          color: Color(0xff7a8fa6),
        ),
        title: const Text(
          'Choose People',
          style: TextStyle(
            fontSize: 23,
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ).tr(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: const Icon(Icons.done),
              color: _selectedUsers.isNotEmpty ? Theme.of(context).primaryColor : Colors.grey,
              onPressed: () async {
                RoomUser owner = RoomUser(
                  id: context.currentUser?.id ?? '',
                  name: context.currentUser?.name ?? '',
                  image: context.currentUser?.image ?? '',
                  isOwner: true,
                  isSpeaker: true,
                  hasPermissionToSpeak: true,
                  isListener: false,
                  phone: context.currentUser?.extraData['phone'] as String,
                  isHandRaised: false,
                  isMicOn: true,
                );

                Map<String, Map<String, dynamic>> roomContacts = {};
                for (var user in _selectedUsers) {
                  roomContacts[user.id] = RoomUser(
                    id: user.id,
                    name: user.name,
                    image: user.image,
                    isOwner: false,
                    isSpeaker: false,
                    hasPermissionToSpeak: false,
                    isListener: true,
                    phone: user.extraData['phone'] as String,
                    isHandRaised: false,
                    isMicOn: false,
                  ).toJson();
                }
                String roomId =
                    DateFormat('yyyyMMddhhmmmss', 'en').format(widget.selectedDateTime ?? DateTime.now()).toString();
                if (widget.isNow) {
                  DatabaseReference ref = FirebaseDatabase.instance.ref("rooms/${context.currentUser?.id ?? ""}");
                  await ref.set({
                    'topic': widget.roomName,
                    'description': widget.roomDescription,
                    'owner': owner.toJson(),
                    'speakers': {owner.id: owner.toJson()},
                    'listeners': {},
                    'room_contacts': roomContacts,
                    'raised_hands': {},
                    'roomId': roomId
                  });
                  if (mounted) {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoomScreen(
                          isNewRoomCreation: true,
                          room: Room(
                            roomId: roomId,
                            topic: widget.roomName,
                            speakers: [owner],
                            listeners: [],
                            roomContacts: [],
                            raisedHands: [],
                          ),
                        ),
                      ),
                    );
                  }
                } else {
                  DateTime? dateTime = widget.selectedDateTime;
                  if (dateTime?.isBefore(DateTime.now()) == true) {
                    dateTime = DateTime.now();
                  }
                  Navigator.pop(context);
                  DatabaseReference ref = FirebaseDatabase.instance.ref(
                    "upcoming_rooms/${context.currentUser?.id ?? ""}/${DateFormat('yyyyMMddhhmmmss').format(dateTime ?? DateTime.now()).toString()}",
                  );
                  await ref.set({
                    'topic': widget.roomName,
                    'description': widget.roomDescription,
                    'owner': owner.toJson(),
                    'speakers': {owner.id: owner.toJson()},
                    'listeners': {},
                    'room_contacts': roomContacts,
                    'raised_hands': {},
                    'date_time': dateTime.toString()
                  });
                }
              },
            ),
          ),
        ],
      ),
      body: StreamConnectionStatusBuilder(
        statusBuilder: (context, status) {
          String statusString = '';
          bool showStatus = true;

          switch (status) {
            case ConnectionStatus.connected:
              statusString = 'Connected'.tr();
              showStatus = false;
              break;
            case ConnectionStatus.connecting:
              statusString = 'Connecting'.tr();
              break;
            case ConnectionStatus.disconnected:
              statusString = 'Disconnected'.tr();
              break;
          }
          return StreamInfoTile(
            showMessage: showStatus,
            tileAnchor: Alignment.topCenter,
            childAnchor: Alignment.topCenter,
            message: statusString,
            child: NestedScrollView(
              floatHeaderSlivers: true,
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20, left: 25, right: 25, bottom: 0),
                      child: Center(
                        child: Text(
                          widget.roomName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 10),
                      child: SearchTextField(
                        controller: _controller,
                        hintText: 'Search'.tr(),
                        showCloseButton: false,
                        onChanged: (value) {
                          if (value.isEmpty) {
                            setState(() {
                              users = allUsers;
                            });
                          } else {
                            setState(() {
                              users = allUsers
                                  .where(
                                    (element) =>
                                        element.name.toLowerCase().contains(_controller?.text.toLowerCase() ?? ''),
                                  )
                                  .toList();
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: HeaderDelegate(
                      height: 32,
                      child: Container(
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          gradient: StreamChatTheme.of(context).colorTheme.bgGradient,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 8,
                          ),
                          child: Text(
                            _controller?.text.isNotEmpty == true
                                ? '${"Matches For".tr()} "${_controller?.text.trim()}"'
                                : 'Start The Room With'.tr(),
                            style: TextStyle(
                              color: StreamChatTheme.of(context).colorTheme.textLowEmphasis,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: phoneContacts.isNotEmpty
                  ? users.isNotEmpty
                      ? RefreshIndicator(
                          onRefresh: () => Future.sync(() => _getContacts()),
                          child: AnimationLimiter(
                            child: ListView.separated(
                              itemBuilder: (context, index) {
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  child: SlideAnimation(
                                    horizontalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: InkWell(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () {
                                          setState(() {
                                            if (_selectedUsers.contains(users[index])) {
                                              _selectedUsers.remove(users[index]);
                                            } else {
                                              _selectedUsers.add(users[index]);
                                            }
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 0),
                                          child: Column(
                                            children: [
                                              const SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(50),
                                                    child: SizedBox(
                                                      height: 50,
                                                      width: 50,
                                                      child: CachedImage(
                                                        url: users[index].image ?? '',
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 13),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        users[index].name,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 3),
                                                      Text(
                                                        users[index].online
                                                            ? 'Online'.tr()
                                                            : "${"Last Seen".tr()} ${DateFormat('d MMM').format(users[index].lastActive ?? DateTime.now())} ${"at".tr()} ${DateFormat('hh:mm a').format(
                                                                users[index].lastActive ?? DateTime.now(),
                                                              )}",
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.w400,
                                                          color: users[index].online ? Colors.green : Colors.grey,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (_selectedUsers.contains(users[index]))
                                                    const Expanded(
                                                      child: SizedBox(),
                                                    ),
                                                  if (_selectedUsers.contains(users[index]))
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: 20),
                                                      child: Icon(
                                                        Icons.check_circle,
                                                        color: Theme.of(context).primaryColor,
                                                      ),
                                                    )
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return Divider(
                                  height: 0,
                                  color: Colors.grey.shade300,
                                );
                              },
                              itemCount: users.length,
                            ),
                          ),
                        )
                      : ChannelsEmptyState(
                          animationController: _animationController,
                          title: 'No Contacts Found'.tr(),
                          message: '',
                        )
                  : _permissionDenied == false
                      ? const UltraLoadingIndicator()
                      : SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(height: 100),
                              SizedBox(
                                height: 200,
                                child: Lottie.asset(
                                  Animations.contactsPermission,
                                  repeat: false,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "${"Contacts Permission is needed".tr()}\n${"To view your contacts".tr()}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () => AppSettings.openAppSettings(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  elevation: 0,
                                  minimumSize: Size(
                                    MediaQuery.of(context).size.width / 2.5,
                                    50,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Go To Settings',
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                                ).tr(),
                              )
                            ],
                          ),
                        ),
            ),
          );
        },
      ),
    );
  }

  _getContacts() async {
    String? myContacts = await Utils.getString(SharedPref.myContacts);
    if (myContacts != null && myContacts.isNotEmpty == true && myContacts != '[]') {
      List<dynamic> usersMapList = jsonDecode(await Utils.getString(SharedPref.myContacts) ?? '');
      List<User> myUsers = [];
      for (var user in usersMapList) {
        myUsers.add(
          User(
            id: user['id'],
            name: user['name'],
            image: user['image'],
            extraData: {'phone': user['phone'], 'shadow_banned': false},
          ),
        );
      }
      users = myUsers;
      allUsers = users;
      phoneContacts = users.isNotEmpty ? [Contact()] : [];
      setState(() {});
    } else {
      if (!await FlutterContacts.requestPermission(readonly: true)) {
        setState(() => _permissionDenied = true);
      } else {
        List contacts = [];
        if (mounted) {
          contacts = await Utils.fetchContacts(context);
        }
        users = contacts.first;
        allUsers = users;
        phoneContacts = contacts[1];
        setState(() {});
      }
    }
  }

  void _userNameListener() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 0), () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller?.clear();
    _controller?.removeListener(_userNameListener);
    _controller?.dispose();
    super.dispose();
  }
}
