import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Screens/Rooms/room_screen.dart';
import 'package:prive/Screens/Rooms/upcoming_rooms_screen.dart';
import 'package:prive/Widgets/AppWidgets/Rooms/new_room_widget.dart';
import 'package:prive/Widgets/Common/cached_image.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({Key? key}) : super(key: key);

  @override
  _RoomsScreenState createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;

  List _elements = [
    {'name': 'John', 'group': 'Your Room'},
    {'name': 'Will', 'group': 'Other Rooms'},
    {'name': 'Beth', 'group': 'Other Rooms'},
    {'name': 'Miranda', 'group': 'Other Rooms'},
  ];

  @override
  void initState() {
    _animationController = AnimationController(vsync: this);
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
          Expanded(
            child: AnimationLimiter(
              child: GroupedListView<dynamic, String>(
                shrinkWrap: true,
                elements: _elements,
                groupBy: (element) => element['group'],
                groupComparator: (value1, value2) => value2.compareTo(value1),
                order: GroupedListOrder.ASC,
                useStickyGroupSeparators: false,
                groupSeparatorBuilder: (String value) =>
                    AnimationConfiguration.staggeredList(
                  position: 0,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 25, bottom: 10, top: 10, right: 25),
                        child: Text(
                          value,
                          style: const TextStyle(
                            color: Color(0xff7a8fa6),
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                itemBuilder: (c, element) {
                  return AnimationConfiguration.staggeredList(
                    position: 0,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      horizontalOffset: 50.0,
                      child: FadeInAnimation(
                        child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RoomScreen(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, bottom: 20, top: 10),
                            child: Container(
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(17),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(
                                        left: 20, top: 20, right: 20),
                                    child: Text(
                                      "Discussing the best places in KSA",
                                      style: TextStyle(
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
                                      children: [
                                        buildSpeaker(),
                                        const SizedBox(width: 10),
                                        buildSpeaker(),
                                        const SizedBox(width: 10),
                                        buildSpeaker(),
                                        const SizedBox(width: 10),
                                        buildInfo("7", "speakers"),
                                        const SizedBox(width: 10),
                                        buildInfo("7", "listeners")
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
          ),
        ],
      ),
    );
  }

  Widget buildSpeaker() {
    return Expanded(
      child: Column(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 10,
              minWidth: 10,
              maxHeight: 60,
              maxWidth: 60,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: const CachedImage(
                url:
                    "https://cdnb.artstation.com/p/assets/images/images/032/393/609/large/anya-valeeva-annie-fan-art-2020.jpg?1606310067",
              ),
            ),
          ),
          const SizedBox(height: 5),
          const Text("Ahmed")
        ],
      ),
    );
  }

  Widget buildInfo(String value, String title) {
    return Column(
      children: [
        Text(
          "+$value",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
