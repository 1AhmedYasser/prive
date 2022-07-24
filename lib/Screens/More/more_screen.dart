import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Helpers/utils.dart';
import 'package:prive/Screens/MainMenu/contacts_screen.dart';
import 'package:prive/Widgets/AppWidgets/option_row_widget.dart';
import 'package:easy_localization/easy_localization.dart';

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
          automaticallyImplyLeading: false,
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
                Padding(
                  padding:
                      const EdgeInsets.only(left: 15, right: 27, bottom: 30),
                  child: Row(
                    children: [
                      const BackButton(),
                      const SizedBox(width: 8),
                      Text(
                        "Settings".tr(),
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                OptionRowWidget(
                  image: R.images.myGroupsImage,
                  title: "My Groups".tr(),
                  onPressed: () {},
                ),
                OptionRowWidget(
                  image: R.images.myChannelsImage,
                  title: "My Channels".tr(),
                  onPressed: () {},
                ),
                OptionRowWidget(
                  image: R.images.catalogManagerImage,
                  title: "Catalog Manager".tr(),
                  onPressed: () =>
                      Navigator.pushNamed(context, R.routes.catalogScreen)
                          .then((value) => setState(() {})),
                ),
                OptionRowWidget(
                  image: R.images.contactsImage,
                  title: "Contacts".tr(),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContactsScreen(
                          title: "Contacts".tr(),
                        ),
                      ),
                    ).then((value) => setState(() {}));
                  },
                ),
                OptionRowWidget(
                  image: R.images.peopleNearbyImage,
                  title: "People Nearby".tr(),
                  onPressed: () {},
                ),
                OptionRowWidget(
                  image: R.images.inviteFriendsImage,
                  title: "Invite Friends".tr(),
                  onPressed: () {},
                ),
                OptionRowWidget(
                  image: R.images.settingsImage,
                  title: "Settings".tr(),
                  onPressed: () {
                    Navigator.pushNamed(context, R.routes.settingsRoute)
                        .then((value) => setState(() {}));
                  },
                ),
                OptionRowWidget(
                  image: R.images.logoutImage,
                  imageColor: const Color(0xff7a8fa6).withOpacity(0.9),
                  title: "Log out".tr(),
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
