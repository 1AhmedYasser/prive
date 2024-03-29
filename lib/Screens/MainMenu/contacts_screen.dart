import 'dart:convert';

import 'package:app_settings/app_settings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lottie/lottie.dart';
import 'package:prive/Helpers/utils.dart';
import 'package:prive/Resources/animations.dart';
import 'package:prive/Resources/shared_pref.dart';
import 'package:prive/Screens/Chat/Chat/chat_screen.dart';
import 'package:prive/UltraNetwork/ultra_loading_indicator.dart';
import 'package:prive/Widgets/AppWidgets/channels_empty_widgets.dart';
import 'package:prive/Widgets/AppWidgets/prive_appbar.dart';
import 'package:prive/Widgets/Common/cached_image.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ContactsScreen extends StatefulWidget {
  final String title;
  const ContactsScreen({Key? key, this.title = 'New Message'}) : super(key: key);

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> with TickerProviderStateMixin {
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
        child: PriveAppBar(title: widget.title.tr()),
      ),
      body: phoneContacts.isNotEmpty
          ? users.isNotEmpty
              ? Stack(
                  children: [
                    RefreshIndicator(
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
                                      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 0),
                                      child: Column(
                                        children: [
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(50),
                                                child: SizedBox(
                                                  height: 50,
                                                  width: 50,
                                                  child: CachedImage(
                                                    url: users[index].image ?? '',
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 13),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                                        ? 'Online'.tr()
                                                        : "${"Last Seen".tr()} ${DateFormat('d MMM').format(users[index].lastActive ?? DateTime.now())} ${"at".tr()} ${DateFormat('hh:mm a').format(
                                                            users[index].lastActive ?? DateTime.now(),
                                                          )}",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w400,
                                                      color: users[index].online ? Colors.green : Colors.grey,
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
                    ),
                    Positioned(
                      bottom: 40,
                      right: 50,
                      left: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          loadContacts();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          elevation: 0,
                          minimumSize: Size(
                            MediaQuery.of(context).size.width - 50,
                            50,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Refresh Contacts',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ).tr(),
                      ),
                    )
                  ],
                )
              : ChannelsEmptyState(
                  animationController: _animationController,
                  title: 'No Contacts Found'.tr(),
                  message: '',
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
                          Animations.contactsPermission,
                          repeat: false,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "${"Contacts Permission is needed".tr()}\n${"To view your contacts".tr()}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => AppSettings.openAppSettings(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          elevation: 0,
                          minimumSize: Size(
                            MediaQuery.of(context).size.width / 2.5,
                            50,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Go To Settings',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                        ).tr(),
                      )
                    ],
                  ),
                ),
    );
  }

  Future<void> createChannel(BuildContext context, User user) async {
    final core = StreamChatCore.of(context);
    final channel = core.client.channel(
      'messaging',
      id: Utils.generateRandomString(60),
      extraData: {
        'members': [
          core.currentUser!.id,
          user.id,
        ],
        'channel_type': 'Normal',
        'is_important': false,
        'is_archive': false
      },
    );
    await channel.watch();

    if (mounted) {
      Navigator.of(context).push(
        ChatScreen.routeWithChannel(channel),
      );
    }
  }

  void loadContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
    } else {
      if (!mounted) return;
      List contacts = await Utils.fetchContacts(context);
      List<User> users = contacts.first;
      String usersMap = jsonEncode(users);
      Utils.saveString(SharedPref.myContacts, usersMap);
      _getContacts();
    }
  }

  _getContacts() async {
    String? myContacts = await Utils.getString(SharedPref.myContacts);
    if (myContacts != null && myContacts.isNotEmpty == true && myContacts != '[]') {
      List<dynamic> usersMapList = jsonDecode(await Utils.getString(SharedPref.myContacts) ?? '');
      List<User> myUsers = [];
      for (var user in usersMapList) {
        myUsers.add(
          User(
            id: user['id'],
            name: user['name'],
            image: user['image'],
            extraData: {'phone': user['phone'], 'shadow_banned': false},
          ),
        );
      }
      users = myUsers;
      phoneContacts = users.isNotEmpty ? [Contact()] : [Contact()];
      setState(() {});
    } else {
      if (!await FlutterContacts.requestPermission(readonly: true)) {
        setState(() => _permissionDenied = true);
      } else {
        if (!mounted) return;
        List contacts = await Utils.fetchContacts(context);
        users = contacts.first;
        phoneContacts = contacts[1];
        setState(() {});
      }
    }
  }
}
