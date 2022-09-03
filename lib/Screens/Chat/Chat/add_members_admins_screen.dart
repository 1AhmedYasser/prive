import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

class AddMembersAdminsScreen extends StatefulWidget {
  final Channel channel;
  final bool isAddingAdmin;
  const AddMembersAdminsScreen({
    Key? key,
    required this.channel,
    this.isAddingAdmin = false,
  }) : super(key: key);

  @override
  State<AddMembersAdminsScreen> createState() => _AddMembersAdminsScreenState();
}

class _AddMembersAdminsScreenState extends State<AddMembersAdminsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StreamChatTheme.of(context).colorTheme.appBg,
      appBar: AppBar(
        elevation: 1,
        toolbarHeight: 56.0,
        backgroundColor: StreamChatTheme.of(context).colorTheme.barsBg,
        leading: const StreamBackButton(),
        title: Column(
          children: [
            Text(
              widget.isAddingAdmin ? "Add Admin" : "Add Member",
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
    );
  }
}
