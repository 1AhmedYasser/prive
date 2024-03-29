import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prive/Resources/images.dart';
import 'package:prive/Resources/routes.dart';
import 'package:prive/Widgets/AppWidgets/prive_appbar.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class ChatSettingsScreen extends StatefulWidget {
  const ChatSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ChatSettingsScreen> createState() => _ChatSettingsScreenState();
}

class _ChatSettingsScreenState extends State<ChatSettingsScreen> {
  double textSize = 14;
  int currentSelectedIndex = 0;

  Map<String, String> themes = {
    Images.colorTheme1: 'Classic',
    Images.colorTheme2: 'Day',
    Images.colorTheme3: 'Dark',
    Images.colorTheme4: 'Night',
    Images.colorTheme5: 'Arctic',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 60),
        child: PriveAppBar(title: 'Chat Settings'.tr()),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 25, left: 20, bottom: 17, right: 20),
              child: Text(
                'Message Text Size',
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: 18,
                ),
              ).tr(),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
              child: SfSlider(
                min: 14,
                max: 24,
                inactiveColor: Colors.grey.shade200,
                value: textSize,
                interval: 2,
                stepSize: 2,
                showLabels: true,
                trackShape: const SfTrackShape(),
                onChanged: (dynamic value) {
                  setState(() {
                    textSize = value;
                  });
                },
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 22, right: 27, bottom: 15, top: 15),
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () => Navigator.pushNamed(context, Routes.chatBackgroundRoute).then((value) => setState(() {})),
                child: Row(
                  children: [
                    Image.asset(
                      Images.chatBackgroundImage,
                      width: 20,
                    ),
                    const SizedBox(width: 18),
                    const Text(
                      'Change Chat Background',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ).tr(),
                    const Expanded(child: SizedBox()),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 17,
                      color: Color(0xffc2c4ca),
                    )
                  ],
                ),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(top: 17, left: 20, bottom: 20, right: 20),
              child: Text(
                'Color Theme',
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: 18,
                ),
              ).tr(),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 7, right: 7),
              child: MediaQuery.removePadding(
                context: context,
                removeBottom: true,
                removeTop: true,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.5 / 2,
                  ),
                  itemBuilder: (context, index) {
                    return InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        setState(() {
                          currentSelectedIndex = index;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Image.asset(themes.keys.toList()[index]),
                                Positioned.fill(
                                  bottom: 10,
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      height: 26,
                                      width: 26,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: currentSelectedIndex == index
                                              ? Theme.of(context).primaryColor
                                              : const Color(0xff7a8fa6),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: currentSelectedIndex == index
                                          ? Icon(
                                              FontAwesomeIcons.solidCircleCheck,
                                              color: Theme.of(context).primaryColor,
                                            )
                                          : null,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(themes[themes.keys.toList()[index]] ?? '')
                          ],
                        ),
                      ),
                    );
                  },
                  itemCount: themes.length,
                ),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 22, right: 27, bottom: 15, top: 15),
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    currentSelectedIndex = 0;
                    textSize = 14;
                  });
                },
                child: Row(
                  children: [
                    Image.asset(
                      Images.undoImage,
                      width: 20,
                    ),
                    const SizedBox(width: 18),
                    const Text(
                      'Reset To Default',
                      style: TextStyle(
                        fontSize: 17,
                        color: Color(0xff7a8fa6),
                        fontWeight: FontWeight.w500,
                      ),
                    ).tr(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
