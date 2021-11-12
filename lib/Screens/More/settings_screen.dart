import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:prive/Extras/resources.dart';

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
            fontSize: 25,
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
                _buildMoreOption(() {},
                    image: R.images.notificationBellImage,
                    title: "Notifications & Sounds"),
                _buildMoreOption(() {},
                    image: R.images.chatImage, title: "Chat Settings"),
                _buildMoreOption(() {},
                    image: R.images.blockedUserImage, title: "Blocked Users"),
                _buildMoreOption(
                  () {
                    Navigator.pushNamed(context, R.routes.settingsRoute);
                  },
                  image: R.images.languageImage,
                  title: "Language",
                ),
                const SizedBox(height: 5),
                buildSettingsChoices("Help", () {},
                    bottom: 30, textColor: const Color(0xff232323)),
                buildSettingsChoices("Ask a Question", () {}),
                buildSettingsChoices("Terms & Conditions", () {}),
                buildSettingsChoices("Privacy Policy", () {}),
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
