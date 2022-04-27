import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prive/Extras/resources.dart';

import '../../Widgets/AppWidgets/prive_appbar.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({Key? key}) : super(key: key);

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  bool isMyMicOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 60),
        child: AppBar(
          backgroundColor: Colors.grey.shade100,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarBrightness: Brightness.light,
          ),
          leading: const BackButton(
            color: Color(0xff7a8fa6),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isMyMicOn = !isMyMicOn;
                });
              },
              child: SizedBox(
                width: 30,
                child: Icon(
                  isMyMicOn
                      ? FontAwesomeIcons.microphone
                      : FontAwesomeIcons.microphoneSlash,
                  color: isMyMicOn ? const Color(0xff7a8fa6) : Colors.red,
                  size: 24,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  right: 20, left: 15, top: 10, bottom: 10),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
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
                    ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 20, top: 18, right: 20),
            child: Text(
              "Discussing the best places in KSA",
              style: TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 20, top: 10, right: 20),
            child: Divider(),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 14, right: 20),
            child: Row(
              children: const [
                Text(
                  "Speakers",
                  style: TextStyle(
                    color: Color(0xff7a8fa6),
                    fontSize: 16.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  "3",
                  style: TextStyle(
                    color: Color(0xff7a8fa6),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
