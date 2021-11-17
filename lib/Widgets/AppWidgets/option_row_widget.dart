import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class OptionRowWidget extends StatelessWidget {
  final String image;
  final String title;
  final Function onPressed;
  final bool showDivider;

  const OptionRowWidget(
      {Key? key,
      this.image = "",
      this.title = "",
      required this.onPressed,
      this.showDivider = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
