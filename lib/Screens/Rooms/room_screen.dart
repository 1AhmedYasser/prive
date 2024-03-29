import 'dart:async';
import 'dart:io';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
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
import 'package:prive/Helpers/room_menu_dialog.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Helpers/utils.dart';
import 'package:prive/Models/Call/prive_call.dart';
import 'package:prive/Models/Rooms/room.dart';
import 'package:prive/Models/Rooms/room_user.dart';
import 'package:prive/Providers/volume_provider.dart';
import 'package:prive/Resources/constants.dart';
import 'package:prive/Resources/images.dart';
import 'package:prive/Resources/shared_pref.dart';
import 'package:prive/UltraNetwork/ultra_constants.dart';
import 'package:prive/UltraNetwork/ultra_network.dart';
import 'package:prive/Widgets/AppWidgets/Rooms/kicked_members_widget.dart';
import 'package:prive/Widgets/AppWidgets/Rooms/raised_hands_widget.dart';
import 'package:prive/Widgets/AppWidgets/Rooms/room_invitation_widget.dart';
import 'package:prive/Widgets/Common/cached_image.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class RoomScreen extends StatefulWidget {
  final bool isNewRoomCreation;
  final Room room;
  const RoomScreen({Key? key, this.isNewRoomCreation = false, required this.room}) : super(key: key);

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  bool isMyMicOn = true;
  bool isNewRoomCreation = false;
  Room? room;
  RoomUser? me;
  RoomUser? currentOwner;
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
  bool isEditingDescription = false;
  TextEditingController descriptionController = TextEditingController();
  FocusNode descriptionFocusNode = FocusNode();
  final yourRoomNameController = TextEditingController();

  @override
  void initState() {
    isNewRoomCreation = widget.isNewRoomCreation;
    setState(() {
      room = widget.room;
      descriptionController.text = room?.description ?? '';
      yourRoomNameController.text = context.currentUser?.name ?? '';
    });
    speakersIds = room?.speakers?.map((e) => e.id ?? '').toList() ?? [];
    raisedHandsIds = room?.raisedHands?.map((e) => e.id ?? '').toList() ?? [];
    _listenToFirebaseChanges();
    if (room?.roomFounderId != context.currentUser?.id) {
      joinRoom();
    } else if (room?.speakers?.firstWhere((speaker) => speaker.isOwner == true).id != room?.roomFounderId) {
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
                  title: Padding(
                    padding: const EdgeInsets.only(top: 13),
                    child: Text(
                      widget.room.topic ?? '',
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  elevation: 0,
                  systemOverlayStyle: const SystemUiOverlayStyle(
                    statusBarBrightness: Brightness.light,
                  ),
                  actions: [
                    if (speakersIds.contains(context.currentUser?.id ?? '')) _buildRoomUserMic(true),
                    if (room?.listeners
                            ?.firstWhereOrNull((listener) => listener.id == context.currentUser?.id)
                            ?.hasPermissionToSpeak ==
                        true)
                      _buildRoomUserMic(false),
                    Padding(
                      padding: const EdgeInsets.only(right: 20, left: 15, top: 15, bottom: 5),
                      child: ElevatedButton(
                        onPressed: () {
                          leaveRoom();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              Images.roomLeave,
                              width: 16,
                              color: Colors.red,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            const Text(
                              'Leave',
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
                  preferredSize: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height / 20),
                  child: Container(
                    color: const Color(0xff5856d6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 25, right: 50, top: 30, bottom: 20),
                            child: const Text(
                              "Let's Go! You Have Created A Room For This Topic Invite Your Friends For Your Room",
                              style: TextStyle(color: Colors.white, fontSize: 15),
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
                    if (isNewRoomCreation)
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 18, right: 20),
                        child: Text(
                          room?.topic ?? '',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20, left: 20),
                              child: TextField(
                                controller: descriptionController,
                                focusNode: descriptionFocusNode,
                                enabled: isEditingDescription,
                                keyboardType: TextInputType.multiline,
                                minLines: 1,
                                maxLines: null,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          if (currentOwner?.id == context.currentUser?.id && isEditingDescription)
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    if (descriptionController.text.isNotEmpty) {
                                      setState(() {
                                        isEditingDescription = false;
                                      });
                                      if (descriptionController.text != room?.description) {
                                        final ref = FirebaseDatabase.instance.ref('rooms/${room?.roomFounderId}');
                                        ref.update({'description': descriptionController.text});
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(40, 40),
                                    backgroundColor: Colors.green,
                                  ),
                                  child: const Icon(Icons.done),
                                ),
                                const SizedBox(
                                  width: 7,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    descriptionController.text = room?.description ?? '';
                                    setState(() {
                                      isEditingDescription = false;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(40, 40),
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Icon(Icons.close),
                                )
                              ],
                            ),
                          if (currentOwner?.id == context.currentUser?.id && !isEditingDescription)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isEditingDescription = true;
                                });
                                Future.delayed(const Duration(milliseconds: 50), () {
                                  descriptionFocusNode.requestFocus();
                                });
                              },
                              child: Text(
                                'Edit',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Divider(),
                    ),
                    buildRoomSectionInfo(
                      'Speakers'.tr(),
                      "${room?.speakers?.length ?? "0"}",
                      true,
                      withInvite: currentOwner?.id == context.currentUser?.id ? true : false,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                      child: MediaQuery.removePadding(
                        context: context,
                        removeBottom: true,
                        removeTop: true,
                        child: GridView.builder(
                          shrinkWrap: true,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1 / 1.4,
                            crossAxisSpacing: 10,
                          ),
                          itemCount: room?.speakers?.length ?? 0,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () {
                                if (currentOwner?.id == context.currentUser?.id ||
                                    context.currentUser?.id == room?.speakers?[index].id) {
                                  RoomMenuDialog.showSpeakerMenu(
                                    context,
                                    currentOwner?.id,
                                    room?.speakers?[index],
                                    onChangeNamePressed: () async {
                                      _showChangeNameDialog();
                                    },
                                    onDemotePressed: () async {
                                      // Remove From Speakers
                                      final speakersRef = FirebaseDatabase.instance
                                          .ref('rooms/${room?.roomFounderId}/speakers/${room?.speakers?[index].id}');
                                      speakersRef.remove();

                                      // Add To Listeners
                                      final listenersRef = FirebaseDatabase.instance
                                          .ref('rooms/${room?.roomFounderId}/listeners/${room?.speakers?[index].id}');
                                      listenersRef.update({
                                        'id': room?.speakers?[index].id,
                                        'name': room?.speakers?[index].name,
                                        'image': room?.speakers?[index].image,
                                        'isSpeaker': false,
                                        'isListener': true,
                                        'phone': room?.speakers?[index].phone,
                                        'isHandRaised': false,
                                        'hasPermissionToSpeak': false,
                                        'isOwner': room?.speakers?[index].isOwner,
                                        'isMicOn': false,
                                      });
                                      isMyMicOn = false;

                                      // Demote From Room Contacts
                                      final roomContactsRef = FirebaseDatabase.instance.ref(
                                        'rooms/${room?.roomFounderId}/room_contacts/${room?.speakers?[index].id}',
                                      );
                                      roomContactsRef.update({
                                        'id': room?.speakers?[index].id,
                                        'name': room?.speakers?[index].name,
                                        'image': room?.speakers?[index].image,
                                        'isSpeaker': false,
                                        'isListener': true,
                                        'phone': room?.speakers?[index].phone,
                                        'isHandRaised': false,
                                        'hasPermissionToSpeak': false,
                                        'isOwner': room?.speakers?[index].isOwner,
                                        'isMicOn': false,
                                      });

                                      // Remove From Raised Hands If He Is There
                                      final raisedHandsRef = FirebaseDatabase.instance
                                          .ref('rooms/${room?.roomFounderId}/raisedHands/${context.currentUser?.id}');
                                      raisedHandsRef.remove();

                                      await agoraEngine?.setClientRole(role: ClientRoleType.clientRoleAudience);

                                      agoraEngine?.muteRemoteAudioStream(
                                        uid: int.parse(await Utils.getString(SharedPref.userId) ?? '0'),
                                        mute: true,
                                      );

                                      await agoraEngine?.muteLocalAudioStream(true);
                                    },
                                  );
                                }
                              },
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      Consumer<VolumeProvider>(
                                        builder: (context, provider, ch) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: room?.speakers?[index].isSpeaking == true
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
                                                  url: room?.speakers?[index].image ?? '',
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      if (room?.speakers?[index].isOwner == true)
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
                                              room?.speakers?[index].isMicOn == true
                                                  ? FontAwesomeIcons.microphone
                                                  : FontAwesomeIcons.microphoneSlash,
                                              color: room?.speakers?[index].isMicOn == true
                                                  ? (room?.speakers?[index].isSpeaking == true
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
                                          (room?.speakers?[index].name?.split(' ').first ?? '').trim(),
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
                    buildRoomSectionInfo(
                      'Listeners'.tr(),
                      "${room?.listeners?.length ?? "0"}",
                      false,
                      withInvite: true,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 30),
                      child: MediaQuery.removePadding(
                        context: context,
                        removeBottom: true,
                        removeTop: true,
                        child: GridView.builder(
                          shrinkWrap: true,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                                if (speakersIds.contains(context.currentUser?.id ?? '')) {
                                  RoomMenuDialog.showListenerMenu(
                                    context,
                                    room?.listeners?[index],
                                    onUpgradePressed: () {
                                      RoomUser? listener = room?.listeners?[index];
                                      listener?.invitationSpeaker = me;
                                      final ref = FirebaseDatabase.instance.ref('rooms/${room?.roomFounderId}');
                                      ref.child('upgradedListeners/${listener?.id}').update({
                                        'id': listener?.id,
                                        'name': listener?.name,
                                        'image': listener?.image,
                                        'isSpeaker': listener?.isSpeaker,
                                        'isListener': listener?.isListener,
                                        'phone': listener?.phone,
                                        'isHandRaised': listener?.isHandRaised,
                                        'hasPermissionToSpeak': listener?.hasPermissionToSpeak,
                                        'isOwner': listener?.isOwner,
                                        'isMicOn': listener?.isMicOn,
                                        'invitationSpeaker': me?.toJson()
                                      });
                                    },
                                    onKickPressed: () {
                                      RoomUser? listener = room?.listeners?[index];
                                      final ref = FirebaseDatabase.instance.ref('rooms/${room?.roomFounderId}');
                                      ref.child('kickedListeners/${listener?.id}').update({
                                        'id': listener?.id,
                                        'name': listener?.name,
                                        'image': listener?.image,
                                        'isSpeaker': listener?.isSpeaker,
                                        'isListener': listener?.isListener,
                                        'phone': listener?.phone,
                                        'isHandRaised': listener?.isHandRaised,
                                        'hasPermissionToSpeak': listener?.hasPermissionToSpeak,
                                        'isOwner': listener?.isOwner,
                                        'isMicOn': listener?.isMicOn,
                                      });
                                    },
                                  );
                                } else {
                                  if (room?.listeners?[index].id == context.currentUser?.id) {
                                    RoomMenuDialog.showChangeNameMenu(
                                      context,
                                      room?.listeners?[index],
                                      onChangeNamePressed: () {
                                        _showChangeNameDialog();
                                      },
                                    );
                                  }
                                }
                              },
                              child: Column(
                                children: [
                                  Consumer<VolumeProvider>(
                                    builder: (context, provider, ch) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: room?.listeners?[index].isSpeaking == true
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
                                              url: room?.listeners?[index].image ?? '',
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        child: Consumer<VolumeProvider>(
                                          builder: (context, provider, ch) {
                                            return Icon(
                                              room?.listeners?[index].isMicOn == true
                                                  ? FontAwesomeIcons.microphone
                                                  : FontAwesomeIcons.microphoneSlash,
                                              color: room?.listeners?[index].isMicOn == true
                                                  ? (room?.listeners?[index].isSpeaking == true
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
                                          (room?.listeners?[index].name?.split(' ').first ?? '').trim(),
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
                  '${room?.raisedHands?.length}',
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
                            roomRef: 'rooms/${room?.roomFounderId}',
                            agoraEngine: agoraEngine,
                          ),
                        ),
                      );
                    } else {
                      if (raisedHandsIds.contains(context.currentUser?.id)) {
                        final ref = FirebaseDatabase.instance
                            .ref('rooms/${room?.roomFounderId}/listeners/${context.currentUser?.id}');
                        isMyMicOn = false;
                        ref.update({'isMicOn': false, 'hasPermissionToSpeak': false});
                        FirebaseDatabase.instance
                            .ref('rooms/${room?.roomFounderId}/raisedHands/${context.currentUser?.id}')
                            .remove();
                        setState(() {});
                      } else {
                        final ref = FirebaseDatabase.instance.ref('rooms/${room?.roomFounderId}');
                        ref.child('raisedHands/${context.currentUser?.id}').update({
                          'id': context.currentUser?.id,
                          'name': context.currentUser?.name,
                          'image': context.currentUser?.image,
                          'isSpeaker': false,
                          'isListener': true,
                          'phone': context.currentUser?.extraData['phone'],
                          'isHandRaised': true,
                          'timeOfRaisingHands': DateTime.now().toString(),
                          'isOwner': false,
                          'isMicOn': false,
                        });
                      }
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      Images.raiseHandIcon,
                      color: speakersIds.contains(context.currentUser?.id)
                          ? null
                          : raisedHandsIds.contains(context.currentUser?.id)
                              ? null
                              : Colors.grey.shade300,
                      colorBlendMode: speakersIds.contains(context.currentUser?.id)
                          ? null
                          : raisedHandsIds.contains(context.currentUser?.id)
                              ? null
                              : BlendMode.lighten,
                    ),
                  ),
                ),
              ),
            ),
            if (room?.kickedListeners?.isNotEmpty == true && me?.isOwner == true)
              Positioned(
                bottom: 55,
                left: 40,
                child: Badge(
                  badgeContent: Text(
                    '${room?.kickedListeners?.length}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  showBadge: room?.kickedListeners?.isNotEmpty == true ? true : false,
                  position: BadgePosition.topEnd(end: -4),
                  padding: const EdgeInsets.all(7),
                  badgeColor: Theme.of(context).primaryColorDark,
                  child: FloatingActionButton(
                    elevation: 1,
                    backgroundColor: Theme.of(context).primaryColor,
                    onPressed: () async {
                      showMaterialModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => SingleChildScrollView(
                          controller: ModalScrollController.of(context),
                          child: KickedMembersWidget(
                            ref: 'rooms/${room?.roomFounderId}/kickedListeners',
                            agoraEngine: agoraEngine,
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: const Icon(
                        FontAwesomeIcons.ban,
                        size: 30,
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

  Padding buildRoomSectionInfo(String title, String value, bool isSpeaker, {bool withInvite = false}) {
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
                      roomRef: 'rooms/${room?.roomFounderId}/room_contacts',
                    ),
                  ),
                );
              },
              child: Text(
                '+ Invite',
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
    final databaseReference = FirebaseDatabase.instance.ref('rooms/${room?.roomFounderId}');

    final snapshot = await databaseReference.get();
    if (snapshot.exists) {
      Map<dynamic, dynamic>? roomResponse = {};
      if (Platform.isIOS) {
        roomResponse = (snapshot.value as Map<dynamic, dynamic>)['${room?.roomFounderId}'];
      } else {
        roomResponse = (snapshot.value as Map<dynamic, dynamic>);
      }

      String? roomId = roomResponse?['roomId'];
      String? topic = roomResponse?['topic'];
      String? description = roomResponse?['description'];
      String? roomFounderId = roomResponse?['roomFounderId'];

      List<RoomUser>? speakers = [];
      List<RoomUser>? listeners = [];
      List<String>? contacts = [];
      List<RoomUser>? raisedHands = [];
      List<RoomUser>? kickedListeners = [];
      List<RoomUser>? upgradedListeners = [];

      Map<dynamic, dynamic>? speakersList = (roomResponse?['speakers'] as Map<dynamic, dynamic>?) ?? {};
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

      Map<dynamic, dynamic>? listenersList = (roomResponse?['listeners'] as Map<dynamic, dynamic>?) ?? {};
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

      Map<dynamic, dynamic>? roomContacts = (roomResponse?['room_contacts'] as Map<dynamic, dynamic>?) ?? {};
      roomContacts.forEach((key, value) {
        contacts.add(key);
      });

      Map<dynamic, dynamic>? raisedHandsList = (roomResponse?['raisedHands'] as Map<dynamic, dynamic>?) ?? {};
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

      Map<dynamic, dynamic>? kickedListenersList = (roomResponse?['kickedListeners'] as Map<dynamic, dynamic>?) ?? {};
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
              hasPermissionToSpeak: value['invitationSpeaker']['hasPermissionToSpeak'],
              isMicOn: value['invitationSpeaker']['isMicOn'],
            ),
          ),
        );
      });

      room = Room(
        roomId: roomId,
        topic: topic,
        description: description,
        roomFounderId: roomFounderId,
        speakers: speakers,
        listeners: listeners,
        roomContacts: contacts,
        raisedHands: raisedHands,
        kickedListeners: kickedListeners,
        upgradedListeners: upgradedListeners,
      );
      speakersIds = room?.speakers?.map((e) => e.id ?? '').toList() ?? [];
      raisedHandsIds = room?.raisedHands?.map((e) => e.id ?? '').toList() ?? [];
      kickedListenersIds = room?.kickedListeners?.map((e) => e.id ?? '').toList() ?? [];
      invitedListenersIds = room?.upgradedListeners?.map((e) => e.id ?? '').toList() ?? [];

      // Get Current Owner
      currentOwner = room?.speakers?.firstWhere((speaker) => speaker.isOwner == true);

      // Check if the room description changed
      if (room?.description != descriptionController.text) {
        descriptionController.text = room?.description ?? '';
      }

      // Get Me From Room Members
      if (mounted) {
        if (speakersIds.contains(context.currentUser?.id)) {
          me = speakers.firstWhereOrNull((speaker) => speaker.id == context.currentUser?.id);
        } else {
          me = listeners.firstWhereOrNull((listener) => listener.id == context.currentUser?.id);
        }
      }

      // Check if i am invited to be upgraded to speaker
      if (mounted) {
        if (invitedListenersIds.contains(context.currentUser?.id)) {
          RoomUser? invitedListener =
              upgradedListeners.firstWhereOrNull((listener) => listener.id == context.currentUser?.id);
          if (mounted) {
            if (isShowingInvitation == false) {
              isShowingInvitation = true;
              Utils.showAlert(
                context,
                withCancel: true,
                message: '${invitedListener?.invitationSpeaker?.name} Invited You To Become A Speaker'.tr(),
                okButtonText: 'Accept'.tr(),
                cancelButtonText: 'Decline'.tr(),
                onOkButtonPressed: () async {
                  print('Accept');
                  // Accept Invitation To Be A Speaker
                  Navigator.pop(context);

                  // Remove From Listeners
                  final listenersRef = FirebaseDatabase.instance
                      .ref('rooms/${room?.roomFounderId}/listeners/${context.currentUser?.id}');
                  listenersRef.remove();

                  // Add To Speakers
                  final speakersRef =
                      FirebaseDatabase.instance.ref('rooms/${room?.roomFounderId}/speakers/${context.currentUser?.id}');
                  speakersRef.update({
                    'id': me?.id,
                    'name': me?.name,
                    'image': me?.image,
                    'isSpeaker': true,
                    'isListener': false,
                    'phone': me?.phone,
                    'isHandRaised': me?.isHandRaised,
                    'hasPermissionToSpeak': true,
                    'isOwner': me?.isOwner,
                    'isMicOn': me?.isMicOn,
                  });
                  isMyMicOn = me?.isMicOn ?? false;

                  // Remove From Raised Hands If He Is There
                  final raisedHandsRef = FirebaseDatabase.instance
                      .ref('rooms/${room?.roomFounderId}/raisedHands/${context.currentUser?.id}');
                  raisedHandsRef.remove();

                  // Remove Invitation
                  final ref = FirebaseDatabase.instance
                      .ref('rooms/${room?.roomFounderId}/upgradedListeners/${context.currentUser?.id}');
                  ref.remove();

                  await agoraEngine?.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

                  agoraEngine?.muteRemoteAudioStream(
                    uid: int.parse(await Utils.getString(SharedPref.userId) ?? '0'),
                    mute: !isMyMicOn,
                  );

                  await agoraEngine?.muteLocalAudioStream(!isMyMicOn);
                },
                onCancelButtonPressed: () {
                  // Decline Invitation To Be A Speaker
                  final ref = FirebaseDatabase.instance
                      .ref('rooms/${room?.roomFounderId}/upgradedListeners/${context.currentUser?.id}');
                  ref.remove();
                },
              ).then((value) {
                isShowingInvitation = false;
              });
            }
          }
        }
      }

      // Check If Kicked Your Kicked Out From The Room
      if (mounted) {
        if (kickedListenersIds.contains(context.currentUser?.id)) {
          if (mounted) {
            leaveRoom();
            Utils.showAlert(
              context,
              message: 'You Have Been Kicked Out Of This Room'.tr(),
              alertImage: Images.alertInfoImage,
            );
          }
        }
      }

      if (mounted) {
        room?.listeners?.forEach((listener) {
          if (listener.id == context.currentUser?.id) {
            if (listener.isMicOn == true) {
              agoraEngine?.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
            } else {
              agoraEngine?.setClientRole(role: ClientRoleType.clientRoleAudience);
            }
          }
        });
      }
      setState(() {});
    } else {
      if (showingInfo == false) {
        if (mounted) {
          Utils.showAlert(context, message: 'The Room Has Ended'.tr(), alertImage: Images.alertInfoImage).then(
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
    final databaseReference = FirebaseDatabase.instance.ref('rooms/${room?.roomFounderId}');
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
    final ref = FirebaseDatabase.instance.ref('rooms/${room?.roomFounderId}');
    final snapshot = await ref.get();
    if (snapshot.exists) {
      Map<dynamic, dynamic>? roomResponse = {};
      if (Platform.isIOS) {
        roomResponse = (snapshot.value as Map<dynamic, dynamic>)['${room?.roomFounderId}'];
      } else {
        roomResponse = (snapshot.value as Map<dynamic, dynamic>);
      }
      List<RoomUser> contacts = [];
      Map<dynamic, dynamic>? roomContactsList = (roomResponse?['room_contacts'] as Map<dynamic, dynamic>?) ?? {};
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
      RoomUser currentUser = contacts.firstWhere((contact) => contact.id == context.currentUser?.id);

      if (currentUser.isSpeaker == true) {
        ref.child('speakers/${context.currentUser?.id}').update({
          'id': currentUser.id,
          'name': currentUser.name,
          'image': currentUser.image,
          'isSpeaker': currentUser.isSpeaker,
          'isListener': currentUser.isListener,
          'phone': currentUser.phone,
          'isHandRaised': currentUser.isHandRaised,
          'hasPermissionToSpeak': currentUser.hasPermissionToSpeak,
          'isOwner': currentUser.isOwner,
          'isMicOn': currentUser.isMicOn,
        });
        initAgora(true);
      } else {
        ref.child('listeners/${context.currentUser?.id}').update({
          'id': currentUser.id,
          'name': currentUser.name,
          'image': currentUser.image,
          'isSpeaker': currentUser.isSpeaker,
          'isListener': currentUser.isListener,
          'phone': currentUser.phone,
          'isHandRaised': currentUser.isHandRaised,
          'hasPermissionToSpeak': currentUser.hasPermissionToSpeak,
          'isOwner': currentUser.isOwner,
          'isMicOn': currentUser.isMicOn,
        });
        initAgora(false);
      }
    }
  }

  void leaveRoom() {
    final ref = FirebaseDatabase.instance.ref('rooms/${room?.roomFounderId}');
    if (currentOwner?.id == context.currentUser?.id && (room?.speakers?.length ?? 1) > 1) {
      RoomUser? nextSpeaker = room?.speakers?.firstWhere((e) => e.id != currentOwner?.id);
      final nextOwnerRef = FirebaseDatabase.instance.ref('rooms/${room?.roomFounderId}/speakers/${nextSpeaker?.id}');
      nextOwnerRef.update({
        'id': nextSpeaker?.id,
        'name': nextSpeaker?.name,
        'image': nextSpeaker?.image,
        'isSpeaker': true,
        'isListener': false,
        'phone': nextSpeaker?.phone,
        'isHandRaised': nextSpeaker?.isHandRaised,
        'hasPermissionToSpeak': nextSpeaker?.hasPermissionToSpeak,
        'isOwner': true,
        'isMicOn': nextSpeaker?.isMicOn,
      });

      final previousOwnerRef =
          FirebaseDatabase.instance.ref('rooms/${room?.roomFounderId}/speakers/${context.currentUser?.id}');
      previousOwnerRef.remove();
    } else if (currentOwner?.id == context.currentUser?.id) {
      // If Only Speaker is owner
      ref.remove();
    } else if (speakersIds.contains(context.currentUser?.id)) {
      // If a Speaker leaves
      ref.child('speakers/${context.currentUser?.id}').remove();
    } else {
      // If a Listener leaves
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
        'Uid': await Utils.getString(SharedPref.userId),
        'channelName': room?.roomId,
      }),
      showLoadingIndicator: false,
      showError: false,
    ).then((response) async {
      if (response != null) {
        PriveCall tokenResponse = response;
        await [Permission.microphone].request();

        agoraEngine = createAgoraRtcEngine();
        await agoraEngine?.initialize(const RtcEngineContext(appId: Constants.agoraAppId));

        agoraEngine?.registerEventHandler(
          RtcEngineEventHandler(
            onJoinChannelSuccess: (connection, uid) {
              print('joinChannelSuccess $uid');
            },
            onUserJoined: (connection, uid, elapsed) {
              print('userJoined $uid');
            },
            onAudioVolumeIndication: (connection, volumeInfo, v, k) {
              for (var speaker in volumeInfo) {
                if ((speaker.volume ?? 0) > 5) {
                  print('User Speaking ${speaker.uid}');
                  try {
                    changeVolumeStatus(speaker.uid ?? 0, true);
                  } catch (error) {
                    print('Error:${error.toString()}');
                  }
                } else {
                  changeVolumeStatus(speaker.uid ?? 0, false);
                }
              }
            },
          ),
        );
        await agoraEngine?.startPreview();
        await agoraEngine?.setClientRole(
          role: isSpeaker ? ClientRoleType.clientRoleBroadcaster : ClientRoleType.clientRoleAudience,
        );
        await agoraEngine?.joinChannel(
          token: tokenResponse.data ?? '',
          channelId: room?.roomId ?? '',
          uid: int.parse(await Utils.getString(SharedPref.userId) ?? '0'),
          options: ChannelMediaOptions(
            token: tokenResponse.data ?? '',
            clientRoleType: isSpeaker ? ClientRoleType.clientRoleBroadcaster : ClientRoleType.clientRoleAudience,
            channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
          ),
        );

        agoraEngine?.setParameters('{"che.audio.opensl":true}');
        await agoraEngine?.enableAudioVolumeIndication(interval: 250, smooth: 6, reportVad: true);
        setState(() {});
      }
    });
  }

  void changeVolumeStatus(int speakerId, bool status) {
    if (speakerId == 0) {
      room?.speakers?.firstWhereOrNull((member) => (member.id ?? 0) == context.currentUser?.id)?.isSpeaking = status;
      room?.listeners?.firstWhereOrNull((member) => (member.id ?? 0) == context.currentUser?.id)?.isSpeaking = status;
    } else {
      room?.speakers?.firstWhereOrNull((member) => (member.id ?? 0) == '$speakerId')?.isSpeaking = status;
      room?.listeners?.firstWhereOrNull((member) => (member.id ?? 0) == '$speakerId')?.isSpeaking = status;
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
            uid: int.parse(await Utils.getString(SharedPref.userId) ?? '0'),
            mute: !isMyMicOn,
          );

          await agoraEngine?.muteLocalAudioStream(!isMyMicOn);
          if (isSpeaker) {
            if (currentOwner?.id == context.currentUser?.id) {
              final ref = FirebaseDatabase.instance.ref('rooms/${room?.roomFounderId}/owner');
              ref.update({'isMicOn': isMyMicOn});
            }
            final ref =
                FirebaseDatabase.instance.ref('rooms/${room?.roomFounderId}/speakers/${context.currentUser?.id}');
            ref.update({'isMicOn': isMyMicOn});
          } else {
            final ref =
                FirebaseDatabase.instance.ref('rooms/${room?.roomFounderId}/listeners/${context.currentUser?.id}');
            ref.update({'isMicOn': isMyMicOn});
          }
        },
        child: SizedBox(
          width: 30,
          child: Icon(
            isSpeaker == true
                ? isMyMicOn
                    ? FontAwesomeIcons.microphone
                    : FontAwesomeIcons.microphoneSlash
                : room?.listeners?.firstWhereOrNull((listener) => listener.id == context.currentUser?.id)?.isMicOn ==
                        true
                    ? FontAwesomeIcons.microphone
                    : FontAwesomeIcons.microphoneSlash,
            color: isSpeaker == true
                ? isMyMicOn
                    ? const Color(0xff7a8fa6)
                    : Colors.red
                : room?.listeners?.firstWhereOrNull((listener) => listener.id == context.currentUser?.id)?.isMicOn ==
                        true
                    ? const Color(0xff7a8fa6)
                    : Colors.red,
            size: 24,
          ),
        ),
      ),
    );
  }

  void _showChangeNameDialog() async {
    Future.delayed(const Duration(milliseconds: 10), () async {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Change Your Name'),
            content: TextField(
              controller: yourRoomNameController,
              decoration: const InputDecoration(hintText: 'Your Name'),
            ),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  yourRoomNameController.text = me?.name ?? '';
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  elevation: 0,
                ),
                child: const Text('Cancel').tr(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  print(yourRoomNameController.text);

                  if (me?.isSpeaker == true) {
                    // Update Name As A Speaker
                    final speakersRef = FirebaseDatabase.instance
                        .ref('rooms/${room?.roomFounderId}/speakers/${context.currentUser?.id}');
                    speakersRef.update({
                      'name': yourRoomNameController.text,
                    });

                    // Update Name if your an owner
                    if (currentOwner?.id == context.currentUser?.id) {
                      final ownerRef = FirebaseDatabase.instance.ref('rooms/${room?.roomFounderId}/owner');
                      ownerRef.update({
                        'name': yourRoomNameController.text,
                      });
                    }
                  } else {
                    // Update Name As A Listener
                    final listenersRef = FirebaseDatabase.instance
                        .ref('rooms/${room?.roomFounderId}/listeners/${context.currentUser?.id}');
                    listenersRef.update({
                      'name': yourRoomNameController.text,
                    });

                    // Update Name From Raised Hands
                    if (me?.isHandRaised == true) {
                      final raisedHandsRef = FirebaseDatabase.instance
                          .ref('rooms/${room?.roomFounderId}/raisedHands/${context.currentUser?.id}');
                      raisedHandsRef.update({
                        'name': yourRoomNameController.text,
                      });
                    }
                  }

                  // Update Name in room contacts
                  if (currentOwner?.id != context.currentUser?.id) {
                    final roomContactsRef = FirebaseDatabase.instance
                        .ref('rooms/${room?.roomFounderId}/room_contacts/${context.currentUser?.id}');
                    roomContactsRef.update({
                      'name': yourRoomNameController.text,
                    });
                  }
                },
                child: const Text('Change').tr(),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  void dispose() {
    onAddListener?.cancel();
    onChangeListener?.cancel();
    onDeleteListener?.cancel();
    agoraEngine?.leaveChannel();
    super.dispose();
  }
}
