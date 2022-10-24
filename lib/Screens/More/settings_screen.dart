import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Screens/More/Settings/terms_privacy_screen.dart';
import 'package:prive/Widgets/AppWidgets/option_row_widget.dart';
import 'package:prive/Widgets/AppWidgets/prive_appbar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 60),
        child: PriveAppBar(title: "Settings".tr()),
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
                  title: "Notifications & Sounds".tr(),
                  onPressed: () => Navigator.pushNamed(
                          context, R.routes.notificationsSoundsRoute)
                      .then((value) => setState(() {})),
                ),
                OptionRowWidget(
                  image: R.images.chatImage,
                  title: "Chat Settings".tr(),
                  onPressed: () =>
                      Navigator.pushNamed(context, R.routes.chatSettingsRoute)
                          .then((value) => setState(() {})),
                ),
                OptionRowWidget(
                  image: R.images.blockedUserImage,
                  title: "Blocked Users".tr(),
                  onPressed: () {},
                ),
                OptionRowWidget(
                  image: R.images.languageImage,
                  title: "Language".tr(),
                  onPressed: () =>
                      Navigator.pushNamed(context, R.routes.languageRoute)
                          .then((value) => setState(() {})),
                ),
                const SizedBox(height: 5),
                buildSettingsChoices("Help", () {},
                    bottom: 30, textColor: const Color(0xff232323)),
                buildSettingsChoices("Ask a Question".tr(), () {
                  _showAskQuestionDialog();
                }),
                buildSettingsChoices(
                  "Terms & Conditions".tr(),
                  () => Navigator.pushNamed(context, R.routes.termsPrivacyRoute)
                      .then((value) => setState(() {})),
                ),
                buildSettingsChoices(
                  "Privacy Policy".tr(),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TermsPrivacyScreen(
                          isTerms: false,
                        ),
                      ),
                    ).then((value) => setState(() {}));
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

  Future<void> _showAskQuestionDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              side: BorderSide(color: Colors.white, width: 1.0)),
          title: Center(
            child: Text(
              "Ask a Question".tr(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Please note that our APP support is done by volunteers. We try to respond as quickly as possible,but it may take a while.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ).tr(),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5, bottom: 5),
                          child: Text(
                            "Cancel",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 16),
                          ).tr(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                                color: Theme.of(context).primaryColorDark),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5, bottom: 5),
                          child: Text(
                            "Ask a Volunteer",
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                                fontSize: 15),
                          ).tr(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
