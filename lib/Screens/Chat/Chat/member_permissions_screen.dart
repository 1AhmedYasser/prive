import 'package:bot_toast/bot_toast.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prive/Models/Chat/group_member.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class MemberPermissionsScreen extends StatefulWidget {
  final Channel channel;
  final GroupMember member;
  const MemberPermissionsScreen({
    Key? key,
    required this.channel,
    required this.member,
  }) : super(key: key);

  @override
  State<MemberPermissionsScreen> createState() => _MemberPermissionsScreenState();
}

class _MemberPermissionsScreenState extends State<MemberPermissionsScreen> {
  bool sendMessages = true;
  bool sendPhotos = true;
  bool sendVideos = true;
  bool sendVoiceRecords = true;
  List<GroupMember> groupMembers = [];

  @override
  void initState() {
    _getGroupMembers();
    _getMemberPermissions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StreamChatTheme.of(context).colorTheme.appBg,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 56.0,
        backgroundColor: StreamChatTheme.of(context).colorTheme.barsBg,
        leading: const StreamBackButton(),
        title: Column(
          children: [
            Text(
              "${widget.member.name?.split(" ").first} Permissions",
              style: TextStyle(
                color: StreamChatTheme.of(context).colorTheme.textHighEmphasis,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ).tr()
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamOptionListTile(
              tileColor: StreamChatTheme.of(context).colorTheme.appBg,
              separatorColor: StreamChatTheme.of(context).colorTheme.disabled,
              title: 'What Can This Member Do ?'.tr(),
              titleTextStyle: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 14.5,
              ),
            ),
            _buildPermission(
              'Send Messages',
              sendMessages,
              () {
                setState(() {
                  sendMessages = !sendMessages;
                });
                groupMembers
                    .firstWhereOrNull(
                      (member) => member.id == widget.member.id,
                    )
                    ?.memberPermissions
                    ?.sendMessages = sendMessages;
                updateMembers(context);
              },
            ),
            _buildPermission(
              'Send Photos',
              sendPhotos,
              () {
                setState(() {
                  sendPhotos = !sendPhotos;
                });
                groupMembers
                    .firstWhereOrNull(
                      (member) => member.id == widget.member.id,
                    )
                    ?.memberPermissions
                    ?.sendPhotos = sendPhotos;
                updateMembers(context);
              },
              separatorColor: StreamChatTheme.of(context).colorTheme.disabled,
            ),
            _buildPermission(
              'Send Videos',
              sendVideos,
              () {
                setState(() {
                  sendVideos = !sendVideos;
                });
                groupMembers
                    .firstWhereOrNull(
                      (member) => member.id == widget.member.id,
                    )
                    ?.memberPermissions
                    ?.sendVideos = sendVideos;
                updateMembers(context);
              },
              separatorColor: StreamChatTheme.of(context).colorTheme.disabled,
            ),
            _buildPermission(
              'Send Voice Records',
              sendVoiceRecords,
              () {
                setState(() {
                  sendVoiceRecords = !sendVoiceRecords;
                });
                groupMembers
                    .firstWhereOrNull(
                      (member) => member.id == widget.member.id,
                    )
                    ?.memberPermissions
                    ?.sendVoiceRecords = sendVoiceRecords;
                updateMembers(context);
              },
              separatorColor: StreamChatTheme.of(context).colorTheme.disabled,
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: StreamChatTheme.of(context).colorTheme.disabled,
            ),
          ],
        ),
      ),
    );
  }

  void updateMembers(BuildContext context, {bool goBackAfterUpdate = false}) {
    List<Map<String, dynamic>> members = [];
    for (var member in groupMembers) {
      members.add({
        'id': member.id,
        'name': member.name,
        'image': member.image,
        'group_role': member.groupRole,
        'members_permissions': {
          'send_messages': member.memberPermissions?.sendMessages ?? true,
          'send_photos': member.memberPermissions?.sendPhotos ?? true,
          'send_videos': member.memberPermissions?.sendVideos ?? true,
          'send_voice_records': member.memberPermissions?.sendVoiceRecords ?? true,
        },
      });
    }
    widget.channel.updatePartial(set: {'group_members': members}).then((value) {
      if (goBackAfterUpdate) {
        if (mounted) {
          Navigator.pop(context);
        }
      }
      BotToast.removeAll('loading');
    });
  }

  Widget _buildPermission(
    String title,
    bool permission,
    Function onPressed, {
    Color separatorColor = Colors.transparent,
  }) {
    return StreamOptionListTile(
      tileColor: StreamChatTheme.of(context).colorTheme.appBg,
      separatorColor: separatorColor,
      title: title.tr(),
      titleTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 14.5,
      ),
      trailing: CupertinoSwitch(
        value: permission,
        onChanged: (val) {
          onPressed();
        },
      ),
    );
  }

  void _getGroupMembers() {
    groupMembers = [];
    List<dynamic>? members = widget.channel.extraData['group_members'] as List<dynamic>? ?? [];
    for (var member in members) {
      GroupMember groupMember = GroupMember.fromJson(member as Map<String, dynamic>);
      groupMembers.add(groupMember);
    }
    setState(() {});
  }

  void _getMemberPermissions() {
    MemberGroupPermissions? permissions = widget.member.memberPermissions;
    sendMessages = permissions?.sendMessages ?? true;
    sendPhotos = permissions?.sendPhotos ?? true;
    sendVideos = permissions?.sendVideos ?? true;
    sendVoiceRecords = permissions?.sendVoiceRecords ?? true;
    setState(() {});
  }
}
