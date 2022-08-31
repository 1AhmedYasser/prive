import 'dart:async';
import 'dart:io';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:badges/badges.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Helpers/room_menu_dialog.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Helpers/utils.dart';
import 'package:prive/UltraNetwork/ultra_constants.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../../Models/Call/prive_call.dart';
import '../../Models/Rooms/room.dart';
import '../../Models/Rooms/room_user.dart';
import '../../Providers/volume_provider.dart';
import '../../UltraNetwork/ultra_network.dart';
import '../../Widgets/AppWidgets/Rooms/raised_hands_widget.dart';
import '../../Widgets/AppWidgets/Rooms/room_invitation_widget.dart';
import '../../Widgets/Common/cached_image.dart';

class RoomScreen extends StatefulWidget {
  final bool isNewRoomCreation;
  final Room room;
  const RoomScreen(
      {Key? key, this.isNewRoomCreation = false, required this.room})
      : super(key: key);

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  bool isMyMicOn = true;
  bool isNewRoomCreation = false;
  Room? room;
  RoomUser? me;
  List<String> speakersIds = [];
  List<String> raisedHandsIds = [];
  List<String> kickedListenersIds = [];
  List<String> invitedListenersIds = [];
  StreamSubscription? onAddListener;
  StreamSubscription? onChangeListener;
  StreamSubscription? onDeleteListener;
  bool showingInfo = false;
  RtcEngine? agoraEngine;
  CancelToken cancelToken = CancelToken();
  bool isShowingInvitation = false;

