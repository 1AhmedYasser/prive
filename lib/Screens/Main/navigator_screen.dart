import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:prive/Helpers/notifications_manager.dart';
import 'package:prive/Helpers/utils.dart';
import 'package:prive/Providers/channels_provider.dart';
import 'package:prive/Resources/images.dart';
import 'package:prive/Resources/shared_pref.dart';
import 'package:prive/Screens/Home/calls_screen.dart';
import 'package:prive/Screens/Home/channels_screen.dart';
import 'package:prive/Screens/Home/rooms_screen.dart';
import 'package:prive/Screens/Home/stories_screen.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class NavigatorScreen extends StatefulWidget {
  const NavigatorScreen({Key? key}) : super(key: key);

  @override
  State<NavigatorScreen> createState() => _NavigatorScreenState();
}

class _NavigatorScreenState extends State<NavigatorScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    NotificationsManager.setupNotifications(context);
    loadContacts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: WillPopScope(
        onWillPop: () async {
          Utils.showAlert(
            context,
            withCancel: true,
            message: 'Do You Want To Exit Prive ?'.tr(),
            okButtonText: 'Yes'.tr(),
            cancelButtonText: 'No'.tr(),
            onOkButtonPressed: () {
              try {
                SystemNavigator.pop();
              } catch (e) {
                exit(0);
              }
            },
          );
          return false;
        },
        child: ConvexAppBar(
          chipBuilder: _ChipBuilder(),
          color: const Color(0xff7a8fa6),
          backgroundColor: Colors.grey.shade100.withOpacity(0.5),
          activeColor: Theme.of(context).primaryColor,
          elevation: 0.5,
          style: TabStyle.fixed,
          height: 60,
          top: -25,
          items: [
            _buildTab('Chat'.tr(), Images.chatTabImage, 0),
            _buildTab('Calls'.tr(), Images.phoneTabImage, 1),
            TabItem(
              icon: Container(),
            ),
            _buildTab('Rooms'.tr(), Images.micTabImage, 3),
            _buildTab('Stories'.tr(), Images.storiesTabImage, 4),
          ],
          initialActiveIndex: 2,
          onTap: (int i) => _onTabTapped(i),
        ),
      ),
      body: _buildBody(),
    );
  }

  TabItem _buildTab(String title, String image, int index) {
    return TabItem(
      icon: SizedBox(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: ImageIcon(
            AssetImage(image),
            color: _currentIndex == index ? Theme.of(context).primaryColorDark : const Color(0xff7a8fa6),
          ),
        ),
      ),
      title: title,
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const ChannelsScreen();
      case 1:
        return const CallsScreen();
      case 3:
        return const RoomsScreen();
      case 4:
        return const StoriesScreen();
      default:
        return const ChannelsScreen();
    }
  }

  void _onTabTapped(int index) {
    if (index != 2) {
      setState(() {
        _currentIndex = index;
      });
    } else if (index == 2) {
      Utils.showMainMenu(context);
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
      if (mounted) {
        Provider.of<ChannelsProvider>(context, listen: false).refreshChannels();
      }
    }
  }
}

class _ChipBuilder extends ChipBuilder {
  @override
  Widget build(BuildContext context, Widget child, int index, bool active) {
    return index == 2
        ? Stack(
            alignment: Alignment.center,
            children: [
              child,
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade400.withOpacity(0.5),
                            spreadRadius: 0.3,
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(Images.addTabImage),
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
        : SizedBox(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 5, top: 10),
                  child: ImageIcon(
                    AssetImage(getImage(index)),
                    color: active ? Theme.of(context).primaryColorDark : const Color(0xff7a8fa6),
                  ),
                ),
                Expanded(
                  child: AutoSizeText(
                    getTitles(index),
                    maxLines: 1,
                    style: TextStyle(
                      color: active ? Theme.of(context).primaryColorDark : const Color(0xff7a8fa6),
                    ),
                  ),
                )
              ],
            ),
          );
  }

  String getImage(int index) {
    switch (index) {
      case 0:
        return Images.chatTabImage;
      case 1:
        return Images.phoneTabImage;
      case 2:
        return Images.addTabImage;
      case 3:
        return Images.micTabImage;
      case 4:
        return Images.storiesTabImage;
      default:
        return Images.chatTabImage;
    }
  }

  String getTitles(int index) {
    switch (index) {
      case 0:
        return 'Chat'.tr();
      case 1:
        return 'Calls'.tr();
      case 2:
        return '';
      case 3:
        return 'Rooms'.tr();
      case 4:
        return 'Stories'.tr();
      default:
        return 'Chat'.tr();
    }
  }
}
