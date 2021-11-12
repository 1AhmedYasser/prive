import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:prive/Extras/resources.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({Key? key}) : super(key: key);

  @override
  _MoreScreenState createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
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
      body: SingleChildScrollView(
        child: AnimationLimiter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(
                  child: widget,
                ),
              ),
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 27, right: 27, bottom: 30),
                  child: Text(
                    "More",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildMoreOption(() {},
                    image: R.images.myGroupsImage, title: "My Groups"),
                _buildMoreOption(() {},
                    image: R.images.myChannelsImage, title: "My Channels"),
                _buildMoreOption(() {},
                    image: R.images.catalogManagerImage,
                    title: "Catalog Manager"),
                _buildMoreOption(() {},
                    image: R.images.contactsImage, title: "Contacts"),
                _buildMoreOption(() {},
                    image: R.images.peopleNearbyImage, title: "People Nearby"),
                _buildMoreOption(() {},
                    image: R.images.inviteFriendsImage,
                    title: "Invite Friends"),
                _buildMoreOption(
                  () {
                    Navigator.pushNamed(context, R.routes.settingsRoute);
                  },
                  image: R.images.settingsImage,
                  title: "Settings",
                  showDivider: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreOption(Function onPressed,
      {String image = "", String title = "", bool showDivider = true}) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () => onPressed(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 22, right: 27, bottom: 15),
            child: Row(
              children: [
                Image.asset(
                  image,
                  width: 30,
                  height: 23,
                ),
                const SizedBox(width: 18),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Expanded(child: SizedBox()),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 17,
                  color: Color(0xffc2c4ca),
                )
              ],
            ),
          ),
          if (showDivider)
            const Padding(
              padding: EdgeInsets.only(left: 22),
              child: Divider(),
            ),
          const SizedBox(height: 18)
        ],
      ),
    );
  }
}
