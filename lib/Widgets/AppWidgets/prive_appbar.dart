import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

class PriveAppBar extends StatelessWidget {
  final String title;

  const PriveAppBar({Key? key, this.title = ""}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.grey.shade100,
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
      ),
      leading: const BackButton(
        color: Color(0xff7a8fa6),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 23,
          color: Colors.black,
          fontWeight: FontWeight.w400,
        ),
      ).tr(),
    );
  }
}