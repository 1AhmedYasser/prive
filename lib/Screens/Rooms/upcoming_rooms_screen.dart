import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:prive/Extras/resources.dart';
import '../../Widgets/AppWidgets/prive_appbar.dart';

class UpComingRoomsScreen extends StatefulWidget {
  const UpComingRoomsScreen({Key? key}) : super(key: key);

  @override
  State<UpComingRoomsScreen> createState() => _UpComingRoomsScreenState();
}

class _UpComingRoomsScreenState extends State<UpComingRoomsScreen> {
  List<bool> notifications = [false, true, false, false, true, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 60),
        child: const PriveAppBar(title: "Upcoming Rooms"),
      ),
      body: AnimationLimiter(
        child: ListView.separated(
          itemCount: notifications.length,
          itemBuilder: (BuildContext context, int index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Padding(
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
                            padding: const EdgeInsets.only(
                                left: 25, top: 20, right: 25),
                            child: Row(
                              children: [
                                const Text(
                                  "20:00 AM",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "20 Oct",
                                  style: TextStyle(
                                    color: Color(0xff7a8fa6),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const Expanded(child: SizedBox()),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      notifications[index] =
                                          !notifications[index];
                                    });
                                  },
                                  child: Image.asset(
                                    notifications[index] == false
                                        ? R.images.roomNotifications
                                        : R.images.roomNotificationsOn,
                                    width: 20,
                                    height: 20,
                                    color: notifications[index] == false
                                        ? Colors.grey.shade400
                                        : Theme.of(context).primaryColor,
                                  ),
                                )
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Divider(),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(
                                left: 20, top: 10, bottom: 25, right: 20),
                            child: Text(
                              "What Movie To Watch In The Evening ?",
                              style: TextStyle(
                                color: Color(0xff5d5d63),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(height: 0);
          },
        ),
      ),
    );
  }
}
