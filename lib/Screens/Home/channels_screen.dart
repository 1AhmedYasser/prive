import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Screens/Chat/Channels/archive_tab.dart';
import 'package:prive/Screens/Chat/Channels/channels_tab.dart';
import 'package:prive/Screens/Chat/Channels/groups_tab.dart';
import 'package:prive/Screens/Chat/Channels/prive_channels_tab.dart';
import 'package:prive/Widgets/Common/cached_image.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../Chat/Calls/call_screen.dart';

class ChannelsScreen extends StatefulWidget {
  const ChannelsScreen({Key? key}) : super(key: key);

  @override
  _ChannelsScreenState createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> {
  final List<String> _tabs = ["Chats", "Groups", "Channels", "Archive"];

  @override
  void initState() {
    //_createChannel();
    super.initState();
  }

  // void _createChannel() async {
  //   StreamChatCore.of(context).client.createChannel('messaging',
  //       channelId: "Customer_support",
  //       channelData: {
  //         'channel_type': "Public_Channels",
  //         'is_important': false,
  //         'name': "الدعم الفني",
  //         'image':
  //             "https://lh3.googleusercontent.com/3dc4AL2oqLjFSNrqtRG8X4iSRAGOvJnY41d0Y3BBjA7vYOLkVk8jgyu_jxZSP9b9EufUcnOicyX4H291pFjqb95SDeTzMZLbhYAfKnuezzb60IJ1L3CsYPhB_obtuMC8v46wvPYSbA6zbKUQYJlv-riXyHe8mIMMzypOD2pa0Xl7TjGRGsb8ehCralBxRw5A2DpXlIsPoOStpPH9DnPy2fJZ5wtgc2PMnigMb9XbAmjso7RM7z4yP3s-kFKGQu9q0UDbmAcdCLH6y4g1xFxAmjh-khlFZ4-ZZNNnf-tfLHnCdgt0FMt8GgA-TpKIvRPcS1LNmMXFuydNOHoH7xW-HJOr-UE5snyd4yxuEm7aemr1QoxlV1Q3WgmkUQqT01o7U1T8eZ2LXNohyhFDaMaosdORqxNRdnlHBoDCwX_EmwZ6z1t5pmMMlKE4W2oR2ijnRbyqwqzdxqKUa53ChSvYPutcGlMZHg4K7m_Ag4MJ4lvK8Yy-I9G-z6uX9glrK_c3mPNObOeUjqVC0prfc-wXCoqleaiQ9nnXfb81GRLpZWQ2jpdk_sPFlyM-V-n1E5zmRPC4rKBi__4_-GCmvn_bZJz4LpO_Q0n_gdbJQPv16IrQS8_YShvL0kQVrZXNVbSztqQ8NAc__6WsGGUWUTlFFcjZ9203-j0b9MU3-ebSpWXQFA7Xg857hm7yC-45oCjvG5mR_YLhPIj-QrBJ1DPRJ95_yf57vzBnlcdxPcXB5Dtpt2yOD7qP-QV6UVqN3ahxaVinQDxy0KwRzkp4CcG55UfjfyvHnfpNKA5AK_FdmRlyjQfPTyXrQ8A8ufnkDQ4nc_1__TvxlChDjriZ8nkQyXkxFgRE6zwepw2a=w400-h430-no?authuser=0",
  //         'is_archive': false,
  //       });
  // }

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
            PriveChannelsTab(),
            ArchiveTab(),
          ],
        ),
      ),
    );
  }
}
