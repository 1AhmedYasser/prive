import 'dart:async';
import 'package:app_settings/app_settings.dart';
import 'package:country_dial_code/country_dial_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';
import 'package:lottie/lottie.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Screens/Rooms/room_screen.dart';
import 'package:prive/Widgets/ChatWidgets/search_text_field.dart';
import 'package:quiver/iterables.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import '../../Extras/resources.dart';
import '../../UltraNetwork/ultra_loading_indicator.dart';
import '../MainMenu/new_group_screen.dart';

class PeopleChooserScreen extends StatefulWidget {
  final String roomName;
  const PeopleChooserScreen({Key? key, this.roomName = ""}) : super(key: key);

  @override
  State<PeopleChooserScreen> createState() => _PeopleChooserScreenState();
}

class _PeopleChooserScreenState extends State<PeopleChooserScreen> {
  TextEditingController? _controller;

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
          "Choose People",
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
              color: _selectedUsers.isNotEmpty
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RoomScreen(
                      isNewRoomCreation: true,
                    ),
                  ),
                );
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
                          top: 20, left: 25, right: 25, bottom: 0),
                      child: Center(
                        child: Text(
                          widget.roomName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 10, left: 15, right: 15, bottom: 10),
                      child: SearchTextField(
                        controller: _controller,
                        hintText: "Search",
                        showCloseButton: false,
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
                                : "Start The Room With",
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

  Future _fetchContacts() async {
    getCountry();
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

  @override
  void dispose() {
    _controller?.clear();
    _controller?.removeListener(_userNameListener);
    _controller?.dispose();
    super.dispose();
  }
}
