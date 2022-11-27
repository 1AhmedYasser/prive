import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Models/Rooms/room_user.dart';
import 'package:prive/Widgets/Common/cached_image.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class RoomMenuDialog {
  static showListenerMenu(
    BuildContext context,
    RoomUser? listener, {
    required Function onUpgradePressed,
    required Function onKickPressed,
  }) {
    Alert(
      context: context,
      title: listener?.name ?? '',
      desc: '',
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
                  'Upgrade To Speaker',
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
                  'Kick From Room',
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
            url: listener?.image ?? '',
          ),
        ),
      ),
    ).show();
  }

  static showSpeakerMenu(
    BuildContext context,
    String? roomOwnerId,
    RoomUser? speaker, {
    required Function onChangeNamePressed,
    required Function onDemotePressed,
  }) {
    Alert(
      context: context,
      title: speaker?.name ?? '',
      desc: '',
      closeFunction: null,
      closeIcon: const SizedBox(height: 30),
      content: Column(
        children: [
          if (speaker?.id == context.currentUser?.id)
            DialogButton(
              onPressed: () {
                onChangeNamePressed();
                Navigator.pop(context);
              },
              radius: BorderRadius.circular(15),
              color: Theme.of(context).primaryColorDark,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    FontAwesomeIcons.userPen,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 13),
                  const Text(
                    'Change Your Name',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ).tr()
                ],
              ),
            ),
          if (roomOwnerId == context.currentUser?.id && speaker?.id != context.currentUser?.id)
            DialogButton(
              onPressed: () {
                onDemotePressed();
                Navigator.pop(context);
              },
              radius: BorderRadius.circular(15),
              color: Colors.purple,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    FontAwesomeIcons.anglesDown,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Demote To Listener',
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
            url: speaker?.image ?? '',
          ),
        ),
      ),
    ).show();
  }

  static showChangeNameMenu(
    BuildContext context,
    RoomUser? listener, {
    required Function onChangeNamePressed,
  }) {
    Alert(
      context: context,
      title: listener?.name ?? '',
      desc: '',
      closeFunction: null,
      closeIcon: const SizedBox(height: 30),
      content: Column(
        children: [
          DialogButton(
            onPressed: () {
              onChangeNamePressed();
              Navigator.pop(context);
            },
            radius: BorderRadius.circular(15),
            color: Theme.of(context).primaryColorDark,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  FontAwesomeIcons.userPen,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 13),
                const Text(
                  'Change Your Name',
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
            url: listener?.image ?? '',
          ),
        ),
      ),
    ).show();
  }
}
