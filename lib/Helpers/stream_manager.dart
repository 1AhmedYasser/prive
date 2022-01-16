import 'package:flutter/material.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Helpers/utils.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class StreamManager {
  static Future<void> connectUserToStream(BuildContext context) async {
    try {
      final client = StreamChatCore.of(context).client;
      await client.connectUser(
        User(
          id: await Utils.getString(R.pref.userId) ?? "",
          extraData: {
            'name': await Utils.getString(R.pref.userName),
            'image': await Utils.getString(R.pref.userImage),
            'phone': await Utils.getString(R.pref.userPhone),
          },
        ),
        client.devToken(await Utils.getString(R.pref.userId) ?? "").rawValue,
      );
    } on Exception catch (_) {
      print('Could not connect user');
    }
  }

  static Future<void> disconnectUserFromStream(BuildContext context) async {
    try {
      await StreamChatCore.of(context).client.disconnectUser();
    } on Exception catch (e, st) {
      print('Could not sign out');
    }
  }

  static String getChannelName(Channel channel, User currentUser) {
    if (channel.name != null) {
      return channel.name!;
    } else if (channel.state?.members.isNotEmpty ?? false) {
      final otherMembers = channel.state?.members
          .where(
            (element) => element.userId != currentUser.id,
          )
          .toList();

      if (otherMembers?.length == 1) {
        return otherMembers!.first.user?.name ?? 'No name';
      } else {
        return 'Multiple users';
      }
    } else {
      return 'No Channel Name';
    }
  }

  static String? getChannelImage(Channel channel, User currentUser) {
    if (channel.image != null) {
      return channel.image!;
    } else if (channel.state?.members.isNotEmpty ?? false) {
      final otherMembers = channel.state?.members
          .where(
            (element) => element.userId != currentUser.id,
          )
          .toList();

      if (otherMembers?.length == 1) {
        return otherMembers!.first.user?.image;
      }
    } else {
      return null;
    }
  }
}

extension StreamChatContext on BuildContext {
  String? get currentUserImage => currentUser!.image;

  User? get currentUser => StreamChatCore.of(this).currentUser;
}
