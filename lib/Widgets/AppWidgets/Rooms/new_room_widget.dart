import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Models/Rooms/room_user.dart';
import 'package:prive/Screens/Rooms/people_chooser_screen.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../../../Helpers/Utils.dart';
import '../../../Models/Rooms/room.dart';
import '../../../Screens/Rooms/room_screen.dart';

class NewRoomWidget extends StatefulWidget {
  const NewRoomWidget({Key? key}) : super(key: key);

  @override
  State<NewRoomWidget> createState() => _NewRoomWidgetState();
}

class _NewRoomWidgetState extends State<NewRoomWidget> {
  int selectedRoomType = 0;
  final _formKey = GlobalKey<FormState>();
  DateTime? selectedDateTime;
  List<bool> isSelected = [true, false];
  List<User> users = [];
  TextEditingController topicNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    selectedDateTime = DateTime.now();
    _getContacts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(25),
            topLeft: Radius.circular(25),
          ),
        ),
        child: Padding(
          padding:
              const EdgeInsets.only(left: 40, top: 30, right: 40, bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "New Room",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ).tr(),
              const SizedBox(height: 20),
              const Text(
                "What Will Your Room Be About ?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ).tr(),
              const SizedBox(height: 15),
              _buildRoomField(
                controller: topicNameController,
                hint: "Topic Name".tr(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter A Topic Name'.tr();
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                "Tell Us About Your Room",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ).tr(),
              const SizedBox(height: 15),
              _buildRoomField(
                controller: descriptionController,
                hint: "Room Description".tr(),
                maxLines: 3,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                validator: (value) {
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                "Choose Your Room",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ).tr(),
              const SizedBox(height: 15),
              buildRoomType(
                  R.images.publicRoom,
                  "Open For Every One".tr(),
                  "Start A Public Room Open For Every One In Your Contacts"
                      .tr(),
                  0, () {
                setState(() {
                  selectedRoomType = 0;
                });
              }),
              const SizedBox(height: 15),
              buildRoomType(R.images.closedRoom, "Closed".tr(),
                  "Start A Private Room With These People".tr(), 1, () {
                setState(() {
                  selectedRoomType = 1;
                });
              }),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Choose Date & Time".tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 27,
                      child: ToggleButtons(
                        borderColor: Colors.grey.shade600,
                        fillColor: Theme.of(context).primaryColor,
                        borderWidth: 1,
                        selectedBorderColor: Colors.grey.shade600,
                        selectedColor: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        onPressed: (int index) {
                          setState(() {
                            for (int i = 0; i < isSelected.length; i++) {
                              isSelected[i] = i == index;
                            }
                          });
                        },
                        isSelected: isSelected,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(2),
                            child: const Text(
                              'Now',
                              style: TextStyle(fontSize: 12),
                            ).tr(),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2),
                            child: const Text(
                              'Later',
                              style: TextStyle(fontSize: 12),
                            ).tr(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected[1] == true)
                Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 10),
                  child: Row(
                    children: [
                      buildOption(
                          DateFormat('d MMM yyyy').format(
                            selectedDateTime ?? DateTime.now(),
                          ),
                          R.images.calendarImage, () {
                        showDatePicker();
                      }),
                      const SizedBox(
                        width: 10,
                      ),
                      buildOption(
                          DateFormat('hh:mm a').format(
                            selectedDateTime ?? DateTime.now(),
                          ),
                          R.images.clockImage, () {
                        showDatePicker(isTime: true);
                      }),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      RoomUser owner = RoomUser(
                        id: context.currentUser?.id ?? "",
                        name: context.currentUser?.name ?? "",
                        image: context.currentUser?.image ?? "",
                        isOwner: true,
                        isSpeaker: true,
                        hasPermissionToSpeak: true,
                        isListener: false,
                        phone:
                            context.currentUser?.extraData['phone'] as String,
                        isHandRaised: false,
                        isMicOn: true,
                      );

                      Map<String, Map<String, dynamic>> roomContacts = {};
                      for (var user in users) {
                        roomContacts[user.id] = RoomUser(
                          id: user.id,
                          name: user.name,
                          image: user.image,
                          isOwner: false,
                          isSpeaker: false,
                          hasPermissionToSpeak: false,
                          isListener: true,
                          phone: user.extraData["phone"] as String,
                          isHandRaised: false,
                          isMicOn: false,
                        ).toJson();
                      }
                      if (selectedRoomType == 0) {
                        if (isSelected.first == false) {
                          if (selectedDateTime?.isBefore(DateTime.now()) ==
                              true) {
                            selectedDateTime = DateTime.now();
                          }
                          Navigator.pop(context);
                          DatabaseReference ref = FirebaseDatabase.instance.ref(
                              "upcoming_rooms/${context.currentUser?.id ?? ""}/${DateFormat('yyyyMMddhhmmmss').format(selectedDateTime ?? DateTime.now()).toString()}");
                          await ref.set({
                            "topic": topicNameController.text,
                            "description": descriptionController.text,
                            "owner": owner.toJson(),
                            "speakers": {owner.id: owner.toJson()},
                            "listeners": {},
                            "room_contacts": roomContacts,
                            "raised_hands": {},
                            "date_time": selectedDateTime.toString()
                          });
                        } else {
                          DatabaseReference ref = FirebaseDatabase.instance
                              .ref("rooms/${context.currentUser?.id ?? ""}");
                          String roomId = DateFormat('yyyyMMddhhmmmss', "en")
                              .format(selectedDateTime ?? DateTime.now())
                              .toString();
                          await ref.set({
                            "topic": topicNameController.text,
                            "description": descriptionController.text,
                            "owner": owner.toJson(),
                            "speakers": {owner.id: owner.toJson()},
                            "listeners": {},
                            "room_contacts": roomContacts,
                            "raised_hands": {},
                            "roomId": roomId
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
                                    topic: topicNameController.text,
                                    description: descriptionController.text,
                                    owner: owner,
                                    speakers: [owner],
                                    listeners: [],
                                    roomContacts: [],
                                    raisedHands: [],
                                  ),
                                ),
                              ),
                            );
                          }
                        }
                      } else {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PeopleChooserScreen(
                              roomName: topicNameController.text.trim(),
                              roomDescription:
                                  descriptionController.text.trim(),
                              isNow: isSelected.first,
                              selectedDateTime:
                                  selectedDateTime ?? DateTime.now(),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    minimumSize: Size(MediaQuery.of(context).size.width, 50),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    selectedRoomType == 0
                        ? isSelected.first
                            ? "Start Room"
                            : "Schedule Room"
                        : "Choose People",
                    style: const TextStyle(fontSize: 18),
                  ).tr(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _buildRoomField(
      {required TextEditingController controller,
      String hint = "",
      int maxLines = 1,
      required Function validator,
      EdgeInsets contentPadding =
          const EdgeInsets.symmetric(horizontal: 25, vertical: 10)}) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.text,
      cursorColor: const Color(0xff777777),
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: contentPadding,
        labelStyle: const TextStyle(
          color: Color(0xff777777),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(12),
          ),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(12),
          ),
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: (value) => validator(value),
    );
  }

  Future<dynamic> showDatePicker({bool isTime = false}) {
    DateTime chosenDateTime = DateTime(
      selectedDateTime?.year ?? DateTime.now().year,
      selectedDateTime?.month ?? DateTime.now().month,
      selectedDateTime?.day ?? DateTime.now().day,
      selectedDateTime?.hour ?? DateTime.now().hour,
      (selectedDateTime?.minute ?? DateTime.now().minute) + 5,
      selectedDateTime?.second ?? DateTime.now().second,
      selectedDateTime?.millisecond ?? DateTime.now().millisecond,
      selectedDateTime?.microsecond ?? DateTime.now().microsecond,
    );
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 250,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 17,
                        ),
                      ).tr(),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          if (isTime == false) {
                            selectedDateTime = DateTime(
                              chosenDateTime.year,
                              chosenDateTime.month,
                              chosenDateTime.day,
                              selectedDateTime?.hour ?? 0,
                              selectedDateTime?.minute ?? 0,
                              selectedDateTime?.second ?? 0,
                              selectedDateTime?.millisecond ?? 0,
                              selectedDateTime?.microsecond ?? 0,
                            );
                          } else {
                            selectedDateTime = chosenDateTime;
                          }
                        });
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Done",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 17,
                        ),
                      ).tr(),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 160,
                child: CupertinoDatePicker(
                  minimumYear: DateTime.now().year,
                  minimumDate: DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                      DateTime.now().hour,
                      chosenDateTime.minute),
                  initialDateTime: chosenDateTime,
                  mode: isTime
                      ? CupertinoDatePickerMode.time
                      : CupertinoDatePickerMode.date,
                  onDateTimeChanged: (dateTime) {
                    chosenDateTime = dateTime;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Expanded buildOption(String value, String icon, Function onPressed) {
    return Expanded(
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () => onPressed(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(7),
          ),
          height: 37,
          child: Row(
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Image.asset(
                icon,
                width: 15,
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRoomType(String image, String title, String description, int type,
      Function onPressed) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () => onPressed(),
      child: Row(
        children: [
          Image.asset(
            image,
            width: 55,
            height: 55,
          ),
          const SizedBox(
            width: 13,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          Icon(
            FontAwesomeIcons.check,
            color: selectedRoomType == type ? Colors.green : Colors.transparent,
          )
        ],
      ),
    );
  }

  _getContacts() async {
    String? myContacts = await Utils.getString(R.pref.myContacts);
    if (myContacts != null &&
        myContacts.isNotEmpty == true &&
        myContacts != "[]") {
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
      setState(() {});
    } else {
      if (!await FlutterContacts.requestPermission(readonly: true)) {
        // TODO: Permission Needed
      } else {
        List contacts = await Utils.fetchContacts(context);
        users = contacts.first;
      }
    }
  }
}
