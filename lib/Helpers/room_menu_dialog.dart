import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prive/Models/Rooms/room_user.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:easy_localization/easy_localization.dart';

import '../Widgets/Common/cached_image.dart';

class RoomMenuDialog {
  static showListenerMenu(
    BuildContext context,
    RoomUser? listener, {
    required Function onUpgradePressed,
    required Function onKickPressed,
  }) {
    Alert(
      context: context,
      title: listener?.name ?? "",
      desc: "",
      closeFunction: null,
      closeIcon: const SizedBox(height: 30),
      content: Column(
        children: [
          DialogButton(
            onPressed: () {
              onUpgradePressed();
              Navigator.pop(context);
            },
            radius: BorderRadius.circular(15),
            color: Theme.of(context).primaryColorDark,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  FontAwesomeIcons.anglesUp,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                const Text(
                  "Upgrade To Speaker",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ).tr()
              ],
            ),
          ),
          DialogButton(
            onPressed: () {
              onKickPressed();
              Navigator.pop(context);
            },
            radius: BorderRadius.circular(15),
            color: Colors.purple,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  FontAwesomeIcons.userSlash,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                const Text(
                  "Kick From Room",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ).tr()
              ],
            ),
          ),
          DialogButton(
            onPressed: () {
              Navigator.pop(context);
            },
            radius: BorderRadius.circular(15),
            color: Colors.blue,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ).tr()
              ],
            ),
          )
        ],
      ),
      buttons: [],
      image: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: SizedBox(
          height: 78,
          width: 80,
          child: CachedImage(
            url: listener?.image ?? "",
          ),
        ),
      ),
    ).show();
  }
}
