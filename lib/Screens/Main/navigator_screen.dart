import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:prive/Extras/resources.dart';

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
        color: const Color(0xff7a8fa6),
        backgroundColor: Colors.white,
        activeColor: Theme.of(context).primaryColor,
        elevation: 0.5,
        style: TabStyle.fixedCircle,
        height: 60,
        top: -25,
        items: [
          _buildTab("Chats", R.images.chatTabImage, 0),
          _buildTab("Calls", R.images.phoneTabImage, 1),
          TabItem(
            icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(100)),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
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
      icon: ImageIcon(
        AssetImage(image),
        color: _currentIndex == index
            ? Theme.of(context).primaryColor
            : const Color(0xff7a8fa6),
      ),
      title: title,
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const Center(
          child: Text(
            "Chats",
            style: TextStyle(
              fontSize: 30,
            ),
          ),
        );
      case 1:
        return const Center(
          child: Text(
            "Calls",
            style: TextStyle(
              fontSize: 30,
            ),
          ),
        );
      case 2:
        return const Center(
          child: Text(
            "Add",
            style: TextStyle(
              fontSize: 30,
            ),
          ),
        );
      case 3:
        return const Center(
          child: Text(
            "Chat Rooms",
            style: TextStyle(
              fontSize: 30,
            ),
          ),
        );
      case 4:
        return const Center(
          child: Text(
            "More",
            style: TextStyle(
              fontSize: 30,
            ),
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
