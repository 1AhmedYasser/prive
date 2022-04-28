import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Widgets/Common/cached_image.dart';

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
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
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
                  buildRoomSectionInfo("Speakers", "3"),
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
                          itemCount: 1,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: const CachedImage(
                                    url:
                                        "https://cdnb.artstation.com/p/assets/images/images/032/393/609/large/anya-valeeva-annie-fan-art-2020.jpg?1606310067",
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: const [
                                    SizedBox(
                                      width: 20,
                                      child: Icon(
                                        FontAwesomeIcons.microphone,
                                        color: Color(0xff7a8fa6),
                                        size: 15,
                                      ),
                                    ),
                                    SizedBox(width: 3),
                                    Expanded(
                                      child: Text(
                                        "Ahmed",
                                        style: TextStyle(
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
                  buildRoomSectionInfo("Listeners", "25"),
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
                        itemCount: 3,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: const CachedImage(
                                  url:
                                      "https://cdnb.artstation.com/p/assets/images/images/032/393/609/large/anya-valeeva-annie-fan-art-2020.jpg?1606310067",
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: const [
                                  SizedBox(
                                    width: 20,
                                    child: Icon(
                                      FontAwesomeIcons.microphoneSlash,
                                      color: Colors.red,
                                      size: 15,
                                    ),
                                  ),
                                  SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      "Ahmed",
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                      maxLines: 1,
                                    ),
                                  )
                                ],
                              )
                            ],
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
            bottom: 60,
            right: 30,
            child: Badge(
              badgeContent: const Text(
                '3',
                style: TextStyle(color: Colors.white),
              ),
              position: BadgePosition.topEnd(end: -4),
              padding: const EdgeInsets.all(7),
              badgeColor: Theme.of(context).primaryColorDark,
              child: FloatingActionButton(
                elevation: 1,
                onPressed: () {},
                child: Image.asset(
                  R.images.raiseHandIcon,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Padding buildRoomSectionInfo(String title, String value) {
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
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xff7a8fa6),
              fontSize: 15.5,
              fontWeight: FontWeight.w400,
            ),
          )
        ],
      ),
    );
  }
}
