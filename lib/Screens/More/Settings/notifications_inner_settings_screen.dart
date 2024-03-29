import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:prive/Widgets/AppWidgets/prive_appbar.dart';

class NotificationsInnerSettingsScreen extends StatefulWidget {
  final String title;

  const NotificationsInnerSettingsScreen({Key? key, this.title = ''}) : super(key: key);

  @override
  State<NotificationsInnerSettingsScreen> createState() => _NotificationsInnerSettingsScreenState();
}

class _NotificationsInnerSettingsScreenState extends State<NotificationsInnerSettingsScreen> {
  List<bool> currentValues = [false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 60),
        child: PriveAppBar(title: widget.title),
      ),
      body: SingleChildScrollView(
        child: AnimationLimiter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 300),
              childAnimationBuilder: (widget) => SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(
                  child: widget,
                ),
              ),
              children: [
                const SizedBox(height: 30),
                buildSetting(
                  "${"Notifications For".tr()} ${widget.title}",
                  currentValues[0] == true ? 'On' : 'Off',
                  0,
                  isSwitch: true,
                ),
                const SizedBox(height: 5),
                buildDivider(),
                Padding(
                  padding: const EdgeInsets.only(top: 15, left: 25, bottom: 17, right: 20),
                  child: Text(
                    'Settings',
                    style: TextStyle(
                      color: Theme.of(context).primaryColorDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ).tr(),
                ),
                buildSetting('Message Preview', '', 1, isSwitch: true),
                const SizedBox(height: 5),
                buildDivider(),
                const SizedBox(height: 15),
                buildSetting('Vibrate', 'Default', 2),
                const SizedBox(height: 15),
                buildDivider(),
                const SizedBox(height: 15),
                buildSetting('Popup Notifications', 'No Popup', 3),
                const SizedBox(height: 15),
                buildDivider(),
                const SizedBox(height: 15),
                buildSetting('Sound', 'Default', 4),
                const SizedBox(height: 15),
                buildDivider(),
                const SizedBox(height: 15),
                buildSetting('Importance', 'Urgent', 5),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSetting(String title, String subTitle, int index, {bool isSwitch = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25),
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationsInnerSettingsScreen(
                title: title.tr(),
              ),
            ),
          );
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
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ).tr(),
                const SizedBox(height: 3),
                if (subTitle.isNotEmpty && isSwitch)
                  Text(
                    subTitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff7a8fa6),
                    ),
                  ).tr(),
              ],
            ),
            if (isSwitch)
              Switch(
                value: currentValues[index],
                activeColor: Theme.of(context).primaryColor,
                onChanged: (value) {
                  setState(() {
                    currentValues[index] = value;
                  });
                },
              ),
            if (isSwitch == false)
              Text(
                subTitle,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColorDark,
                ),
              ).tr(),
          ],
        ),
      ),
    );
  }

  Widget buildDivider() {
    return Padding(
      padding: EdgeInsets.only(
        left: context.locale.languageCode == 'en' ? 25 : 0,
        right: context.locale.languageCode == 'en' ? 0 : 25,
      ),
      child: const Divider(),
    );
  }
}
