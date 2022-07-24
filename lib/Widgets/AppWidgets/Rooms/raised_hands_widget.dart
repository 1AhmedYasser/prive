import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prive/Models/Rooms/room_user.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../Common/cached_image.dart';

class RaisedHandsWidget extends StatefulWidget {
  final String roomRef;
  final RtcEngine? agoraEngine;
  const RaisedHandsWidget({Key? key, required this.roomRef, this.agoraEngine})
      : super(key: key);

  @override
  State<RaisedHandsWidget> createState() => _RaisedHandsWidgetState();
}

class _RaisedHandsWidgetState extends State<RaisedHandsWidget> {
  List<RoomUser> raisedHands = [];
  StreamSubscription? onAddListener;
  StreamSubscription? onChangeListener;
  StreamSubscription? onDeleteListener;

  @override
  void initState() {
    _listenToFirebaseChanges();
    // getRaisedHands();
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
              "${"Raised Hands".tr()} ${raisedHands.isNotEmpty ? "(${raisedHands.length})" : ""}",
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
              child: raisedHands.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: const Text(
                          "No Raised Hands",
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
                        itemCount: raisedHands.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                if (raisedHands[index].isMicOn == true) {
                                  raisedHands[index].isMicOn = false;
                                  FirebaseDatabase.instance
                                      .ref(
                                          "${widget.roomRef}/raisedHands/${raisedHands[index].id}")
                                      .update({"isMicOn": false});
                                  FirebaseDatabase.instance
                                      .ref(
                                          "${widget.roomRef}/listeners/${raisedHands[index].id}")
                                      .update({"isMicOn": false});
                                } else {
                                  raisedHands[index].isMicOn = true;
                                  FirebaseDatabase.instance
                                      .ref(
                                          "${widget.roomRef}/raisedHands/${raisedHands[index].id}")
                                      .update({"isMicOn": true});
                                  FirebaseDatabase.instance
                                      .ref(
                                          "${widget.roomRef}/listeners/${raisedHands[index].id}")
                                      .update({"isMicOn": true});
                                }
                                setState(() {});
                              },
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: SizedBox(
                                      height: 60,
                                      width: 60,
                                      child: CachedImage(
                                        url: raisedHands[index].image ?? "",
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Text(
                                    raisedHands[index].name ?? "",
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Expanded(child: SizedBox()),
                                  SizedBox(
                                    width: 30,
                                    child: Icon(
                                      raisedHands[index].isMicOn == true
                                          ? FontAwesomeIcons.microphone
                                          : FontAwesomeIcons.microphoneSlash,
                                      color: raisedHands[index].isMicOn == true
                                          ? const Color(0xff7a8fa6)
                                          : Colors.red,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: raisedHands[index].isMicOn == true
                                          ? Theme.of(context).primaryColor
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color:
                                            raisedHands[index].isMicOn == true
                                                ? Theme.of(context).primaryColor
                                                : const Color(0xff7a8fa6),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Icon(
                                        raisedHands[index].isMicOn == true
                                            ? FontAwesomeIcons.check
                                            : null,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ),
                                  )
                                ],
                              ),
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

  void getRaisedHands() async {
    final ref = FirebaseDatabase.instance.ref("${widget.roomRef}/raisedHands");
    final res = await ref.once();
    raisedHands.clear();
    if (res.snapshot.exists) {
      print(res.snapshot.value);
      Map<dynamic, dynamic>? response =
          (res.snapshot.value as Map<dynamic, dynamic>? ?? {});
      response.forEach((key, value) {
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
            isMicOn: value['isMicOn'],
          ),
        );
      });
      setState(() {});
    } else {
      setState(() {});
    }
  }

  void _listenToFirebaseChanges() {
    final ref = FirebaseDatabase.instance.ref("${widget.roomRef}/raisedHands");
    onAddListener = ref.onChildAdded.listen((event) {
      getRaisedHands();
    });
    onChangeListener = ref.onChildChanged.listen((event) {
      getRaisedHands();
    });
    onChangeListener = ref.onChildRemoved.listen((event) {
      getRaisedHands();
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
