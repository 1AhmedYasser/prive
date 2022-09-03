import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class AdminPermissionsScreen extends StatefulWidget {
  final Channel channel;
  const AdminPermissionsScreen({
    Key? key,
    required this.channel,
  }) : super(key: key);

  @override
  State<AdminPermissionsScreen> createState() => _AdminPermissionsScreenState();
}

class _AdminPermissionsScreenState extends State<AdminPermissionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
