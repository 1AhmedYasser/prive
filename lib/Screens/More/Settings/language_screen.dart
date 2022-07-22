import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:prive/Widgets/AppWidgets/prive_appbar.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({Key? key}) : super(key: key);

  @override
  _LanguageScreenState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  int currentSelectedIndex = 1;

  @override
  void didChangeDependencies() {
    setState(() {
      currentSelectedIndex = context.locale == const Locale("en") ? 1 : 2;
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 60),
        child: const PriveAppBar(title: "Language"),
      ),
      body: SingleChildScrollView(
        child: AnimationLimiter(
          child: Column(
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 300),
              childAnimationBuilder: (widget) => SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(
                  child: widget,
                ),
              ),
              children: [
                const SizedBox(height: 20),
                buildLanguage("English", "English", 1, "en"),
                const SizedBox(height: 5),
                const Divider(),
                const SizedBox(height: 5),
                buildLanguage("العربية", "Arabic", 2, "ar"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLanguage(
      String title, String subTitle, int index, String language) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25),
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          context.setLocale(Locale(language));
          setState(() {
            currentSelectedIndex = index;
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff7a8fa6),
                  ),
                ),
              ],
            ),
            Container(
              height: 26,
              width: 26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: currentSelectedIndex == index
                      ? Theme.of(context).primaryColor
                      : const Color(0xff7a8fa6),
                ),
              ),
              child: currentSelectedIndex == index
                  ? Icon(
                      FontAwesomeIcons.solidCheckCircle,
                      color: Theme.of(context).primaryColor,
                    )
                  : null,
            )
          ],
        ),
      ),
    );
  }
}
