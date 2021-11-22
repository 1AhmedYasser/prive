import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lottie/lottie.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/UltraNetwork/ultra_loading_indicator.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class ChannelsScreen extends StatefulWidget {
  const ChannelsScreen({Key? key}) : super(key: key);

  @override
  _ChannelsScreenState createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen>
    with TickerProviderStateMixin {
  final List<String> _tabs = ["Chats", "Groups", "Important", "Archive"];

  final channelListController = ChannelListController();
  late final AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.isEmpty ? 1 : _tabs.length,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(140),
          child: Theme(
            data: ThemeData(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
            ),
            child: AppBar(
              elevation: 0,
              backgroundColor: Colors.grey.shade200.withOpacity(0.4),
              titleSpacing: 0,
              title: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, left: 25, right: 25),
                  child: Image.asset(
                    R.images.logoImage,
                    height: 40,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              bottom: _tabs.isEmpty
                  ? null
                  : PreferredSize(
                      preferredSize:
                          Size(MediaQuery.of(context).size.width, 50),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 12),
                              Expanded(
                                child: TabBar(
                                  onTap: (index) {},
                                  unselectedLabelColor: Colors.grey,
                                  indicatorSize: TabBarIndicatorSize.label,
                                  labelColor:
                                      Theme.of(context).primaryColorDark,
                                  isScrollable: true,
                                  labelStyle:
                                      const TextStyle(color: Color(0xff1293a8)),
                                  labelPadding:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  indicator: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(
                                      color: const Color(0xff1293a8),
                                      width: 1,
                                    ),
                                  ),
                                  tabs: _tabs.map(
                                    (String name) {
                                      return SizedBox(
                                        child: Tab(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              //     color: Color(0xff1293a8),
                                              border: Border.all(
                                                color: Colors.transparent,
                                                width: 0.3,
                                              ),
                                            ),
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 20, right: 20),
                                                child: Text(
                                                  name,
                                                  style: const TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        height: 38,
                                      );
                                    },
                                  ).toList(),
                                ),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
              actions: [
                Row(
                  children: [
                    ClipRRect(
                      child: Image.asset(
                        R.images.searchImage,
                        width: 25,
                        fit: BoxFit.fill,
                      ),
                    ),
                    const SizedBox(width: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        R.images.profileImage,
                        width: 40,
                        fit: BoxFit.fill,
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: ChannelListCore(
          channelListController: channelListController,
          filter: Filter.and(
            [
              Filter.equal('type', 'messaging'),
              Filter.in_('members', [
                StreamChatCore.of(context).currentUser!.id,
              ])
            ],
          ),
          emptyBuilder: (context) => SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  R.animations.emptyChannels,
                  width: MediaQuery.of(context).size.width / 1.6,
                  fit: BoxFit.fill,
                  controller: _animationController,
                  onLoaded: (composition) {
                    // Configure the AnimationController with the duration of the
                    // Lottie file and start the animation.
                    _animationController
                      ..duration = composition.duration
                      ..forward()
                      ..repeat(min: 0.2,max: 1);
                  },
                ),
                const SizedBox(height: 25),
                const Text(
                  "No Messages Yet",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 15),
                const Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Text(
                    "Start Chatting With Your Friends Right Now",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                )
              ],
            ),
          ),
          errorBuilder: (context, error) => Center(
            child: Text(
              'Error: $error',
              textAlign: TextAlign.center,
            ),
          ),
          loadingBuilder: (
            context,
          ) =>
              const UltraLoadingIndicator(),
          listBuilder: (context, channels) {
            return ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: 6,
              itemBuilder: (BuildContext context, int index) =>
                  AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        right: 22, top: 30, left: 15, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Stack(
                              children: [
                                SizedBox(
                                  child: Image.asset(
                                    R.images.profileImage,
                                    width: 75,
                                    height: 75,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                if (index % 2 == 0)
                                  Positioned(
                                    bottom: 2,
                                    right: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.all(2),
                                        child: CircleAvatar(
                                          backgroundColor: Colors.green,
                                          radius: 6,
                                        ),
                                      ),
                                    ),
                                  )
                              ],
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Expanded(
                                        child: Text(
                                          'Ehab Sayed',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text('8:30'),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Why Did You Do That ?',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xff1293a8)),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: const Color(0xff53c662)),
                                        child: const Center(
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: 8,
                                                right: 8,
                                                top: 3.5,
                                                bottom: 3.5),
                                            child: Text(
                                              '6',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
