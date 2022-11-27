import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Screens/Chat/Channels/archive_tab.dart';
import 'package:prive/Screens/Chat/Channels/channels_tab.dart';
import 'package:prive/Screens/Chat/Channels/groups_tab.dart';
import 'package:prive/Screens/Chat/Channels/prive_channels_tab.dart';
import 'package:prive/Widgets/Common/cached_image.dart';

import '../../Resources/images.dart';
import '../../Resources/routes.dart';

class ChannelsScreen extends StatefulWidget {
  const ChannelsScreen({Key? key}) : super(key: key);

  @override
  State<ChannelsScreen> createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> {
  final List<String> _tabs = ["Chats", "Groups", "Channels", "Archive"];

  @override
  void initState() {
    // _createChannel();
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

  // void _createChannel() async {
  //   StreamChatCore.of(context)
  //       .client
  //       .createChannel('messaging', channelId: "ads_marketing", channelData: {
  //     'channel_type': "Public_Channels",
  //     'is_important': false,
  //     'name': "الاعلانات و التسويق",
  //     'image':
  //         "https://lh3.googleusercontent.com/j5U-aQIRSmqbClGbVHyOhkOgCOxf78zmA9ipAAhzJ2qeMSKfrwqWW3OEGLO8PhvPu_iEL3F_8BXPEBganXe6UNdY2ctzeuLSCC1z4WYqy_mPSn8H96zwVkeFaIp-Yi2TnVjTyDMf1D0MRACezAz2slu2tvRU2ZICQ0KyccecOyqvbdVa8FtyvM-CKz-8MSCeGgSKk04o4-MqLdy9YXvyIkej7yJwt_1yaiCz7GLyeuY0T8dZKvENg65iq0BE7HDN3Ykh11bH5saC3kX2uJp1ZS_bcgukjXAvSvNdnHIhoZ7sEiTR3BPKfxlLlFj3lkT_G5fINtFfT5MpmJlaUE_UwFcU4sKC4VUzETnFHreWQPUJr4yL7_ManMpK5Nl2CHkEVcRHe1kimfEPcMgadKBQxjaCQevxaYfosnjZ2xOZam3orQFa-JU7ZigbLJI0kw6Y2jCfhS7m-GiaZSqmnT2a6bxoprOgzrNzx0FOnVCjqhXYyCspOMHmSDoAkoARWdDLBHr_DhEHRcyndEPyDWwrsc1TRfsYPCdJIv2mlZa2Ph0k7n3v5Una91aKks_CgHL7o7kx7anwNKF_7FULAvUooNeFqceyi9w46q1eab-itsuW7dAInpnYww37FCTIS5G-MIf_r0HCVVNbUClcaDs0776hjtvVScVbtnjJaBHIIu7axWf4Vy9Q38VW4bX79Tyd4M1NMseeHyTjDOw5YkwZfAa_QmU6RDgVUFbD1RgMgeR69GiieCRdsBiaFaIYujaNLH1Xv1WOphpwekEf0l-MUXunwNist9Qxy76yjtEoj9qJLttcAjo4gIAn29iHaxbYTARat8cfPGuY0caRaozsr1uzV970gqWkuXU1=w400-h430-no?authuser=0",
  //     'is_archive': false,
  //   });
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
                alignment: context.locale.languageCode == "en" ? Alignment.centerLeft : Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, left: 25, right: 25),
                  child: Image.asset(
                    Images.logoImage,
                    height: 40,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              bottom: _tabs.isEmpty
                  ? null
                  : PreferredSize(
                      preferredSize: Size(MediaQuery.of(context).size.width, 50),
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
                                  labelColor: Theme.of(context).primaryColorDark,
                                  isScrollable: true,
                                  labelStyle: const TextStyle(color: Color(0xff1293a8)),
                                  labelPadding: const EdgeInsets.only(left: 5, right: 5),
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
                                        height: 38,
                                        child: Tab(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(50),
                                              border: Border.all(
                                                color: Colors.transparent,
                                                width: 0.3,
                                              ),
                                            ),
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 20, right: 20),
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
                    Padding(
                      padding: EdgeInsets.only(
                          right: context.locale.languageCode == "en" ? 23 : 0,
                          left: context.locale.languageCode == "en" ? 0 : 23),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, Routes.profileRoute).then((value) {
                            setState(() {});
                          });
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
                    ),
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
