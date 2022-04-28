import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prive/Extras/resources.dart';
import 'package:intl/intl.dart';
import 'package:prive/Screens/Rooms/people_chooser_screen.dart';

class NewRoomWidget extends StatefulWidget {
  const NewRoomWidget({Key? key}) : super(key: key);

  @override
  State<NewRoomWidget> createState() => _NewRoomWidgetState();
}

class _NewRoomWidgetState extends State<NewRoomWidget> {
  int selectedRoom = 0;
  final _formKey = GlobalKey<FormState>();
  DateTime? selectedDateTime;
  List<bool> isSelected = [true, false];
  TextEditingController topicNameController = TextEditingController();

  @override
  void initState() {
    selectedDateTime = DateTime.now();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
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
              ),
              const SizedBox(height: 20),
              const Text(
                "What Will Your Room Be About ?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: topicNameController,
                keyboardType: TextInputType.text,
                cursorColor: const Color(0xff777777),
                decoration: InputDecoration(
                  hintText: "Topic Name",
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
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
                    borderSide: BorderSide(
                        color: Theme.of(context).primaryColor, width: 2),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter A Topic Name';
                  }

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
              ),
              const SizedBox(height: 15),
              buildRoomType(
                  R.images.publicRoom,
                  "Open For Every One",
                  "Start A Public Room Open For Every One In Your Contacts",
                  0, () {
                setState(() {
                  selectedRoom = 0;
                });
              }),
              const SizedBox(height: 15),
              buildRoomType(R.images.closedRoom, "Closed",
                  "Start A Private Room With These People", 1, () {
                setState(() {
                  selectedRoom = 1;
                });
              }),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 15),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Choose Date & Time",
                        style: TextStyle(
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
                        children: const <Widget>[
                          Padding(
                            padding: EdgeInsets.all(2),
                            child: Text(
                              'Now',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(2),
                            child: Text(
                              'Later',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                        onPressed: (int index) {
                          setState(() {
                            for (int i = 0; i < isSelected.length; i++) {
                              isSelected[i] = i == index;
                            }
                          });
                        },
                        isSelected: isSelected,
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (selectedRoom == 0) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PeopleChooserScreen(
                              roomName: topicNameController.text.trim(),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    selectedRoom == 0 ? "Start Room" : "Choose People",
                    style: const TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                    minimumSize: Size(MediaQuery.of(context).size.width, 50),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
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
                      ),
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
                      ),
                    )
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            color: selectedRoom == type ? Colors.green : Colors.transparent,
          )
        ],
      ),
    );
  }
}