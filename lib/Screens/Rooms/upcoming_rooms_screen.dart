import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:flutter_swipe_action_cell/core/controller.dart';
import 'package:lottie/lottie.dart';
import 'package:prive/Models/Rooms/room_user.dart';
import 'package:prive/Models/Rooms/upcoming_room.dart';
import 'package:prive/UltraNetwork/ultra_loading_indicator.dart';
import 'package:prive/Widgets/Common/cached_image.dart';
import '../../Extras/resources.dart';
import '../../Widgets/AppWidgets/prive_appbar.dart';
import 'package:prive/Helpers/stream_manager.dart';

class UpComingRoomsScreen extends StatefulWidget {
  const UpComingRoomsScreen({Key? key}) : super(key: key);

  @override
  State<UpComingRoomsScreen> createState() => _UpComingRoomsScreenState();
}

class _UpComingRoomsScreenState extends State<UpComingRoomsScreen> {
  List<UpcomingRoom> upcomingRoomsList = [];
  SwipeActionController controller = SwipeActionController();
  bool isLoading = true;
  final databaseReference = FirebaseDatabase.instance.ref('upcoming_rooms');
  StreamSubscription? onAddListener;
  StreamSubscription? onChangeListener;
  StreamSubscription? onRemoveListener;
  bool isFirstOpen = true;

