import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:app_settings/app_settings.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lottie/lottie.dart';
import 'package:prive/UltraNetwork/ultra_network.dart';
import 'package:prive/Widgets/ChatWidgets/search_text_field.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../../../Extras/resources.dart';
import '../../../Helpers/Utils.dart';
import '../../../Models/Rooms/room.dart';
import '../../../UltraNetwork/ultra_constants.dart';
import '../../../UltraNetwork/ultra_loading_indicator.dart';
import '../../Common/cached_image.dart';
import '../channels_empty_widgets.dart';

class RoomInvitationWidget extends StatefulWidget {
  final List<String> roomContacts;
  final bool isSpeaker;
  final String roomRef;
  final Room? room;
  const RoomInvitationWidget(
      {Key? key,
      this.roomContacts = const [],
      this.isSpeaker = false,
      required this.roomRef,
      this.room})
      : super(key: key);

  @override
  State<RoomInvitationWidget> createState() => _RoomInvitationWidgetState();
}

class _RoomInvitationWidgetState extends State<RoomInvitationWidget>
    with TickerProviderStateMixin {
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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25),
          topLeft: Radius.circular(25),
        ),
      ),
      height: MediaQuery.of(context).size.height / 1.5,
      child: ConnectionStatusBuilder(
        statusBuilder: (context, status) {
          String statusString = '';
          bool showStatus = true;

          switch (status) {
            case ConnectionStatus.connected:
              statusString = "Connected";
              showStatus = false;
              break;
            case ConnectionStatus.connecting:
              statusString = "Connecting";
              break;
            case ConnectionStatus.disconnected:
              statusString = "Disconnected";
              break;
          }
          return Stack(
            children: [
              InfoTile(
                showMessage: showStatus,
                tileAnchor: Alignment.topCenter,
                childAnchor: Alignment.topCenter,
                message: statusString,
                child: SingleChildScrollView(
                  physics: phoneContacts.isNotEmpty
                      ? const NeverScrollableScrollPhysics()
                      : const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 30, left: 30, right: 30, bottom: 0),
                        child: Text(
                          widget.isSpeaker
                              ? "Invite A Speaker"
                              : "Invite People To The Room",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 20, left: 15, right: 15),
                        child: SizedBox(
                          height: 60,
                          child: SearchTextField(
                            controller: _controller,
                            hintText: "Search",
                            showCloseButton: false,
                            borderRadius: 12,
                            onChanged: (value) {
                              if (value.isEmpty) {
                                setState(() {
                                  users = allUsers;
                                });
                              } else {
                                setState(() {
                                  users = allUsers
                                      .where(
                                        (element) => element.name
                                            .toLowerCase()
                                            .contains(_controller?.text
                                                    .toLowerCase() ??
                                                ""),
                                      )
                                      .toList();
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      phoneContacts.isNotEmpty
                          ? users.isNotEmpty
                              ? SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height / 2.5,
                                  child: RefreshIndicator(
                                    onRefresh: () =>
                                        Future.sync(() => _getContacts()),
                                    child: AnimationLimiter(
                                      child: MediaQuery.removePadding(
                                        context: context,
                                        removeTop: true,
                                        removeBottom: true,
                                        child: ListView.separated(
                                          itemBuilder: (context, index) {
                                            return AnimationConfiguration
                                                .staggeredList(
                                              position: index,
                                              child: SlideAnimation(
                                                horizontalOffset: 50.0,
                                                child: FadeInAnimation(
                                                  child: InkWell(
                                                    splashColor:
                                                        Colors.transparent,
                                                    highlightColor:
                                                        Colors.transparent,
                                                    onTap: () {
                                                      setState(() {
                                                        if (_selectedUsers
                                                            .contains(
                                                                users[index])) {
                                                          _selectedUsers.remove(
                                                              users[index]);
                                                        } else {
                                                          _selectedUsers.add(
                                                              users[index]);
                                                        }
                                                      });
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 25,
                                                              right: 25,
                                                              bottom: 0),
                                                      child: Column(
                                                        children: [
                                                          const SizedBox(
                                                              height: 10),
                                                          Row(
                                                            children: [
                                                              ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            50),
                                                                child: SizedBox(
                                                                  height: 50,
                                                                  width: 50,
                                                                  child:
                                                                      CachedImage(
                                                                    url: users[index]
                                                                            .image ??
                                                                        "",
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 13),
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    users[index]
                                                                        .name,
                                                                    style:
                                                                        const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          3),
                                                                  Text(
                                                                    users[index]
                                                                            .online
                                                                        ? "Online"
                                                                        : "Last Seen ${DateFormat('d MMM').format(users[index].lastActive ?? DateTime.now())} at ${DateFormat('hh:mm a').format(
                                                                            users[index].lastActive ??
                                                                                DateTime.now(),
                                                                          )}",
                                                                    style:
                                                                        TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      color: users[index].online
                                                                          ? Colors
                                                                              .green
                                                                          : Colors
                                                                              .grey,
                                                                      fontSize:
                                                                          13,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              if (_selectedUsers
                                                                  .contains(users[
                                                                      index]))
                                                                const Expanded(
                                                                  child:
                                                                      SizedBox(),
                                                                ),
                                                              if (_selectedUsers
                                                                  .contains(users[
                                                                      index]))
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      right:
                                                                          20),
                                                                  child: Icon(
                                                                    Icons
                                                                        .check_circle,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColor,
                                                                  ),
                                                                )
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
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
                                    ),
                                  ),
                                )
                              : ChannelsEmptyState(
                                  animationController: _animationController,
                                  title: "No Contacts Found",
                                  message: "",
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
                                          R.animations.contactsPermission,
                                          repeat: false,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        "Contacts Permission is needed\nTo view your contacts",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      ElevatedButton(
                                        onPressed: () =>
                                            AppSettings.openAppSettings(),
                                        child: const Text(
                                          "Go To Settings",
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          primary:
                                              Theme.of(context).primaryColor,
                                          elevation: 0,
                                          minimumSize: Size(
                                            MediaQuery.of(context).size.width /
                                                2.5,
                                            50,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 50,
                right: 35,
                left: 35,
                child: ElevatedButton(
                  onPressed: () {
                    final ref = FirebaseDatabase.instance.ref(widget.roomRef);
                    for (var user in _selectedUsers) {
                      ref.child(user.id).update({
                        "id": user.id,
                        "name": user.name,
                        "image": user.image,
                        "isSpeaker": widget.isSpeaker,
                        "isListener": !widget.isSpeaker,
                        "phone": user.extraData['phone'],
                        "isHandRaised": false,
                        "isOwner": false,
                        "isMicOn": widget.isSpeaker,
                      });
                    }
                    Navigator.pop(context);
                    _sendInvitations();
                  },
                  child: const Text(
                    "Send Invitation",
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                    minimumSize: const Size(0, 50),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  void _sendInvitations() {
    UltraNetwork.request(
      context,
      sendInvitations,
      showLoadingIndicator: false,
      showError: false,
      cancelToken: CancelToken(),
      formData: FormData.fromMap({
        "Ownername": widget.room?.owner?.name,
        "Roomname": widget.room?.topic,
        "IsSpeaker": widget.isSpeaker ? 1 : 0,
        "UsersIds": _selectedUsers.map((e) => e.id).toList().join(","),
      }),
    );
  }

  _getContacts() async {
    String? myContacts = await Utils.getString(R.pref.myContacts);
    if (myContacts != null && myContacts.isNotEmpty == true) {
      List<dynamic> usersMapList =
          jsonDecode(await Utils.getString(R.pref.myContacts) ?? "");
      List<User> myUsers = [];
      for (var user in usersMapList) {
        myUsers.add(User(
          id: user['id'],
          name: user['name'],
          image: user['image'],
          extraData: {'phone': user['phone'], 'shadow_banned': false},
        ));
      }
      users = myUsers;
      users = users
          .where((user) => widget.roomContacts.contains(user.id) == false)
          .toList();
      allUsers = users;
      phoneContacts = users.isNotEmpty ? [Contact()] : [];
      setState(() {});
    } else {
      if (!await FlutterContacts.requestPermission(readonly: true)) {
        setState(() => _permissionDenied = true);
      } else {
        List contacts = await Utils.fetchContacts(context);
        users = contacts.first;
        users = users
            .where((user) => widget.roomContacts.contains(user.id) == false)
            .toList();
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
