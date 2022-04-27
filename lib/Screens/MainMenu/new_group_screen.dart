import 'dart:async';
import 'package:app_settings/app_settings.dart';
import 'package:country_dial_code/country_dial_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';
import 'package:lottie/lottie.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Screens/Chat/Chat/chat_screen.dart';
import 'package:prive/Widgets/ChatWidgets/search_text_field.dart';
import 'package:quiver/iterables.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import '../../Extras/resources.dart';
import '../../UltraNetwork/ultra_loading_indicator.dart';

class NewGroupScreen extends StatefulWidget {
  const NewGroupScreen({Key? key}) : super(key: key);

  @override
  _NewGroupScreenState createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  TextEditingController? _controller;
  TextEditingController groupNameController = TextEditingController();

  String _userNameQuery = '';
  List<User> users = [];

  final _selectedUsers = <User>{};

  bool _isSearchActive = false;

  Timer? _debounce;
  bool _permissionDenied = false;
  var phoneContacts = [];
  List<String> phoneNumbers = [];
  String? deviceCountryCode =
      WidgetsBinding.instance?.window.locale.countryCode;
  CountryDialCode? deviceDialCode;

  void _userNameListener() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() {
          _userNameQuery = _controller!.text;
          _isSearchActive = _userNameQuery.isNotEmpty;
        });
      }
    });
  }

  @override
  void initState() {
    getCountry();
    _fetchContacts();
    super.initState();
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
                            _isSearchActive
                                ? 'Matches For "$_userNameQuery"'
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
                  ? GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanDown: (_) => FocusScope.of(context).unfocus(),
                      child: UsersBloc(
                        child: UserListView(
                          selectedUsers: _selectedUsers,
                          pullToRefresh: false,
                          groupAlphabetically: _isSearchActive ? false : true,
                          filter: Filter.and([
                            if (_userNameQuery.isNotEmpty)
                              Filter.autoComplete('name', _userNameQuery),
                            Filter.notEqual("id", context.currentUser!.id),
                            Filter.notEqual("role", "admin"),
                            Filter.in_('phone', phoneNumbers),
                          ]),
                          onUserTap: (user, _) {
                            if (!_selectedUsers.contains(user)) {
                              setState(() {
                                _selectedUsers.add(user);
                              });
                            } else {
                              setState(() {
                                _selectedUsers.remove(user);
                              });
                            }
                          },
                          limit: 25,
                          sort: const [
                            SortOption(
                              'name',
                              direction: 1,
                            ),
                          ],
                          emptyBuilder: (_) {
                            return LayoutBuilder(
                              builder: (context, viewportConstraints) {
                                return SingleChildScrollView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: viewportConstraints.maxHeight,
                                    ),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(24),
                                            child: StreamSvgIcon.search(
                                              size: 96,
                                              color: StreamChatTheme.of(context)
                                                  .colorTheme
                                                  .textLowEmphasis,
                                            ),
                                          ),
                                          Text(
                                            "No Matching Contact",
                                            style: StreamChatTheme.of(context)
                                                .textTheme
                                                .footnote
                                                .copyWith(
                                                  color: StreamChatTheme.of(
                                                          context)
                                                      .colorTheme
                                                      .textLowEmphasis,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
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

  void getCountry() async {
    try {
      deviceCountryCode =
          (await FlutterSimCountryCode.simCountryCode ?? "").toUpperCase();
      if (deviceCountryCode?.isEmpty == true) {
        deviceCountryCode = WidgetsBinding.instance?.window.locale.countryCode;
      }
      deviceDialCode =
          CountryDialCode.fromCountryCode(deviceCountryCode ?? "US");
    } catch (e) {
      deviceCountryCode = WidgetsBinding.instance?.window.locale.countryCode;
      deviceDialCode =
          CountryDialCode.fromCountryCode(deviceCountryCode ?? "US");
    }
  }

  Future _fetchContacts() async {
    users.clear();
    phoneContacts.clear();
    phoneNumbers.clear();
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      setState(() => _permissionDenied = true);
    } else {
      phoneContacts = await FlutterContacts.getContacts(withProperties: true);
      for (var contact in phoneContacts) {
        for (var phone in contact.phones) {
          try {
            PhoneNumber.fromRaw(phone.number.trim().replaceAll(" ", ""));
            if (phone.number.trim().replaceAll(" ", "").startsWith("011") ||
                phone.number.trim().replaceAll(" ", "").startsWith("010") ||
                phone.number.trim().replaceAll(" ", "").startsWith("012")) {
              String dialCode = deviceDialCode?.dialCode == "+20"
                  ? "+2"
                  : deviceDialCode?.dialCode ?? "";
              if (phone.number.trim().replaceAll(" ", "").startsWith("05")) {
                phoneNumbers.add(
                    "$dialCode${phone.number.trim().replaceAll(" ", "").substring(1)}");
              } else {
                phoneNumbers
                    .add("$dialCode${phone.number.trim().replaceAll(" ", "")}");
              }
            } else {
              phoneNumbers.add(phone.number.trim().replaceAll(" ", ""));
            }
          } catch (e) {
            String dialCode = deviceDialCode?.dialCode == "+20"
                ? "+2"
                : deviceDialCode?.dialCode ?? "";

            if (phone.number.trim().replaceAll(" ", "").startsWith("05")) {
              phoneNumbers.add(
                  "$dialCode${phone.number.trim().replaceAll(" ", "").substring(1)}");
            } else {
              phoneNumbers
                  .add("$dialCode${phone.number.trim().replaceAll(" ", "")}");
            }
          }
        }
      }

      // Handling Filters
      List<List<String>> dividedPhoneNumbers = [];
      dividedPhoneNumbers = partition(phoneNumbers, 500).toList();
      for (var phoneNumbers in dividedPhoneNumbers) {
        QueryUsersResponse usersResponse =
            await StreamChatCore.of(context).client.queryUsers(
          filter: Filter.and([
            Filter.notEqual("id", context.currentUser!.id),
            Filter.notEqual("role", "admin"),
            Filter.in_("phone", phoneNumbers)
          ]),
          sort: const [
            SortOption(
              'name',
              direction: 1,
            ),
          ],
        );
        for (var user in usersResponse.users) {
          users.add(user);
        }
      }

      setState(() {});
    }
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
