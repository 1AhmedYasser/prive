import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

class MemberPermissionsScreen extends StatefulWidget {
  final Channel channel;
  const MemberPermissionsScreen({
    Key? key,
    required this.channel,
  }) : super(key: key);

  @override
  State<MemberPermissionsScreen> createState() => _MemberPermissionsScreenState();
}

class _MemberPermissionsScreenState extends State<MemberPermissionsScreen> {
  bool sendMessages = true;
  bool sendMedia = true;
  bool addMembers = true;

  @override
  void initState() {
    _getMembersPermissions();
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
              'Permissions',
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
      body: StreamBuilder<ChannelState>(
        stream: widget.channel.state?.channelStateStream,
        builder: (context, state) {
          _getMembersPermissions();
          return Column(
            children: [
              StreamOptionListTile(
                tileColor: StreamChatTheme.of(context).colorTheme.appBg,
                separatorColor: StreamChatTheme.of(context).colorTheme.disabled,
                title: 'What Can Members Of This Group Do ?'.tr(),
                titleTextStyle: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 14.5,
                ),
              ),
              StreamOptionListTile(
                tileColor: StreamChatTheme.of(context).colorTheme.appBg,
                separatorColor: Colors.transparent,
                title: 'Send Messages'.tr(),
                titleTextStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 14.5,
                ),
                trailing: CupertinoSwitch(
                  value: sendMessages,
                  onChanged: (val) {
                    setState(() {
                      sendMessages = !sendMessages;
                      widget.channel.updatePartial(
                        set: {
                          'members_permissions': {
                            'send_messages': sendMessages,
                            'send_media': sendMedia,
                            'add_members': addMembers,
                          }
                        },
                      );
                    });
                  },
                ),
                onTap: () {},
              ),
              StreamOptionListTile(
                tileColor: StreamChatTheme.of(context).colorTheme.appBg,
                separatorColor: StreamChatTheme.of(context).colorTheme.disabled,
                title: 'Send Media'.tr(),
                titleTextStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 14.5,
                ),
                trailing: CupertinoSwitch(
                  value: sendMedia,
                  onChanged: (val) {
                    setState(() {
                      sendMedia = !sendMedia;
                      widget.channel.updatePartial(
                        set: {
                          'members_permissions': {
                            'send_messages': sendMessages,
                            'send_media': sendMedia,
                            'add_members': addMembers,
                          }
                        },
                      );
                    });
                  },
                ),
                onTap: () {},
              ),
              StreamOptionListTile(
                tileColor: StreamChatTheme.of(context).colorTheme.appBg,
                separatorColor: StreamChatTheme.of(context).colorTheme.disabled,
                title: 'Add Members'.tr(),
                titleTextStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 14.5,
                ),
                trailing: CupertinoSwitch(
                  value: addMembers,
                  onChanged: (val) {
                    setState(() {
                      addMembers = !addMembers;
                      widget.channel.updatePartial(
                        set: {
                          'members_permissions': {
                            'send_messages': sendMessages,
                            'send_media': sendMedia,
                            'add_members': addMembers,
                          }
                        },
                      );
                    });
                  },
                ),
                onTap: () {},
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: StreamChatTheme.of(context).colorTheme.disabled,
              )
            ],
          );
        },
      ),
    );
  }

  void _getMembersPermissions() {
    Map<String, dynamic>? membersPermissions =
        widget.channel.extraData['members_permissions'] as Map<String, dynamic>? ?? {};
    sendMessages = membersPermissions['send_messages'] as bool? ?? true;
    sendMedia = membersPermissions['send_media'] as bool? ?? true;
    addMembers = membersPermissions['add_members'] as bool? ?? true;
  }
}