  @override
  void initState() {
    isNewRoomCreation = widget.isNewRoomCreation;
    setState(() {
      room = widget.room;
    });
    speakersIds = room?.speakers?.map((e) => e.id ?? "").toList() ?? [];
    raisedHandsIds = room?.raisedHands?.map((e) => e.id ?? "").toList() ?? [];
    _listenToFirebaseChanges();
    if (room?.owner?.id != context.currentUser?.id) {
      joinRoom();
    } else {
      initAgora(true);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: !isNewRoomCreation
            ? PreferredSize(
                preferredSize: Size(MediaQuery.of(context).size.width, 68),
                child: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.grey.shade100,
                  elevation: 0,
                  systemOverlayStyle: const SystemUiOverlayStyle(
                    statusBarBrightness: Brightness.light,
                  ),
                  actions: [
                    if (speakersIds.contains(context.currentUser?.id ?? ""))
                      _buildRoomUserMic(true),
                    if (room?.listeners
                            ?.firstWhereOrNull((listener) =>
                                listener.id == context.currentUser?.id)
                            ?.hasPermissionToSpeak ==
                        true)
                      _buildRoomUserMic(false),
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 20, left: 15, top: 15, bottom: 5),
                      child: ElevatedButton(
                        onPressed: () {
                          leaveRoom();
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              R.images.roomLeave,
                              width: 16,
                              color: Colors.red,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            const Text(
                              "Leave",
                              style: TextStyle(fontSize: 16, color: Colors.red),
                            ).tr(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : AppBar(
                backgroundColor: const Color(0xff5856d6),
                automaticallyImplyLeading: false,
                elevation: 0,
                bottom: PreferredSize(
                  preferredSize: Size(MediaQuery.of(context).size.width,
                      MediaQuery.of(context).size.height / 20),
                  child: Container(
                    color: const Color(0xff5856d6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 25, right: 50, top: 30, bottom: 20),
                            child: const Text(
                              "Let's Go! You Have Created A Room For This Topic Invite Your Friends For Your Room",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ).tr(),
                          ),
                        ),
                        IconButton(
                          padding: const EdgeInsets.only(right: 30),
                          icon: StreamSvgIcon.closeSmall(
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              isNewRoomCreation = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        body: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 20, top: 18, right: 20),
                      child: Text(
                        room?.topic ?? "",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 20, top: 10, right: 20),
                      child: Text(
                        room?.description ?? "",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 20, top: 10, right: 20),
                      child: Divider(),
                    ),
                    buildRoomSectionInfo(
                      "Speakers".tr(),
                      "${room?.speakers?.length ?? "0"}",
                      true,
                      withInvite: room?.owner?.id == context.currentUser?.id
                          ? true
                          : false,
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 20, right: 20, top: 20),
                      child: MediaQuery.removePadding(
                        context: context,
                        removeBottom: true,
                        removeTop: true,
                        child: GridView.builder(
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1 / 1.4,
                              crossAxisSpacing: 10,
                            ),
                            itemCount: room?.speakers?.length ?? 0,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return Column(
                                children: [
                                  Stack(
                                    children: [
                                      Consumer<VolumeProvider>(
                                          builder: (context, provider, ch) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: room?.speakers?[index]
                                                          .isSpeaking ==
                                                      true
                                                  ? Colors.green
                                                  : Colors.transparent,
                                              width: 1.5,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            child: SizedBox(
                                              height: 78,
                                              width: 80,
                                              child: CachedImage(
                                                url: room?.speakers?[index]
                                                        .image ??
                                                    "",
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                      if (room?.speakers?[index].isOwner ==
                                          true)
                                        const Positioned(
                                          right: 8,
                                          child: Icon(
                                            Icons.star,
                                            color: Colors.yellow,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        child: Consumer<VolumeProvider>(
                                            builder: (context, provider, ch) {
                                          return Icon(
                                            room?.speakers?[index].isMicOn ==
                                                    true
                                                ? FontAwesomeIcons.microphone
                                                : FontAwesomeIcons
                                                    .microphoneSlash,
                                            color: room?.speakers?[index]
                                                        .isMicOn ==
                                                    true
                                                ? (room?.speakers?[index]
                                                            .isSpeaking ==
                                                        true
                                                    ? Colors.green
                                                    : const Color(0xff7a8fa6))
                                                : Colors.red,
                                            size: 15,
                                          );
                                        }),
                                      ),
                                      const SizedBox(width: 3),
                                      Expanded(
                                        child: Text(
                                          (room?.speakers?[index].name
                                                      ?.split(" ")
                                                      .first ??
                                                  "")
                                              .trim(),
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                          maxLines: 1,
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              );
                            }),
                      ),
                    ),
                    buildRoomSectionInfo(
                      "Listeners".tr(),
                      "${room?.listeners?.length ?? "0"}",
                      false,
                      withInvite: true,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 20, bottom: 30),
                      child: MediaQuery.removePadding(
                        context: context,
                        removeBottom: true,
                        removeTop: true,
                        child: GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1 / 1.4,
                            crossAxisSpacing: 10,
                          ),
                          itemCount: room?.listeners?.length ?? 0,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              onTap: () {
                                if (speakersIds
                                    .contains(context.currentUser?.id ?? "")) {
                                  RoomMenuDialog.showListenerMenu(
                                      context, room?.listeners?[index],
                                      onUpgradePressed: () {
                                    RoomUser? listener =
                                        room?.listeners?[index];
                                    listener?.invitationSpeaker = me;
                                    final ref = FirebaseDatabase.instance
                                        .ref('rooms/${room?.owner?.id}');
                                    ref
                                        .child(
                                            'upgradedListeners/${listener?.id}')
                                        .update({
                                      "id": listener?.id,
                                      "name": listener?.name,
                                      "image": listener?.image,
                                      "isSpeaker": listener?.isSpeaker,
                                      "isListener": listener?.isListener,
                                      "phone": listener?.phone,
                                      "isHandRaised": listener?.isHandRaised,
                                      "hasPermissionToSpeak":
                                          listener?.hasPermissionToSpeak,
                                      "isOwner": listener?.isOwner,
                                      "isMicOn": listener?.isMicOn,
                                      "invitationSpeaker": me?.toJson()
                                    });
                                  }, onKickPressed: () {
                                    RoomUser? listener =
                                        room?.listeners?[index];
                                    final ref = FirebaseDatabase.instance
                                        .ref('rooms/${room?.owner?.id}');
                                    ref
                                        .child(
                                            'kickedListeners/${listener?.id}')
                                        .update({
                                      "id": listener?.id,
                                      "name": listener?.name,
                                      "image": listener?.image,
                                      "isSpeaker": listener?.isSpeaker,
                                      "isListener": listener?.isListener,
                                      "phone": listener?.phone,
                                      "isHandRaised": listener?.isHandRaised,
                                      "hasPermissionToSpeak":
                                          listener?.hasPermissionToSpeak,
                                      "isOwner": listener?.isOwner,
                                      "isMicOn": listener?.isMicOn,
                                    });
                                  });
                                }
                              },
                              child: Column(
                                children: [
                                  Consumer<VolumeProvider>(
                                      builder: (context, provider, ch) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: room?.listeners?[index]
                                                      .isSpeaking ==
                                                  true
                                              ? Colors.green
                                              : Colors.transparent,
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(25),
                                        child: SizedBox(
                                          height: 78,
                                          width: 80,
                                          child: CachedImage(
                                            url:
                                                room?.listeners?[index].image ??
                                                    "",
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        child: Consumer<VolumeProvider>(
                                          builder: (context, provider, ch) {
                                            return Icon(
                                              room?.listeners?[index].isMicOn ==
                                                      true
                                                  ? FontAwesomeIcons.microphone
                                                  : FontAwesomeIcons
                                                      .microphoneSlash,
                                              color: room?.listeners?[index]
                                                          .isMicOn ==
                                                      true
                                                  ? (room?.listeners?[index]
                                                              .isSpeaking ==
                                                          true
                                                      ? Colors.green
                                                      : const Color(0xff7a8fa6))
                                                  : Colors.red,
                                              size: 15,
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      Expanded(
                                        child: Text(
                                          (room?.listeners?[index].name
                                                      ?.split(" ")
                                                      .first ??
                                                  "")
                                              .trim(),
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                          maxLines: 1,
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 55,
              right: 30,
              child: Badge(
                badgeContent: Text(
                  "${room?.raisedHands?.length}",
                  style: const TextStyle(color: Colors.white),
                ),
                showBadge: speakersIds.contains(context.currentUser?.id)
                    ? room?.raisedHands?.isEmpty == true
                        ? false
                        : true
                    : false,
                position: BadgePosition.topEnd(end: -4),
                padding: const EdgeInsets.all(7),
                badgeColor: Theme.of(context).primaryColorDark,
                child: FloatingActionButton(
                  elevation: 1,
                  onPressed: () async {
                    if (speakersIds.contains(context.currentUser?.id)) {
                      showMaterialModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => SingleChildScrollView(
                          controller: ModalScrollController.of(context),
                          child: RaisedHandsWidget(
                            roomRef: 'rooms/${room?.owner?.id}',
                            agoraEngine: agoraEngine,
                          ),
                        ),
                      );
                    } else {
                      if (raisedHandsIds.contains(context.currentUser?.id)) {
                        final ref = FirebaseDatabase.instance.ref(
                            'rooms/${room?.owner?.id}/listeners/${context.currentUser?.id}');
                        isMyMicOn = false;
                        ref.update(
                            {"isMicOn": false, "hasPermissionToSpeak": false});
                        FirebaseDatabase.instance
                            .ref(
                                'rooms/${room?.owner?.id}/raisedHands/${context.currentUser?.id}')
                            .remove();
                        setState(() {});
                      } else {
                        final ref = FirebaseDatabase.instance
                            .ref('rooms/${room?.owner?.id}');

                        ref
                            .child('raisedHands/${context.currentUser?.id}')
                            .update({
                          "id": context.currentUser?.id,
                          "name": context.currentUser?.name,
                          "image": context.currentUser?.image,
                          "isSpeaker": false,
                          "isListener": true,
                          "phone": context.currentUser?.extraData['phone'],
                          "isHandRaised": true,
                          "isOwner": false,
                          "isMicOn": false,
                        });
                      }
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      R.images.raiseHandIcon,
                      color: speakersIds.contains(context.currentUser?.id)
                          ? null
                          : raisedHandsIds.contains(context.currentUser?.id)
                              ? null
                              : Colors.grey.shade300,
                      colorBlendMode:
                          speakersIds.contains(context.currentUser?.id)
                              ? null
                              : raisedHandsIds.contains(context.currentUser?.id)
                                  ? null
                                  : BlendMode.lighten,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Padding buildRoomSectionInfo(String title, String value, bool isSpeaker,
      {bool withInvite = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 14, right: 20),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xff7a8fa6),
              fontSize: 16.5,
              fontWeight: FontWeight.w400,
            ),
          ).tr(),
          const SizedBox(width: 10),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xff7a8fa6),
              fontSize: 15.5,
              fontWeight: FontWeight.w400,
            ),
          ).tr(),
          if (withInvite) const Expanded(child: SizedBox()),
          if (withInvite)
            GestureDetector(
              onTap: () {
                showMaterialModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => SingleChildScrollView(
                    controller: ModalScrollController.of(context),
                    child: RoomInvitationWidget(
                      roomContacts: room?.roomContacts ?? [],
                      isSpeaker: isSpeaker,
                      room: room,
                      roomRef: 'rooms/${room?.owner?.id}/room_contacts',
                    ),
                  ),
                );
              },
              child: Text(
                "+ Invite",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 16.5,
                ),
              ).tr(),
            )
        ],
      ),
    );
  }

  void getRoom() async {
    final databaseReference =
        FirebaseDatabase.instance.ref('rooms/${room?.owner?.id}');

    final snapshot = await databaseReference.get();
    if (snapshot.exists) {
      Map<dynamic, dynamic>? roomResponse = {};
      if (Platform.isIOS) {
        roomResponse =
            (snapshot.value as Map<dynamic, dynamic>)['${room?.owner?.id}'];
      } else {
        roomResponse = (snapshot.value as Map<dynamic, dynamic>);
      }

      String? roomId = roomResponse?['roomId'];
      String? topic = roomResponse?['topic'];
      String? description = roomResponse?['description'];
      RoomUser? owner = RoomUser(
        id: roomResponse?['owner']['id'],
        name: roomResponse?['owner']['name'],
        image: roomResponse?['owner']['image'],
        isOwner: roomResponse?['owner']['isOwner'],
        isSpeaker: roomResponse?['owner']['isSpeaker'],
        isListener: roomResponse?['owner']['isListener'],
        hasPermissionToSpeak: roomResponse?['owner']['hasPermissionToSpeak'],
        phone: roomResponse?['owner']['phone'],
        isHandRaised: roomResponse?['owner']['isHandRaised'],
        isMicOn: roomResponse?['owner']['isMicOn'],
      );

      List<RoomUser>? speakers = [];
      List<RoomUser>? listeners = [];
      List<String>? contacts = [];
      List<RoomUser>? raisedHands = [];
      List<RoomUser>? kickedListeners = [];
      List<RoomUser>? upgradedListeners = [];

      Map<dynamic, dynamic>? speakersList =
          (roomResponse?['speakers'] as Map<dynamic, dynamic>?) ?? {};
      speakersList.forEach((key, value) {
        speakers.add(
          RoomUser(
            id: value['id'],
            name: value['name'],
            image: value['image'],
            isOwner: value['isOwner'],
            isSpeaker: value['isSpeaker'],
            isListener: value['isListener'],
            phone: value['phone'],
            isHandRaised: value['isHandRaised'],
            hasPermissionToSpeak: value['hasPermissionToSpeak'],
            isMicOn: value['isMicOn'],
          ),
        );
      });

      Map<dynamic, dynamic>? listenersList =
          (roomResponse?['listeners'] as Map<dynamic, dynamic>?) ?? {};
      listenersList.forEach((key, value) {
        listeners.add(
          RoomUser(
            id: value['id'],
            name: value['name'],
            image: value['image'],
            isOwner: value['isOwner'],
            isSpeaker: value['isSpeaker'],
            isListener: value['isListener'],
            phone: value['phone'],
            isHandRaised: value['isHandRaised'],
            hasPermissionToSpeak: value['hasPermissionToSpeak'],
            isMicOn: value['isMicOn'],
          ),
        );
      });

      Map<dynamic, dynamic>? roomContacts =
          (roomResponse?['room_contacts'] as Map<dynamic, dynamic>?) ?? {};
      roomContacts.forEach((key, value) {
        contacts.add(key);
      });

      Map<dynamic, dynamic>? raisedHandsList =
          (roomResponse?['raisedHands'] as Map<dynamic, dynamic>?) ?? {};
      raisedHandsList.forEach((key, value) {
        raisedHands.add(
          RoomUser(
            id: value['id'],
            name: value['name'],
            image: value['image'],
            isOwner: value['isOwner'],
            isSpeaker: value['isSpeaker'],
            isListener: value['isListener'],
            phone: value['phone'],
            isHandRaised: value['isHandRaised'],
            hasPermissionToSpeak: value['hasPermissionToSpeak'],
            isMicOn: value['isMicOn'],
          ),
        );
      });

      Map<dynamic, dynamic>? kickedListenersList =
          (roomResponse?['kickedListeners'] as Map<dynamic, dynamic>?) ?? {};
      kickedListenersList.forEach((key, value) {
        kickedListeners.add(
          RoomUser(
            id: value['id'],
            name: value['name'],
            image: value['image'],
            isOwner: value['isOwner'],
            isSpeaker: value['isSpeaker'],
            isListener: value['isListener'],
            phone: value['phone'],
            isHandRaised: value['isHandRaised'],
            hasPermissionToSpeak: value['hasPermissionToSpeak'],
            isMicOn: value['isMicOn'],
          ),
        );
      });

      Map<dynamic, dynamic>? upgradedListenersList =
          (roomResponse?['upgradedListeners'] as Map<dynamic, dynamic>?) ?? {};
      upgradedListenersList.forEach((key, value) {
        upgradedListeners.add(
          RoomUser(
            id: value['id'],
            name: value['name'],
            image: value['image'],
            isOwner: value['isOwner'],
            isSpeaker: value['isSpeaker'],
            isListener: value['isListener'],
            phone: value['phone'],
            isHandRaised: value['isHandRaised'],
            hasPermissionToSpeak: value['hasPermissionToSpeak'],
            isMicOn: value['isMicOn'],
            invitationSpeaker: RoomUser(
              id: value['invitationSpeaker']['id'],
              name: value['invitationSpeaker']['name'],
              image: value['invitationSpeaker']['image'],
              isOwner: value['invitationSpeaker']['isOwner'],
              isSpeaker: value['invitationSpeaker']['isSpeaker'],
              isListener: value['invitationSpeaker']['isListener'],
              phone: value['invitationSpeaker']['phone'],
              isHandRaised: value['invitationSpeaker']['isHandRaised'],
              hasPermissionToSpeak: value['invitationSpeaker']
                  ['hasPermissionToSpeak'],
              isMicOn: value['invitationSpeaker']['isMicOn'],
            ),
          ),
        );
      });

      room = Room(
          roomId: roomId,
          topic: topic,
          description: description,
          owner: owner,
          speakers: speakers,
          listeners: listeners,
          roomContacts: contacts,
          raisedHands: raisedHands,
          kickedListeners: kickedListeners,
          upgradedListeners: upgradedListeners);
      speakersIds = room?.speakers?.map((e) => e.id ?? "").toList() ?? [];
      raisedHandsIds = room?.raisedHands?.map((e) => e.id ?? "").toList() ?? [];
      kickedListenersIds =
          room?.kickedListeners?.map((e) => e.id ?? "").toList() ?? [];
      invitedListenersIds =
          room?.upgradedListeners?.map((e) => e.id ?? "").toList() ?? [];

      // Get Me From Room Members
      if (speakersIds.contains(context.currentUser?.id)) {
        me = speakers.firstWhereOrNull(
            (speaker) => speaker.id == context.currentUser?.id);
      } else {
        me = listeners.firstWhereOrNull(
            (listener) => listener.id == context.currentUser?.id);
      }

      // Check if i am invited to be upgraded to speaker
      if (invitedListenersIds.contains(context.currentUser?.id)) {
        RoomUser? invitedListener = upgradedListeners.firstWhereOrNull(
            (listener) => listener.id == context.currentUser?.id);
        if (mounted) {
          if (isShowingInvitation == false) {
            isShowingInvitation = true;
            Utils.showAlert(context,
                withCancel: true,
                message:
                    "${invitedListener?.invitationSpeaker?.name} Invited You To Become A Speaker"
                        .tr(),
                okButtonText: "Accept".tr(),
                cancelButtonText: "Decline".tr(), onOkButtonPressed: () async {
              print("Accept");
              // Accept Invitation To Be A Speaker
              Navigator.pop(context);

              // Remove From Listeners
              final listenersRef = FirebaseDatabase.instance.ref(
                  'rooms/${room?.owner?.id}/listeners/${context.currentUser?.id}');
              listenersRef.remove();

              // Add To Speakers
              final speakersRef = FirebaseDatabase.instance.ref(
                  'rooms/${room?.owner?.id}/speakers/${context.currentUser?.id}');
              speakersRef.update({
                "id": me?.id,
                "name": me?.name,
                "image": me?.image,
                "isSpeaker": true,
                "isListener": false,
                "phone": me?.phone,
                "isHandRaised": me?.isHandRaised,
                "hasPermissionToSpeak": true,
                "isOwner": me?.isOwner,
                "isMicOn": me?.isMicOn,
              });
              isMyMicOn = me?.isMicOn ?? false;

              // Remove From Raised Hands If He Is There
              final raisedHandsRef = FirebaseDatabase.instance.ref(
                  'rooms/${room?.owner?.id}/raisedHands/${context.currentUser?.id}');
              raisedHandsRef.remove();

              // Remove Invitation
              final ref = FirebaseDatabase.instance.ref(
                  'rooms/${room?.owner?.id}/upgradedListeners/${context.currentUser?.id}');
              ref.remove();

              await agoraEngine?.setClientRole(ClientRole.Broadcaster);

              agoraEngine?.muteRemoteAudioStream(
                  int.parse(await Utils.getString(R.pref.userId) ?? "0"),
                  !isMyMicOn);

              await agoraEngine?.muteLocalAudioStream(!isMyMicOn);
            }, onCancelButtonPressed: () {
              // Decline Invitation To Be A Speaker
              final ref = FirebaseDatabase.instance.ref(
                  'rooms/${room?.owner?.id}/upgradedListeners/${context.currentUser?.id}');
              ref.remove();
            }).then((value) {
              isShowingInvitation = false;
            });
          }
        }
      }

      // Check If Kicked Your Kicked Out From The Room
      if (kickedListenersIds.contains(context.currentUser?.id)) {
        if (mounted) {
          leaveRoom();
          Utils.showAlert(
            context,
            message: "You Have Been Kicked Out Of This Room".tr(),
            alertImage: R.images.alertInfoImage,
          );
        }
      }

      room?.listeners?.forEach((listener) {
        if (listener.id == context.currentUser?.id) {
          if (listener.isMicOn == true) {
            agoraEngine?.setClientRole(ClientRole.Broadcaster);
          } else {
            agoraEngine?.setClientRole(ClientRole.Audience);
          }
        }
      });
      setState(() {});
    } else {
      if (showingInfo == false) {
        if (mounted) {
          Utils.showAlert(context,
                  message: "The Room Has Ended".tr(),
                  alertImage: R.images.alertInfoImage)
              .then(
            (value) {
              if (mounted) {
                Navigator.pop(context);
              }
            },
          );
        }
      }
      showingInfo = true;
    }
  }

  void _listenToFirebaseChanges() {
    final databaseReference =
        FirebaseDatabase.instance.ref('rooms/${room?.owner?.id}');
    onAddListener = databaseReference.onChildAdded.listen((event) {
      getRoom();
    });
    onChangeListener = databaseReference.onChildChanged.listen((event) {
      getRoom();
    });
    onChangeListener = databaseReference.onChildRemoved.listen((event) {
      getRoom();
    });
  }

  void joinRoom() async {
    final ref = FirebaseDatabase.instance.ref('rooms/${room?.owner?.id}');
    final snapshot = await ref.get();
    if (snapshot.exists) {
      Map<dynamic, dynamic>? roomResponse = {};
      if (Platform.isIOS) {
        roomResponse =
            (snapshot.value as Map<dynamic, dynamic>)['${room?.owner?.id}'];
      } else {
        roomResponse = (snapshot.value as Map<dynamic, dynamic>);
      }
      List<RoomUser> contacts = [];
      Map<dynamic, dynamic>? roomContactsList =
          (roomResponse?['room_contacts'] as Map<dynamic, dynamic>?) ?? {};
      roomContactsList.forEach((key, value) {
        contacts.add(
          RoomUser(
            id: value['id'],
            name: value['name'],
            image: value['image'],
            isOwner: value['isOwner'],
            isSpeaker: value['isSpeaker'],
            isListener: value['isListener'],
            hasPermissionToSpeak: value['hasPermissionToSpeak'],
            phone: value['phone'],
            isHandRaised: value['isHandRaised'],
            isMicOn: value['isMicOn'],
          ),
        );
      });
      RoomUser currentUser = contacts
          .firstWhere((contact) => contact.id == context.currentUser?.id);

      if (currentUser.isSpeaker == true) {
        ref.child('speakers/${context.currentUser?.id}').update({
          "id": currentUser.id,
          "name": currentUser.name,
          "image": currentUser.image,
          "isSpeaker": currentUser.isSpeaker,
          "isListener": currentUser.isListener,
          "phone": currentUser.phone,
          "isHandRaised": currentUser.isHandRaised,
          "hasPermissionToSpeak": currentUser.hasPermissionToSpeak,
          "isOwner": currentUser.isOwner,
          "isMicOn": currentUser.isMicOn,
        });
        initAgora(true);
      } else {
        ref.child('listeners/${context.currentUser?.id}').update({
          "id": currentUser.id,
          "name": currentUser.name,
          "image": currentUser.image,
          "isSpeaker": currentUser.isSpeaker,
          "isListener": currentUser.isListener,
          "phone": currentUser.phone,
          "isHandRaised": currentUser.isHandRaised,
          "hasPermissionToSpeak": currentUser.hasPermissionToSpeak,
          "isOwner": currentUser.isOwner,
          "isMicOn": currentUser.isMicOn,
        });
        initAgora(false);
      }
    }
  }

  void leaveRoom() {
    final ref = FirebaseDatabase.instance.ref('rooms/${room?.owner?.id}');
    if (room?.owner?.id == context.currentUser?.id) {
      ref.remove();
    } else if (speakersIds.contains(context.currentUser?.id)) {
      ref.child('speakers/${context.currentUser?.id}').remove();
    } else {
      ref.child('listeners/${context.currentUser?.id}').remove();
      ref.child('raisedHands/${context.currentUser?.id}').remove();
    }
    Navigator.pop(context);
  }

  Future<void> initAgora(bool isSpeaker) async {
    UltraNetwork.request(
      context,
      roomToken,
      cancelToken: cancelToken,
      formData: FormData.fromMap({
        "Uid": await Utils.getString(R.pref.userId),
        "channelName": room?.roomId,
      }),
      showLoadingIndicator: false,
      showError: false,
    ).then((response) async {
      if (response != null) {
        PriveCall tokenResponse = response;
        await [Permission.microphone].request();

        agoraEngine = await RtcEngine.createWithContext(
            RtcEngineContext(R.constants.agoraAppId));

        await agoraEngine?.setChannelProfile(ChannelProfile.LiveBroadcasting);
        await agoraEngine?.enableAudioVolumeIndication(250, 6, true);
        agoraEngine?.setEventHandler(RtcEngineEventHandler(
          joinChannelSuccess: (String channel, int uid, int elapsed) {
            print('joinChannelSuccess $channel $uid');
          },
          userJoined: (int uid, int elapsed) {
            print('userJoined $uid');
          },
          audioVolumeIndication: (volumeInfo, v) {
            for (var speaker in volumeInfo) {
              if (speaker.volume > 5) {
                print("User Speaking ${speaker.uid}");
                try {
                  changeVolumeStatus(speaker.uid, true);
                } catch (error) {
                  print('Error:${error.toString()}');
                }
              } else {
                changeVolumeStatus(speaker.uid, false);
              }
            }
          },
        ));
        await agoraEngine?.setClientRole(
            isSpeaker ? ClientRole.Broadcaster : ClientRole.Audience);
        await agoraEngine?.joinChannel(
            tokenResponse.data ?? "",
            room?.roomId ?? "",
            null,
            int.parse(await Utils.getString(R.pref.userId) ?? "0"));
        agoraEngine?.setParameters('{"che.audio.opensl":true}');
        setState(() {});
      }
    });
  }

  void changeVolumeStatus(int speakerId, bool status) {
    if (speakerId == 0) {
      room?.speakers
          ?.firstWhereOrNull(
              (member) => (member.id ?? 0) == context.currentUser?.id)
          ?.isSpeaking = status;
      room?.listeners
          ?.firstWhereOrNull(
              (member) => (member.id ?? 0) == context.currentUser?.id)
          ?.isSpeaking = status;
    } else {
      room?.speakers
          ?.firstWhereOrNull((member) => (member.id ?? 0) == "$speakerId")
          ?.isSpeaking = status;
      room?.listeners
          ?.firstWhereOrNull((member) => (member.id ?? 0) == "$speakerId")
          ?.isSpeaking = status;
    }
    Provider.of<VolumeProvider>(context, listen: false).refreshVolumes();
  }

  Widget _buildRoomUserMic(bool isSpeaker) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: GestureDetector(
        onTap: () async {
          setState(() {
            isMyMicOn = !isMyMicOn;
          });
          agoraEngine?.muteRemoteAudioStream(
              int.parse(await Utils.getString(R.pref.userId) ?? "0"),
              !isMyMicOn);

          await agoraEngine?.muteLocalAudioStream(!isMyMicOn);
          if (isSpeaker) {
            if (room?.owner?.id == context.currentUser?.id) {
              final ref = FirebaseDatabase.instance
                  .ref('rooms/${room?.owner?.id}/owner');
              ref.update({"isMicOn": isMyMicOn});
            }
            final ref = FirebaseDatabase.instance.ref(
                'rooms/${room?.owner?.id}/speakers/${context.currentUser?.id}');
            ref.update({"isMicOn": isMyMicOn});
          } else {
            final ref = FirebaseDatabase.instance.ref(
                'rooms/${room?.owner?.id}/listeners/${context.currentUser?.id}');
            ref.update({"isMicOn": isMyMicOn});
          }
        },
        child: SizedBox(
          width: 30,
          child: Icon(
            isSpeaker == true
                ? isMyMicOn
                    ? FontAwesomeIcons.microphone
                    : FontAwesomeIcons.microphoneSlash
                : room?.listeners
                            ?.firstWhereOrNull((listener) =>
                                listener.id == context.currentUser?.id)
                            ?.isMicOn ==
                        true
                    ? FontAwesomeIcons.microphone
                    : FontAwesomeIcons.microphoneSlash,
            color: isSpeaker == true
                ? isMyMicOn
                    ? const Color(0xff7a8fa6)
                    : Colors.red
                : room?.listeners
                            ?.firstWhereOrNull((listener) =>
                                listener.id == context.currentUser?.id)
                            ?.isMicOn ==
                        true
                    ? const Color(0xff7a8fa6)
                    : Colors.red,
            size: 24,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    onAddListener?.cancel();
    onChangeListener?.cancel();
    onDeleteListener?.cancel();
    agoraEngine?.destroy();
    super.dispose();
  }
}
