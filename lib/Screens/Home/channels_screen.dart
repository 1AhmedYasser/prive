import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Screens/Chat/Channels/archive_tab.dart';
import 'package:prive/Screens/Chat/Channels/channels_tab.dart';
import 'package:prive/Screens/Chat/Channels/groups_tab.dart';
import 'package:prive/Screens/Chat/Channels/important_tab.dart';
import 'package:prive/Widgets/Common/cached_image.dart';

class ChannelsScreen extends StatefulWidget {
  const ChannelsScreen({Key? key}) : super(key: key);

  @override
  _ChannelsScreenState createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> {
  final List<String> _tabs = ["Chats", "Groups", "Important", "Archive"];

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
              backgroundColor: Colors.grey.shade200.withOpacity(0.3),
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
                                  unselectedLabelColor: Colors.grey.shade400,
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
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, R.routes.profileRoute);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: CachedImage(
                            url: context.currentUserImage ?? "",
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            ChannelsTab(),
            GroupsTab(),
            ImportantTab(),
            ArchiveTab(),
          ],
        ),
      ),
    );
  }
}
