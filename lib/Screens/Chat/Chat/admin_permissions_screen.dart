import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prive/Models/Chat/group_admin.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

class AdminPermissionsScreen extends StatefulWidget {
  final Channel channel;
  final GroupAdmin admin;
  const AdminPermissionsScreen({
    Key? key,
    required this.channel,
    required this.admin,
  }) : super(key: key);

  @override
  State<AdminPermissionsScreen> createState() => _AdminPermissionsScreenState();
}

class _AdminPermissionsScreenState extends State<AdminPermissionsScreen> {
  bool pinMessages = true;
  bool addMembers = true;
  bool addAdmins = true;
  bool changeGroupInfo = true;
  bool deleteOthersMessages = true;
  bool deleteMembers = true;

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
              "${widget.admin.name?.split(" ").first} Permissions",
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
              title: "What Can This Admin Do ?".tr(),
              titleTextStyle: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 14.5,
              ),
            ),
            _buildPermission(
              "Pin Messages",
              pinMessages,
              () {
                setState(() {
                  pinMessages = !pinMessages;
                });
              },
            ),
            _buildPermission(
              "Add Members",
              addMembers,
              () {
                setState(() {
                  addMembers = !addMembers;
                });
              },
              separatorColor: StreamChatTheme.of(context).colorTheme.disabled,
            ),
            _buildPermission(
              "Add Admins",
              addAdmins,
              () {
                setState(() {
                  addAdmins = !addAdmins;
                });
              },
              separatorColor: StreamChatTheme.of(context).colorTheme.disabled,
            ),
            _buildPermission(
              "Change Group Info",
              changeGroupInfo,
              () {
                setState(() {
                  changeGroupInfo = !changeGroupInfo;
                });
              },
              separatorColor: StreamChatTheme.of(context).colorTheme.disabled,
            ),
            _buildPermission(
              "Delete Members Messages",
              deleteOthersMessages,
              () {
                setState(() {
                  deleteOthersMessages = !deleteOthersMessages;
                });
              },
              separatorColor: StreamChatTheme.of(context).colorTheme.disabled,
            ),
            _buildPermission(
              "Delete Members",
              deleteMembers,
              () {
                setState(() {
                  deleteMembers = !deleteMembers;
                });
              },
              separatorColor: StreamChatTheme.of(context).colorTheme.disabled,
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: StreamChatTheme.of(context).colorTheme.disabled,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 70),
              child: ElevatedButton(
                onPressed: () {
                  print("Remove Admin");
                },
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                  elevation: 0,
                  minimumSize: Size(
                    MediaQuery.of(context).size.width / 2.5,
                    50,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Remove Admin",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ).tr(),
              ),
            )
          ],
        ),
      ),
    );
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
}
