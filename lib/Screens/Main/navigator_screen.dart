import 'package:auto_size_text/auto_size_text.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Helpers/utils.dart';

class NavigatorScreen extends StatefulWidget {
  const NavigatorScreen({Key? key}) : super(key: key);

  @override
  State<NavigatorScreen> createState() => _NavigatorScreenState();
}

class _NavigatorScreenState extends State<NavigatorScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: ConvexAppBar(
        chipBuilder: _ChipBuilder(),
        color: const Color(0xff7a8fa6),
        backgroundColor: Colors.white,
        activeColor: Theme.of(context).primaryColor,
        elevation: 0.5,
        style: TabStyle.fixed,
        height: 60,
        top: -25,
        items: [
          _buildTab("Chats", R.images.chatTabImage, 0),
          _buildTab("Calls", R.images.phoneTabImage, 1),
          TabItem(
            icon: Container(),
          ),
          _buildTab("Chat Rooms", R.images.micTabImage, 3),
          _buildTab("More", R.images.moreTabImage, 4),
        ],
        initialActiveIndex: 2,
        onTap: (int i) => _onTabTapped(i),
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
            color: _currentIndex == index
                ? Theme.of(context).primaryColor
                : const Color(0xff7a8fa6),
          ),
        ),
      ),
      title: title,
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Chats",
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  Utils.saveString(R.pref.token, "");
                  Utils.saveString(R.pref.userId, "");
                  Utils.saveBool(R.pref.isLoggedIn, false);
                  Navigator.pushReplacementNamed(
                    context,
                    R.routes.loginRoute,
                  );
                },
                child: const Text(
                  "Log Out",
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w400),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                  elevation: 0,
                  minimumSize: Size(
                    MediaQuery.of(context).size.width - 50,
                    50,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        );
      case 1:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Calls",
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  Utils.saveString(R.pref.token, "");
                  Utils.saveString(R.pref.userId, "");
                  Utils.saveBool(R.pref.isLoggedIn, false);
                  Navigator.pushReplacementNamed(
                    context,
                    R.routes.loginRoute,
                  );
                },
                child: const Text(
                  "Log Out",
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w400),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                  elevation: 0,
                  minimumSize: Size(
                    MediaQuery.of(context).size.width - 50,
                    50,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        );
      case 2:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Add",
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  Utils.saveString(R.pref.token, "");
                  Utils.saveString(R.pref.userId, "");
                  Utils.saveBool(R.pref.isLoggedIn, false);
                  Navigator.pushReplacementNamed(
                    context,
                    R.routes.loginRoute,
                  );
                },
                child: const Text(
                  "Log Out",
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w400),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                  elevation: 0,
                  minimumSize: Size(
                    MediaQuery.of(context).size.width - 50,
                    50,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        );
      case 3:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Chat Rooms",
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  Utils.saveString(R.pref.token, "");
                  Utils.saveString(R.pref.userId, "");
                  Utils.saveBool(R.pref.isLoggedIn, false);
                  Navigator.pushReplacementNamed(
                    context,
                    R.routes.loginRoute,
                  );
                },
                child: const Text(
                  "Log Out",
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w400),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                  elevation: 0,
                  minimumSize: Size(
                    MediaQuery.of(context).size.width - 50,
                    50,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        );
      case 4:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "More",
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  Utils.saveString(R.pref.token, "");
                  Utils.saveString(R.pref.userId, "");
                  Utils.saveBool(R.pref.isLoggedIn, false);
                  Navigator.pushReplacementNamed(
                    context,
                    R.routes.loginRoute,
                  );
                },
                child: const Text(
                  "Log Out",
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w400),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                  elevation: 0,
                  minimumSize: Size(
                    MediaQuery.of(context).size.width - 50,
                    50,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        );
      default:
        return const Center(
          child: Text(
            "Chats",
            style: TextStyle(
              fontSize: 30,
            ),
          ),
        );
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
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
                    padding: const EdgeInsets.all(11),
                    child: Image.asset(R.images.addTabImage),
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
                    color: active
                        ? Theme.of(context).primaryColor
                        : const Color(0xff7a8fa6),
                  ),
                ),
                Expanded(
                  child: AutoSizeText(
                    getTitles(index),
                    maxLines: 1,
                    style: TextStyle(
                      color: active
                          ? Theme.of(context).primaryColor
                          : const Color(0xff7a8fa6),
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
        return R.images.chatTabImage;
      case 1:
        return R.images.phoneTabImage;
      case 2:
        return R.images.addTabImage;
      case 3:
        return R.images.micTabImage;
      case 4:
        return R.images.moreTabImage;
      default:
        return R.images.chatTabImage;
    }
  }

  String getTitles(int index) {
    switch (index) {
      case 0:
        return "Chat";
      case 1:
        return "Calls";
      case 2:
        return "";
      case 3:
        return "Chat Rooms";
      case 4:
        return "More";
      default:
        return "Chat";
    }
  }
}
