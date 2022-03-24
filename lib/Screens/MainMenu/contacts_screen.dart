import 'package:app_settings/app_settings.dart';
import 'package:country_dial_code/country_dial_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lottie/lottie.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Helpers/utils.dart';
import 'package:prive/Screens/Chat/Chat/chat_screen.dart';
import 'package:prive/UltraNetwork/ultra_loading_indicator.dart';
import 'package:prive/Widgets/AppWidgets/prive_appbar.dart';
import 'package:prive/Widgets/Common/cached_image.dart';
import 'package:quiver/iterables.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:intl/intl.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  bool _permissionDenied = false;
  var phoneContacts = [];
  List<String> phoneNumbers = [];
  String? deviceCountryCode =
      WidgetsBinding.instance?.window.locale.countryCode;
  CountryDialCode? deviceDialCode;
  List<User> users = [];

  @override
  void initState() {
    Utils.checkForInternetConnection(context);
    getCountry();
    _fetchContacts();

    super.initState();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 60),
        child: const PriveAppBar(title: "New Message"),
      ),
      body: phoneContacts.isNotEmpty
          ? RefreshIndicator(
              onRefresh: () => Future.sync(() => _fetchContacts()),
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
                              createChannel(context, users[index]);
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
                                        borderRadius: BorderRadius.circular(50),
                                        child: SizedBox(
                                          height: 50,
                                          width: 50,
                                          child: CachedImage(
                                            url: users[index].image ?? "",
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 13),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            users[index].name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            users[index].online
                                                ? "Online"
                                                : "Last Seen ${DateFormat('d MMM').format(users[index].lastActive ?? DateTime.now())} at ${DateFormat('hh:mm a').format(
                                                    users[index].lastActive ??
                                                        DateTime.now(),
                                                  )}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: users[index].online
                                                  ? Colors.green
                                                  : Colors.grey,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
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
                              fontSize: 17, fontWeight: FontWeight.w500),
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
      'is_important': false,
      'is_archive': false
    });
    await channel.watch();

    Navigator.of(context).push(
      ChatScreen.routeWithChannel(channel),
    );
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
              phoneNumbers
                  .add("$dialCode${phone.number.trim().replaceAll(" ", "")}");
            } else {
              phoneNumbers.add(phone.number.trim().replaceAll(" ", ""));
            }
          } catch (e) {
            String dialCode = deviceDialCode?.dialCode == "+20"
                ? "+2"
                : deviceDialCode?.dialCode ?? "";
            phoneNumbers
                .add("$dialCode${phone.number.trim().replaceAll(" ", "")}");
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
}
