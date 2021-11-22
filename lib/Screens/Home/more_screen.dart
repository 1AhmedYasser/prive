import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Helpers/utils.dart';
import 'package:prive/Widgets/AppWidgets/option_row_widget.dart';

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
                OptionRowWidget(
                  image: R.images.myGroupsImage,
                  title: "My Groups",
                  onPressed: () {},
                ),
                OptionRowWidget(
                  image: R.images.myChannelsImage,
                  title: "My Channels",
                  onPressed: () {},
                ),
                OptionRowWidget(
                  image: R.images.catalogManagerImage,
                  title: "Catalog Manager",
                  onPressed: () {},
                ),
                OptionRowWidget(
                  image: R.images.contactsImage,
                  title: "Contacts",
                  onPressed: () {},
                ),
                OptionRowWidget(
                  image: R.images.peopleNearbyImage,
                  title: "People Nearby",
                  onPressed: () {},
                ),
                OptionRowWidget(
                  image: R.images.inviteFriendsImage,
                  title: "Invite Friends",
                  onPressed: () {},
                ),
                OptionRowWidget(
                  image: R.images.settingsImage,
                  title: "Settings",
                  onPressed: () {
                    Navigator.pushNamed(context, R.routes.settingsRoute);
                  },
                ),
                OptionRowWidget(
                  image: R.images.logoutImage,
                  imageColor: const Color(0xff7a8fa6).withOpacity(0.9),
                  title: "Logout",
                  showDivider: false,
                  onPressed: () {
                    Utils.saveString(R.pref.token, "");
                    Utils.saveString(R.pref.userId, "");
                    Utils.saveString(R.pref.userName, "");
                    Utils.saveString(R.pref.userFirstName, "");
                    Utils.saveString(R.pref.userLastName, "");
                    Utils.saveString(R.pref.userEmail, "");
                    Utils.saveString(R.pref.userPhone, "");
                    Utils.saveBool(R.pref.isLoggedIn, false);
                    StreamManager.disconnectUserFromStream(context);
                    Navigator.pushNamedAndRemoveUntil(context,
                        R.routes.loginRoute, (Route<dynamic> route) => false);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
