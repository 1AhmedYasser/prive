import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Screens/Chat/chat_screen.dart';
import 'package:prive/UltraNetwork/ultra_loading_indicator.dart';
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
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
        ),
        leading: const BackButton(
          color: Color(0xff7a8fa6),
        ),
        title: const Text(
          "New Message",
          style: TextStyle(
            fontSize: 22,
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ).tr(),
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
      ]
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
