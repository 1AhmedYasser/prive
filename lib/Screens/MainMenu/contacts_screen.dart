import 'package:app_settings/app_settings.dart';
import 'package:country_dial_code/country_dial_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';
import 'package:lottie/lottie.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Helpers/utils.dart';
import 'package:prive/Screens/Chat/Chat/chat_screen.dart';
import 'package:prive/UltraNetwork/ultra_loading_indicator.dart';
import 'package:prive/Widgets/AppWidgets/prive_appbar.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

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
          ? UsersBloc(
              child: UserListView(
                pullToRefresh: false,
                filter: Filter.and([
                  Filter.notEqual("id", context.currentUser!.id),
                  Filter.notEqual("role", "admin"),
                  Filter.in_('phone', phoneNumbers),
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
                errorBuilder: (context, widget) {
                  return const SizedBox.shrink();
                },
                loadingBuilder: (context) => const UltraLoadingIndicator(),
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
        phoneNumbers = [
          "+201004136429",
          "+201003501814",
          "+201222383034",
          "+201275845424",
          "+2012-758-45424",
          "+201123985925",
          "+2010-279-19442",
          "+201027919442",
          "+201128518060",
          "+201010032674",
          "+201121013336",
          "+201015070284",
          "+201015070284",
          "+551599197-6990",
          "+919155193930",
          "+2012-740-34646",
          "+201274034646",
          "+201111889598",
          "+201113727678",
          "+201001876856",
          "+201001876856",
          "+201126731394",
          "+2010-642-80415",
          "+201064280415",
          "+201206874946",
          "+201206874946",
          "+201116763795",
          "+201027036636",
          "+2010-270-36636",
          "+97145868748",
          "+918439046987",
          "+201000524612",
          "19286",
          "+917428578244",
          "+201111513786",
          "+2011-115-13786",
          "+8801408-017414",
          "+201006867251",
          "+201203802743",
          "+2012-038-02743",
          "+201156161108",
          "+201117056387",
          "+2011-170-56387",
          "+201120092951",
          "+2011-200-92951",
          "+8801814-095951",
          "+201127657820",
          "+2011-276-57820",
          "+201067588410",
          "+2010-675-88410",
          "+2011-270-65064",
          "+201127065064",
          "+2012-729-29260",
          "+201050014769",
          "+201050014769",
          "+201276267662",
          "+201007621549",
          "+2010-076-21549",
          "+201005860781",
          "+2011-274-56120",
          "+201127456120",
          "+2010-282-53934",
          "+201202444207",
          "+201225830274",
          "+201225830274",
          "+923164670636",
          "+20"
        ];
        print(phoneNumbers);
      }
      setState(() {});
    }
  }
}
