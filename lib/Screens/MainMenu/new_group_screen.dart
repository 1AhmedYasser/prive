import 'dart:async';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lottie/lottie.dart';
import 'package:prive/Screens/Chat/Chat/chat_screen.dart';
import 'package:prive/Widgets/ChatWidgets/search_text_field.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../Extras/resources.dart';
import '../../Helpers/Utils.dart';
import '../../UltraNetwork/ultra_loading_indicator.dart';
import '../../Widgets/AppWidgets/channels_empty_widgets.dart';
import '../../Widgets/Common/cached_image.dart';

class NewGroupScreen extends StatefulWidget {
  const NewGroupScreen({Key? key}) : super(key: key);

  @override
  _NewGroupScreenState createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen>
    with TickerProviderStateMixin {
  TextEditingController? _controller;
  TextEditingController groupNameController = TextEditingController();
  final _selectedUsers = <User>{};
  Timer? _debounce;
  bool _permissionDenied = false;
  List<Contact> phoneContacts = [];
  List<User> users = [];
  List<User> allUsers = [];
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
    _getContacts();
    _controller = TextEditingController()..addListener(_userNameListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StreamChatTheme.of(context).colorTheme.appBg,
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
          "New Group",
          style: TextStyle(
            fontSize: 23,
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ).tr(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: const Icon(Icons.done),
              color: _selectedUsers.isNotEmpty &&
                      groupNameController.text.isNotEmpty
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
              onPressed: () async {
                if (groupNameController.text.isNotEmpty &&
                    _selectedUsers.isNotEmpty) {
                  try {
                    final groupName = groupNameController.text;
                    final client = StreamChat.of(context).client;
                    final channel = client.channel('messaging', extraData: {
                      'members': [
                        client.state.currentUser!.id,
                        ..._selectedUsers.map((e) => e.id),
                      ],
                      'name': groupName,
                      'channel_type': "Group",
                      'is_important': false,
                      'is_archive': false
                    });
                    await channel.watch();
                    Navigator.of(context).push(
                      ChatScreen.routeWithChannel(channel),
                    );
                  } catch (err) {
                    print(err);
                  }
                }
              },
            ),
          ),
        ],
      ),
      body: ConnectionStatusBuilder(
        statusBuilder: (context, status) {
          String statusString = '';
          bool showStatus = true;

          switch (status) {
            case ConnectionStatus.connected:
              statusString = "Connected";
              showStatus = false;
              break;
            case ConnectionStatus.connecting:
              statusString = "Connecting";
              break;
            case ConnectionStatus.disconnected:
              statusString = "Disconnected";
              break;
          }
          return InfoTile(
            showMessage: showStatus,
            tileAnchor: Alignment.topCenter,
            childAnchor: Alignment.topCenter,
            message: statusString,
            child: NestedScrollView(
              floatHeaderSlivers: true,
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 15, left: 15, right: 15, bottom: 10),
                      child: TextField(
                        controller: groupNameController,
                        onChanged: (value) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          hintText: "Group Name ...",
                          contentPadding: const EdgeInsets.only(left: 20),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade500),
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SearchTextField(
                      controller: _controller,
                      hintText: "Search",
                      showCloseButton: false,
                      onChanged: (value) {
                        if (value.isEmpty) {
                          setState(() {
                            users = allUsers;
                          });
                        } else {
                          setState(() {
                            users = allUsers
                                .where(
                                  (element) => element.name
                                      .toLowerCase()
                                      .contains(
                                          _controller?.text.toLowerCase() ??
                                              ""),
                                )
                                .toList();
                          });
                        }
                      },
                    ),
                  ),
                  if (_selectedUsers.isNotEmpty)
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 104,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedUsers.length,
                          padding: const EdgeInsets.all(8),
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 16),
                          itemBuilder: (_, index) {
                            final user = _selectedUsers.elementAt(index);
                            return Column(
                              children: [
                                Stack(
                                  children: [
                                    UserAvatar(
                                      onlineIndicatorAlignment:
                                          const Alignment(0.9, 0.9),
                                      user: user,
                                      showOnlineStatus: true,
                                      borderRadius: BorderRadius.circular(32),
                                      constraints:
                                          const BoxConstraints.tightFor(
                                        height: 64,
                                        width: 64,
                                      ),
                                    ),
                                    Positioned(
                                      top: -4,
                                      right: -4,
                                      child: GestureDetector(
                                        onTap: () {
                                          if (_selectedUsers.contains(user)) {
                                            setState(() =>
                                                _selectedUsers.remove(user));
                                          }
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: StreamChatTheme.of(context)
                                                .colorTheme
                                                .appBg,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: StreamChatTheme.of(context)
                                                  .colorTheme
                                                  .appBg,
                                            ),
                                          ),
                                          child: StreamSvgIcon.close(
                                            color: StreamChatTheme.of(context)
                                                .colorTheme
                                                .textHighEmphasis,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.name.split(' ')[0],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: HeaderDelegate(
                      height: 32,
                      child: Container(
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          gradient:
                              StreamChatTheme.of(context).colorTheme.bgGradient,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 8,
                          ),
                          child: Text(
                            _controller?.text.isNotEmpty == true
                                ? 'Matches For "${_controller?.text.trim()}"'
                                : "On the platform",
                            style: TextStyle(
                              color: StreamChatTheme.of(context)
                                  .colorTheme
                                  .textLowEmphasis,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: phoneContacts.isNotEmpty
                  ? users.isNotEmpty
                      ? RefreshIndicator(
                          onRefresh: () => Future.sync(() => _getContacts()),
                          child: AnimationLimiter(
                            child: ListView.separated(
                              itemBuilder: (context, index) {
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  child: SlideAnimation(
                                    horizontalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: InkWell(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () {
                                          setState(() {
                                            if (_selectedUsers
                                                .contains(users[index])) {
                                              _selectedUsers
                                                  .remove(users[index]);
                                            } else {
                                              _selectedUsers.add(users[index]);
                                            }
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10, bottom: 0),
                                          child: Column(
                                            children: [
                                              const SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    child: SizedBox(
                                                      height: 50,
                                                      width: 50,
                                                      child: CachedImage(
                                                        url: users[index]
                                                                .image ??
                                                            "",
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 13),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        users[index].name,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 3),
                                                      Text(
                                                        users[index].online
                                                            ? "Online"
                                                            : "Last Seen ${DateFormat('d MMM').format(users[index].lastActive ?? DateTime.now())} at ${DateFormat('hh:mm a').format(
                                                                users[index]
                                                                        .lastActive ??
                                                                    DateTime
                                                                        .now(),
                                                              )}",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: users[index]
                                                                  .online
                                                              ? Colors.green
                                                              : Colors.grey,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (_selectedUsers
                                                      .contains(users[index]))
                                                    const Expanded(
                                                      child: SizedBox(),
                                                    ),
                                                  if (_selectedUsers
                                                      .contains(users[index]))
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 20),
                                                      child: Icon(
                                                        Icons.check_circle,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      ),
                                                    )
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return Divider(
                                  height: 0,
                                  color: Colors.grey.shade300,
                                );
                              },
                              itemCount: users.length,
                            ),
                          ),
                        )
                      : ChannelsEmptyState(
                          animationController: _animationController,
                          title: "No Contacts Found",
                          message: "",
                        )
                  : _permissionDenied == false
                      ? const UltraLoadingIndicator()
                      : SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(height: 100),
                              SizedBox(
                                height: 200,
                                child: Lottie.asset(
                                  R.animations.contactsPermission,
                                  repeat: false,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "Contacts Permission is needed\nTo view your contacts",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () => AppSettings.openAppSettings(),
                                child: const Text(
                                  "Go To Settings",
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500),
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Theme.of(context).primaryColor,
                                  elevation: 0,
                                  minimumSize: Size(
                                    MediaQuery.of(context).size.width / 2.5,
                                    50,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
            ),
          );
        },
      ),
    );
  }

  _getContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      setState(() => _permissionDenied = true);
    } else {
      List contacts = await Utils.fetchContacts(context);
      users = contacts.first;
      allUsers = users;
      phoneContacts = contacts[1];
      setState(() {});
    }
  }

  void _userNameListener() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 0), () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller?.clear();
    _controller?.removeListener(_userNameListener);
    _controller?.dispose();
    super.dispose();
  }
}

class HeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  const HeaderDelegate({
    required this.child,
    required this.height,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: StreamChatTheme.of(context).colorTheme.barsBg,
      child: child,
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(HeaderDelegate oldDelegate) => true;
}
