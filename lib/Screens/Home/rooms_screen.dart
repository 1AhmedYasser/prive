import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Screens/Rooms/room_screen.dart';
import 'package:prive/Screens/Rooms/upcoming_rooms_screen.dart';
import 'package:prive/Widgets/AppWidgets/Rooms/new_room_widget.dart';
import 'package:prive/Widgets/Common/cached_image.dart';

import '../../Models/Rooms/room.dart';
import '../../Models/Rooms/room_user.dart';
import '../../UltraNetwork/ultra_loading_indicator.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({Key? key}) : super(key: key);

  @override
  _RoomsScreenState createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  List<Room> roomsList = [];
  final databaseReference = FirebaseDatabase.instance.ref('rooms');
  bool isLoading = true;
  StreamSubscription? onAddListener;
  StreamSubscription? onChangeListener;
  StreamSubscription? onRemoveListener;
  bool isFirstOpen = true;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this);
    _listenToFirebaseChanges();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(35),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarBrightness: Brightness.light,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 25),
            child: Column(
                children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(
                  child: widget,
                ),
              ),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Rooms",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    SizedBox(
                      width: 20,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UpComingRoomsScreen(),
                            ),
                          );
                        },
                        child: Image.asset(R.images.chatRoomsIcons),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showMaterialModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) => SingleChildScrollView(
                            controller: ModalScrollController.of(context),
                            child: const NewRoomWidget(),
                          ),
                        );
                      },
                      child: const Text("Start A Room"),
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            )),
          ),
          const SizedBox(height: 25),
          isLoading
              ? SizedBox(
                  height: MediaQuery.of(context).size.height / 1.6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [UltraLoadingIndicator()],
                  ),
                )
              : roomsList.isNotEmpty
                  ? Expanded(
                      child: AnimationLimiter(
                        child: ListView.builder(
                          itemCount: roomsList.length,
                          itemBuilder: (context, index) {
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                horizontalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      if (roomsList[index].roomId?.isNotEmpty ==
                                          true) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => RoomScreen(
                                              room: roomsList[index],
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20,
                                          right: 20,
                                          bottom: 0,
                                          top: 25),
                                      child: Container(
                                        height: 150,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200
                                              .withOpacity(0.5),
                                          borderRadius:
                                              BorderRadius.circular(17),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20, top: 20, right: 20),
                                              child: Text(
                                                roomsList[index].topic ?? "",
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15.5,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 20,
                                                top: 15,
                                                right: 20,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  if (roomsList[index]
                                                          .speakers
                                                          ?.isNotEmpty ==
                                                      true)
                                                    buildSpeaker(
                                                        roomsList[index]
                                                            .speakers
                                                            ?.first),
                                                  if ((roomsList[index]
                                                              .speakers
                                                              ?.length ??
                                                          0) >
                                                      1)
                                                    buildSpeaker(
                                                        roomsList[index]
                                                            .speakers?[1]),
                                                  if ((roomsList[index]
                                                              .speakers
                                                              ?.length ??
                                                          0) >
                                                      2)
                                                    buildSpeaker(
                                                        roomsList[index]
                                                            .speakers?[2]),
                                                  buildInfo(
                                                      "${(roomsList[index].speakers?.length ?? 0) > 3 ? "+${((roomsList[index].speakers?.length ?? 0) - 3)}" : roomsList[index].speakers?.length ?? 0}",
                                                      "speakers"),
                                                  buildInfo(
                                                      "${roomsList[index].listeners?.length ?? 0}",
                                                      "listeners")
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  : SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 1.5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            R.animations.noRooms,
                            width: MediaQuery.of(context).size.width / 1.3,
                            fit: BoxFit.fill,
                            controller: _animationController,
                            onLoaded: (composition) {
                              _animationController
                                ..duration = composition.duration
                                ..forward()
                                ..repeat(min: 0.4, max: 1);
                            },
                          ),
                          const SizedBox(height: 25),
                          const Text(
                            "Start Creating Rooms Now",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
        ],
      ),
    );
  }

  Widget buildSpeaker(RoomUser? speaker) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: 50,
                minWidth: 50,
                maxHeight: 50,
                maxWidth: 50,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CachedImage(
                  url: speaker?.image ?? "",
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text((speaker?.name?.split(" ").first ?? "").trim())
          ],
        ),
      ),
    );
  }

  Widget buildInfo(String value, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            int.parse(value) != 1
                ? title
                : title.substring(0, title.length - 1),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _listenToFirebaseChanges() {
    databaseReference.once().then((event) {
      getRooms();
      onAddListener = databaseReference.onChildAdded.listen((event) {
        if (isFirstOpen == false) {
          getRooms();
        }
      });
      isFirstOpen = false;
    });
    onChangeListener = databaseReference.onChildChanged.listen((event) {
      getRooms();
    });
    onRemoveListener = databaseReference.onChildRemoved.listen((event) {
      getRooms();
    });
  }

  void getRooms() async {
    final snapshot = await databaseReference.get();
    if (snapshot.exists) {
      Map<dynamic, dynamic>? roomsResponse =
          snapshot.value as Map<dynamic, dynamic>? ?? {};
      roomsList.clear();
      roomsResponse.forEach((key, value) {
        Map<dynamic, dynamic> rooms = value as Map<dynamic, dynamic>;
        String roomId = rooms['roomId'];
        String topic = "";
        RoomUser? owner;
        List<RoomUser>? speakers = [];
        List<RoomUser>? listeners = [];
        List<String> contacts = [];
        List<RoomUser>? raisedHands = [];
        topic = rooms['topic'];
        owner = RoomUser(
          id: rooms['owner']['id'],
          name: rooms['owner']['name'],
          image: rooms['owner']['image'],
          isOwner: rooms['owner']['isOwner'],
          isSpeaker: rooms['owner']['isSpeaker'],
          isListener: rooms['owner']['isListener'],
          phone: rooms['owner']['phone'],
          isHandRaised: rooms['owner']['isHandRaised'],
          isMicOn: rooms['owner']['isMicOn'],
        );
        Map<dynamic, dynamic>? roomContacts =
            (value['room_contacts'] as Map<dynamic, dynamic>?) ?? {};
        roomContacts.forEach((key, value) {
          contacts.add(key);
        });

        Map<dynamic, dynamic>? speakersList =
            (value['speakers'] as Map<dynamic, dynamic>?) ?? {};
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
              isMicOn: value['isMicOn'],
            ),
          );
        });

        Map<dynamic, dynamic>? listenersList =
            (value['listeners'] as Map<dynamic, dynamic>?) ?? {};
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
              isMicOn: value['isMicOn'],
            ),
          );
        });

        Map<dynamic, dynamic>? raisedHandsList =
            (value['raisedHands'] as Map<dynamic, dynamic>?) ?? {};
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
              isMicOn: value['isMicOn'],
            ),
          );
        });
        roomsList.add(
          Room(
            roomId: roomId,
            topic: topic,
            owner: owner,
            speakers: speakers,
            listeners: listeners,
            roomContacts: contacts,
            raisedHands: raisedHands,
          ),
        );
      });

      // Filter out my rooms and the rooms iam not in
      roomsList = roomsList
          .where((element) =>
              element.owner?.id != context.currentUser?.id &&
              element.roomContacts?.contains(context.currentUser?.id) == true)
          .toList();
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        roomsList.clear();
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    onAddListener?.cancel();
    onChangeListener?.cancel();
    onRemoveListener?.cancel();
    _animationController.dispose();
    super.dispose();
  }
}
