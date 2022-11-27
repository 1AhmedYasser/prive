import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:prive/Screens/More/Settings/notifications_inner_settings_screen.dart';
import 'package:prive/Widgets/AppWidgets/prive_appbar.dart';

class NotificationsSoundsScreen extends StatefulWidget {
  const NotificationsSoundsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsSoundsScreen> createState() => _NotificationsSoundsScreenState();
}

class _NotificationsSoundsScreenState extends State<NotificationsSoundsScreen> {
  List<bool> currentValues = [false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 60),
        child: PriveAppBar(title: 'Notifications & Sounds'.tr()),
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
                Padding(
                  padding: const EdgeInsets.only(
                    top: 25,
                    left: 25,
                    bottom: 17,
                    right: 20,
                  ),
                  child: Text(
                    'Notifications & Sounds'.tr(),
                    style: TextStyle(
                      color: Theme.of(context).primaryColorDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ).tr(),
                ),
                const SizedBox(height: 20),
                buildSetting('Private Chats'.tr(), 'Tab To Change'.tr(), 0),
                const SizedBox(height: 5),
                buildDivider(),
                const SizedBox(height: 5),
                buildSetting('Groups'.tr(), 'Tab To Change'.tr(), 1),
                const SizedBox(height: 5),
                buildDivider(),
                const SizedBox(height: 5),
                buildSetting('Channels'.tr(), 'Tab To Change'.tr(), 2),
              ],
            ),
          ),
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

  Widget buildSetting(String title, String subTitle, int index) {
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
          ).then((value) => setState(() {}));
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
            Switch(
              value: currentValues[index],
              activeColor: Theme.of(context).primaryColor,
              onChanged: (value) {
                setState(() {
                  currentValues[index] = value;
                });
              },
            )
          ],
        ),
      ),
    );
  }
}
