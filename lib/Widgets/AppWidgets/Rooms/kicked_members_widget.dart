import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:prive/Models/Rooms/room_user.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:prive/Widgets/Common/cached_image.dart';

class KickedMembersWidget extends StatefulWidget {
  final String ref;
  final RtcEngine? agoraEngine;
  const KickedMembersWidget({Key? key, required this.ref, this.agoraEngine}) : super(key: key);

  @override
  State<KickedMembersWidget> createState() => _KickedMembersWidgetState();
}

class _KickedMembersWidgetState extends State<KickedMembersWidget> {
  List<RoomUser> kickedMembers = [];
  StreamSubscription? onAddListener;
  StreamSubscription? onChangeListener;
  StreamSubscription? onDeleteListener;

  @override
  void initState() {
    _listenToFirebaseChanges();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25),
          topLeft: Radius.circular(25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30, left: 30, right: 30),
            child: Text(
              "${"Kicked Members".tr()} ${kickedMembers.isNotEmpty ? "(${kickedMembers.length})" : ""}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
              child: kickedMembers.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: const Text(
                          'No Kicked Members',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ).tr(),
                      ),
                    )
                  : MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      removeBottom: true,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: kickedMembers.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: SizedBox(
                                    height: 60,
                                    width: 60,
                                    child: CachedImage(
                                      url: kickedMembers[index].image ?? '',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Text(
                                  kickedMembers[index].name ?? '',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Expanded(child: SizedBox()),
                                ElevatedButton(
                                  onPressed: () {
                                    final ref =
                                        FirebaseDatabase.instance.ref('${widget.ref}/${kickedMembers[index].id}');
                                    ref.remove();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColorDark,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Text('Un Kick'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void getKickedMembers() async {
    final ref = FirebaseDatabase.instance.ref(widget.ref);
    final res = await ref.once();
    kickedMembers.clear();
    if (res.snapshot.exists) {
      Map<dynamic, dynamic>? response = (res.snapshot.value as Map<dynamic, dynamic>? ?? {});
      response.forEach((key, value) {
        kickedMembers.add(
          RoomUser(
            id: value['id'],
            name: value['name'],
            image: value['image'],
            isOwner: value['isOwner'],
            isSpeaker: value['isSpeaker'],
            isListener: value['isListener'],
            phone: value['phone'],
            isHandRaised: value['isHandRaised'],
            timeOfRaisingHands: value['timeOfRaisingHands'],
            hasPermissionToSpeak: value['hasPermissionToSpeak'],
            isMicOn: value['isMicOn'],
          ),
        );
      });
      kickedMembers.sort((a, b) {
        DateTime aDate = DateTime.parse(a.timeOfRaisingHands ?? '');
        DateTime bDate = DateTime.parse(b.timeOfRaisingHands ?? '');
        return aDate.compareTo(bDate);
      });
      setState(() {});
    } else {
      setState(() {});
    }
  }

  void _listenToFirebaseChanges() {
    final ref = FirebaseDatabase.instance.ref(widget.ref);
    onAddListener = ref.onChildAdded.listen((event) {
      getKickedMembers();
    });
    onChangeListener = ref.onChildChanged.listen((event) {
      getKickedMembers();
    });
    onChangeListener = ref.onChildRemoved.listen((event) {
      getKickedMembers();
    });
  }

  @override
  void dispose() {
    onAddListener?.cancel();
    onChangeListener?.cancel();
    onDeleteListener?.cancel();
    super.dispose();
  }
}
