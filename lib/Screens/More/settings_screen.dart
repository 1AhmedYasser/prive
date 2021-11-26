import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Screens/More/terms_privacy_screen.dart';
import 'package:prive/Widgets/AppWidgets/option_row_widget.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
        ),
        leading: const BackButton(
          color: Color(0xff7a8fa6),
        ),
        title: const Text(
          "Settings",
          style: TextStyle(
            fontSize: 23,
            color: Colors.black,
            fontWeight: FontWeight.w400,
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
                const SizedBox(height: 30),
                OptionRowWidget(
                  image: R.images.notificationBellImage,
                  title: "Notifications & Sounds",
                  onPressed: () {},
                ),
                OptionRowWidget(
                  image: R.images.chatImage,
                  title: "Chat Settings",
                  onPressed: () => Navigator.pushNamed(context, R.routes.chatSettingsRoute),
                ),
                OptionRowWidget(
                  image: R.images.blockedUserImage,
                  title: "Blocked Users",
                  onPressed: () {},
                ),
                OptionRowWidget(
                  image: R.images.languageImage,
                  title: "Language",
                  onPressed: () => Navigator.pushNamed(context, R.routes.languageRoute),
                ),
                const SizedBox(height: 5),
                buildSettingsChoices("Help", () {},
                    bottom: 30, textColor: const Color(0xff232323)),
                buildSettingsChoices("Ask a Question", () {}),
                buildSettingsChoices(
                  "Terms & Conditions",
                  () =>
                      Navigator.pushNamed(context, R.routes.termsPrivacyRoute),
                ),
                buildSettingsChoices(
                  "Privacy Policy",
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TermsPrivacyScreen(
                          isTerms: false,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSettingsChoices(String text, Function onPressed,
      {double bottom = 17, Color textColor = const Color(0xff7a8fa6)}) {
    return Padding(
      padding: EdgeInsets.only(left: 27, right: 27, bottom: bottom),
      child: GestureDetector(
        onTap: () => onPressed(),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w400,
            color: textColor,
          ),
        ).tr(),
      ),
    );
  }
}