  @override
  void initState() {
    _listenToFirebaseChanges();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 60),
        child: PriveAppBar(title: "Upcoming Rooms".tr()),
      ),
      body: isLoading
          ? const Padding(
              padding: EdgeInsets.only(bottom: 30),
              child: UltraLoadingIndicator(),
            )
          : upcomingRoomsList.isNotEmpty
              ? AnimationLimiter(
                  child: RefreshIndicator(
                    onRefresh: () => Future.sync(() => getUpcomingRooms()),
                    child: ListView.separated(
                      itemCount: upcomingRoomsList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: upcomingRoomsList[index].owner?.id ==
                                      context.currentUser?.id
                                  ? SwipeActionCell(
                                      controller: controller,
                                      index: index,
                                      key: ValueKey(upcomingRoomsList[index]),
                                      trailingActions: [
                                        SwipeAction(
                                          content: Image.asset(
                                            R.images.deleteChatImage,
                                            width: 15,
                                            color: Colors.red,
                                          ),
                                          color: Colors.transparent,
                                          onTap: (handler) async {
                                            await handler(true);
                                            FirebaseDatabase.instance
                                                .ref(
                                                    'upcoming_rooms/${upcomingRoomsList[index].owner?.id}/${upcomingRoomsList[index].roomId}')
                                                .remove();
                                            setState(() {
                                              upcomingRoomsList.removeAt(index);
                                            });
                                          },
                                        ),
                                      ],
                                      child: buildUpcomingRoomItem(index),
                                    )
                                  : buildUpcomingRoomItem(index),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(height: 0);
                      },
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          R.animations.upcomingRooms,
                          width: 140,
                          repeat: true,
                          fit: BoxFit.fill,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          "${"Upcoming Rooms".tr()}\n${"Will Appear Here".tr()}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey.shade600,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
    );
  }

  Padding buildUpcomingRoomItem(int index) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 10,
        top: index == 0 ? 20 : 10,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200.withOpacity(0.45),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 25, top: 20, right: 25),
              child: Row(
                children: [
                  Text(
                    DateFormat("hh:mm a", "en").format(
                      DateTime.parse(
                        upcomingRoomsList[index].time ??
                            DateTime.now().toString(),
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    DateFormat("d MMM", "en").format(
                      DateTime.parse(
                        upcomingRoomsList[index].time ??
                            DateTime.now().toString(),
                      ),
                    ),
                    style: const TextStyle(
                      color: Color(0xff7a8fa6),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  // const Expanded(child: SizedBox()),
                  // GestureDetector(
                  //   onTap: () {
                  //     // setState(() {
                  //     //   notifications[index] =
                  //     //       !notifications[index];
                  //     // });
                  //   },
                  //   child: Image.asset(
                  //     R.images.roomNotifications,
                  //     // notifications[index] == false
                  //     //     ? R.images.roomNotifications
                  //     //     : R.images.roomNotificationsOn,
                  //     width: 20,
                  //     height: 20,
                  //     color: Colors.grey.shade400,
                  //     // color: notifications[index] == false
                  //     //     ? Colors.grey.shade400
                  //     //     : Theme.of(context).primaryColor,
                  //   ),
                  // )
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Divider(),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, top: 10, bottom: 10, right: 20),
              child: Text(
                upcomingRoomsList[index].topic ?? "",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, top: 0, bottom: 15, right: 20),
              child: Text(
                upcomingRoomsList[index].description ?? "",
                style: const TextStyle(
                  color: Color(0xff5d5d63),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, top: 5, bottom: 25, right: 20),
              child: Row(
                children: [
                  Text(
                    "With /",
                    style: TextStyle(
                      color: Theme.of(context).primaryColorDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ).tr(),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    child: SizedBox(
                      height: 30,
                      width: 30,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedImage(
                          url: upcomingRoomsList[index].owner?.image ?? "",
                        ),
                      ),
                    ),
                  ),
                  Text(
                    upcomingRoomsList[index].owner?.name ?? "",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _listenToFirebaseChanges() {
    databaseReference.once().then((event) {
      getUpcomingRooms();
      onAddListener = databaseReference.onChildAdded.listen((event) {
        if (isFirstOpen == false) {
          getUpcomingRooms();
        }
      });
      isFirstOpen = false;
    });
    onChangeListener = databaseReference.onChildChanged.listen((event) {
      getUpcomingRooms();
    });
    onRemoveListener = databaseReference.onChildRemoved.listen((event) {
      getUpcomingRooms();
    });
  }

  void getUpcomingRooms() async {
    final snapshot = await databaseReference.get();
    if (snapshot.exists) {
      Map<dynamic, dynamic> upcomingRoomsResponse =
          snapshot.value as Map<dynamic, dynamic>? ?? {};
      upcomingRoomsList.clear();
      upcomingRoomsResponse.forEach((key, value) {
        Map<dynamic, dynamic> upcomingRooms = value as Map<dynamic, dynamic>;
        upcomingRooms.forEach((key, value) {
          String roomId = key;
          String topic = "";
          String description = "";
          RoomUser? owner;
          List<String> contacts = [];
          String dateTime = "";
          topic = value['topic'];
          description = value['description'];
          dateTime = value['date_time'];
          owner = RoomUser(
            id: value['owner']['id'],
            name: value['owner']['name'],
            image: value['owner']['image'],
            isOwner: value['owner']['isOwner'],
            isSpeaker: value['owner']['isSpeaker'],
            isListener: value['owner']['isListener'],
            phone: value['owner']['phone'],
            isHandRaised: value['owner']['isHandRaised'],
            isMicOn: value['owner']['isMicOn'],
          );
          Map<dynamic, dynamic>? roomContacts =
              (value['room_contacts'] as Map<dynamic, dynamic>?) ?? {};
          roomContacts.forEach((key, value) {
            contacts.add(key);
          });
          upcomingRoomsList.add(
            UpcomingRoom(
              roomId: roomId,
              topic: topic,
              description: description,
              owner: owner,
              roomContacts: contacts,
              time: dateTime,
            ),
          );
        });
      });
      List<UpcomingRoom> myUpcomingRooms = upcomingRoomsList
          .where((element) => element.owner?.id == context.currentUser?.id)
          .toList();
      myUpcomingRooms.addAll(upcomingRoomsList
          .where((element) =>
              element.owner?.id != context.currentUser?.id &&
              element.roomContacts?.contains(context.currentUser?.id) == true)
          .toList());

      upcomingRoomsList = myUpcomingRooms;

      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        upcomingRoomsList.clear();
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    onAddListener?.cancel();
    onChangeListener?.cancel();
    onRemoveListener?.cancel();
    super.dispose();
  }
}
