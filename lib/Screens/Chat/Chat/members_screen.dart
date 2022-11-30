import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Models/Chat/group_member.dart';
import 'package:prive/Screens/Chat/Chat/member_permissions_screen.dart';
import 'package:prive/Widgets/Common/cached_image.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class MembersScreen extends StatefulWidget {
  final Channel channel;
  const MembersScreen({
    Key? key,
    required this.channel,
  }) : super(key: key);

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  List<User> users = [];
  List<String> usersPhoneNumbers = [];
  bool userInContacts = true;
  String userRole = '';
  List<GroupMember> groupMembers = [];

  @override
  void initState() {
    _getGroupMembers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StreamChatTheme.of(context).colorTheme.appBg,
      appBar: AppBar(
        elevation: 0.5,
        toolbarHeight: 56.0,
        backgroundColor: StreamChatTheme.of(context).colorTheme.barsBg,
        leading: const StreamBackButton(),
        title: Column(
          children: [
            Text(
              'Members',
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
          _getGroupMembers();
          return Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: groupMembers.length,
                itemBuilder: (context, index) {
                  GroupMember member = groupMembers[index];

                  return Material(
                    color: StreamChatTheme.of(context).colorTheme.appBg,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MemberPermissionsScreen(
                              channel: widget.channel,
                              member: groupMembers[index],
                            ),
                          ),
                        ).then((value) => _getGroupMembers());
                      },
                      child: SizedBox(
                        height: 65.0,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 12.0,
                                  ),
                                  child: SizedBox(
                                    height: 40.0,
                                    width: 40.0,
                                    child: CachedImage(
                                      url: member.image ?? '',
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Text(
                                      //   member.user!.name,
                                      //   style: const TextStyle(
                                      //     fontWeight: FontWeight.bold,
                                      //   ),
                                      // ),
                                      Text(
                                        member.name ?? '',
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Text(
                                    'Member',
                                    style: TextStyle(
                                      color: StreamChatTheme.of(context).colorTheme.textHighEmphasis.withOpacity(0.5),
                                    ),
                                  ).tr(),
                                ),
                              ],
                            ),
                            Container(
                              height: 1.0,
                              color: StreamChatTheme.of(context).colorTheme.disabled,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _getGroupMembers() {
    groupMembers = [];
    List<dynamic>? members = widget.channel.extraData['group_members'] as List<dynamic>;
    for (var member in members) {
      GroupMember groupMember = GroupMember.fromJson(member as Map<String, dynamic>);
      groupMembers.add(groupMember);
    }
    userRole = groupMembers
            .firstWhereOrNull(
              (admin) => admin.id == context.currentUser?.id,
            )
            ?.groupRole ??
        'member';
  }
}
