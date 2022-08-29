import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Helpers/utils.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class StreamManager {
  static List<User> users = [];
  static List<String> usersPhoneNumbers = [];

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

  static Future<void> updateUser(BuildContext context) async {
    try {
      final client = StreamChatCore.of(context).client;
      await client.updateUser(
        User(
          id: await Utils.getString(R.pref.userId) ?? "",
          extraData: {
            'name': await Utils.getString(R.pref.userName),
            'image': await Utils.getString(R.pref.userImage),
            'phone': await Utils.getString(R.pref.userPhone),
          },
        ),
      );
    } on Exception catch (_) {
      print('Could not update user');
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
    if (channel.isGroup) {
      return channel.name ?? "";
    } else {
      final otherMember = channel.state!.members.firstWhere(
        (member) => member.userId != currentUser.id,
      );
      _getContacts(currentUser);
      if (usersPhoneNumbers
          .contains(otherMember.user?.extraData["phone"] as String?)) {
        return otherMember.user?.name ?? "";
      } else {
        return otherMember.user?.extraData["phone"] as String? ?? "";
      }
    }
  }

  static void _getContacts(User currentUser) async {
    String? myContacts = await Utils.getString(R.pref.myContacts);
    if (myContacts != null && myContacts.isNotEmpty == true) {
      List<dynamic> usersMapList =
          jsonDecode(await Utils.getString(R.pref.myContacts) ?? "");
      List<User> myUsers = [];
      for (var user in usersMapList) {
        myUsers.add(User(
          id: user['id'],
          name: user['name'],
          image: user['image'],
          extraData: {'phone': user['phone'], 'shadow_banned': false},
        ));
      }
      users = myUsers;
      usersPhoneNumbers = users
          .map(
            (e) => e.extraData['phone'] as String,
          )
          .toList();
      usersPhoneNumbers.add(currentUser.extraData['phone'] as String);
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
