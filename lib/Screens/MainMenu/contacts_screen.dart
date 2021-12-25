import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Screens/Chat/Chat/chat_screen.dart';
import 'package:prive/UltraNetwork/ultra_loading_indicator.dart';
import 'package:prive/Widgets/AppWidgets/prive_appbar.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Contact> _contacts = [];
  bool _permissionDenied = false;

  @override
  void initState() {
    _fetchContacts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 60),
        child: const PriveAppBar(title: "New Message"),
      ),
      body: _contacts.isNotEmpty
          ? UsersBloc(
              child: UserListView(
                filter: Filter.and([
                  Filter.notEqual("id", context.currentUser!.id),
                  Filter.notEqual("role", "admin"),
                ]),
                sort: const [
                  SortOption(
                    'name',
                    direction: 1,
                  ),
                ],
                limit: 25,
                onUserTap: (user, widget) {
                  createChannel(context, user);
                },
                loadingBuilder: (context) => const UltraLoadingIndicator(),
              ),
            )
          : const UltraLoadingIndicator(),
    );
  }

  Future<void> createChannel(BuildContext context, User user) async {
    final core = StreamChatCore.of(context);
    final channel = core.client.channel('messaging', extraData: {
      'members': [
        core.currentUser!.id,
        user.id,
      ],
      'channel_type': "Normal",
      'is_important' : false,
      'is_archive' : false
    });
    await channel.watch();

    Navigator.of(context).push(
      ChatScreen.routeWithChannel(channel),
    );
  }

  Future _fetchContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      setState(() => _permissionDenied = true);
    } else {
      final contacts = await FlutterContacts.getContacts();
      setState(() => _contacts = contacts);
    }
  }
}
