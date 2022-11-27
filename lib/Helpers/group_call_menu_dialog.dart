import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prive/Models/Call/call_member.dart';
import 'package:prive/Widgets/Common/cached_image.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class GroupCallMenuDialog {
  static showMemberMenu(
    BuildContext context,
    CallMember? callMember, {
    required Function onMutePressed,
    required Function onKickPressed,
  }) {
    Alert(
      context: context,
      title: callMember?.name ?? '',
      desc: '',
      closeFunction: null,
      closeIcon: const SizedBox(height: 30),
      content: Column(
        children: [
          DialogButton(
            onPressed: () {
              onKickPressed();
              Navigator.pop(context);
            },
            radius: BorderRadius.circular(15),
            color: Theme.of(context).primaryColorDark,
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
                  'Kick From Call',
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
              onMutePressed();
              Navigator.pop(context);
            },
            radius: BorderRadius.circular(15),
            color: Colors.purple,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  FontAwesomeIcons.volumeXmark,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  "${callMember?.hasPermissionToSpeak == true ? "Mute" : "UnMute"} ${callMember?.name?.split(" ").first}",
                  style: const TextStyle(
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
                  'Cancel',
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
            url: callMember?.image ?? '',
          ),
        ),
      ),
    ).show();
  }
}
