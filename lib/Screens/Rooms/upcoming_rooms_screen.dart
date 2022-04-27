import 'package:flutter/material.dart';

import '../../Widgets/AppWidgets/prive_appbar.dart';

class UpComingRoomsScreen extends StatefulWidget {
  const UpComingRoomsScreen({Key? key}) : super(key: key);

  @override
  State<UpComingRoomsScreen> createState() => _UpComingRoomsScreenState();
}

class _UpComingRoomsScreenState extends State<UpComingRoomsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 60),
        child: const PriveAppBar(title: "Upcoming Rooms"),
      ),
    );
  }
}
