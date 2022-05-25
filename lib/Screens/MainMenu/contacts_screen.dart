import 'dart:convert';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lottie/lottie.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Helpers/utils.dart';
import 'package:prive/Screens/Chat/Chat/chat_screen.dart';
import 'package:prive/UltraNetwork/ultra_loading_indicator.dart';
import 'package:prive/Widgets/AppWidgets/prive_appbar.dart';
import 'package:prive/Widgets/Common/cached_image.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:intl/intl.dart';

import '../../Widgets/AppWidgets/channels_empty_widgets.dart';

class ContactsScreen extends StatefulWidget {
  final String title;
  const ContactsScreen({Key? key, this.title = "New Message"})
      : super(key: key);

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen>
    with TickerProviderStateMixin {
  bool _permissionDenied = false;
  List<Contact> phoneContacts = [];
  List<User> users = [];
  late final AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this);
    Utils.checkForInternetConnection(context);
    _getContacts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 60),
        child: PriveAppBar(title: widget.title),
      ),
      body: phoneContacts.isNotEmpty
          ? users.isNotEmpty
              ? RefreshIndicator(
                  onRefresh: () => Future.sync(() => _getContacts()),
                  child: AnimationLimiter(
                    child: ListView.separated(
                      itemBuilder: (context, index) {
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          child: SlideAnimation(
                            horizontalOffset: 50.0,
                            child: FadeInAnimation(
                              child: InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  createChannel(context, users[index]);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10, bottom: 0),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            child: SizedBox(
                                              height: 50,
                                              width: 50,
                                              child: CachedImage(
                                                url: users[index].image ?? "",
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 13),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                users[index].name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                users[index].online
                                                    ? "Online"
                                                    : "Last Seen ${DateFormat('d MMM').format(users[index].lastActive ?? DateTime.now())} at ${DateFormat('hh:mm a').format(
                                                        users[index]
                                                                .lastActive ??
                                                            DateTime.now(),
                                                      )}",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  color: users[index].online
                                                      ? Colors.green
                                                      : Colors.grey,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Divider(
                          height: 0,
                          color: Colors.grey.shade300,
                        );
                      },
                      itemCount: users.length,
                    ),
                  ),
                )
              : ChannelsEmptyState(
                  animationController: _animationController,
                  title: "No Contacts Found",
                  message: "",
                )
          : _permissionDenied == false
              ? const UltraLoadingIndicator()
              : SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 100),
                      SizedBox(
                        height: 200,
                        child: Lottie.asset(
                          R.animations.contactsPermission,
                          repeat: false,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Contacts Permission is needed\nTo view your contacts",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => AppSettings.openAppSettings(),
                        child: const Text(
                          "Go To Settings",
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w500),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).primaryColor,
                          elevation: 0,
                          minimumSize: Size(
                            MediaQuery.of(context).size.width / 2.5,
                            50,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
    );
  }

  Future<void> createChannel(BuildContext context, User user) async {
    final core = StreamChatCore.of(context);
    final channel = core.client.channel('messaging', extraData: {
      'members': [
        core.currentUser!.id,
        user.id,
      ],
      'channel_type': "Normal",
      'is_important': false,
      'is_archive': false
    });
    await channel.watch();

    Navigator.of(context).push(
      ChatScreen.routeWithChannel(channel),
    );
  }

  _getContacts() async {
    String? myContacts = await Utils.getString(R.pref.myContacts);
    if (myContacts != null && myContacts.isNotEmpty == true) {
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
      phoneContacts = users.isNotEmpty ? [Contact()] : [Contact()];
      setState(() {});
    } else {
      if (!await FlutterContacts.requestPermission(readonly: true)) {
        setState(() => _permissionDenied = true);
      } else {
        List contacts = await Utils.fetchContacts(context);
        users = contacts.first;
        phoneContacts = contacts[1];
        setState(() {});
      }
    }
  }
}
