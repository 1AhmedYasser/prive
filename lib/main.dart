import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:prive/Providers/call_provider.dart';
import 'package:prive/Providers/channels_provider.dart';
import 'package:prive/Providers/stories_provider.dart';
import 'package:prive/Providers/volume_provider.dart';
import 'package:prive/Resources/constants.dart';
import 'package:prive/Resources/routes.dart';
import 'package:prive/Screens/Auth/login_screen.dart';
import 'package:prive/Screens/Auth/signup_screen.dart';
import 'package:prive/Screens/Auth/verify_screen.dart';
import 'package:prive/Screens/Home/channels_screen.dart';
import 'package:prive/Screens/Main/home_screen.dart';
import 'package:prive/Screens/Main/navigator_screen.dart';
import 'package:prive/Screens/MainMenu/add_contact_screen.dart';
import 'package:prive/Screens/MainMenu/catalog_screen.dart';
import 'package:prive/Screens/MainMenu/contacts_screen.dart';
import 'package:prive/Screens/MainMenu/new_group_screen.dart';
import 'package:prive/Screens/More/Settings/chat_backgrounds_screen.dart';
import 'package:prive/Screens/More/Settings/chat_settings_screen.dart';
import 'package:prive/Screens/More/Settings/language_screen.dart';
import 'package:prive/Screens/More/Settings/notifications_sounds_screen.dart';
import 'package:prive/Screens/More/Settings/terms_privacy_screen.dart';
import 'package:prive/Screens/More/profile_screen.dart';
import 'package:prive/Screens/More/settings_screen.dart';
import 'package:prive/UltraNetwork/ultra_network.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  EasyLocalization.logger.enableBuildModes = [];
  await Firebase.initializeApp();
  final client = StreamChatClient(Constants.streamKey, logLevel: Level.OFF);
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: Prive(
        client: client,
      ),
    ),
  );
}

class Prive extends StatefulWidget {
  const Prive({Key? key, required this.client}) : super(key: key);

  final StreamChatClient client;

  @override
  State<Prive> createState() => _PriveState();
}

class _PriveState extends State<Prive> {
  final botToastBuilder = BotToastInit();

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      primaryColor: const Color(0xff3cc7bd),
      primaryColorDark: const Color(0xff1293a8),
      fontFamily: 'SFPro',
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => UltraNetwork(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ChannelsProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => VolumeProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => StoriesProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CallProvider(),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        navigatorKey: navigatorKey,
        locale: context.locale,
        theme: theme,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          child = botToastBuilder(context, child);
          return StreamChat(
            client: widget.client,
            streamChatThemeData: StreamChatThemeData.fromTheme(theme).copyWith(),
            child: StreamChatCore(
              client: widget.client,
              child: child,
            ),
          );
        },
        navigatorObservers: [BotToastNavigatorObserver()],
        home: const HomeScreen(),
        routes: {
          Routes.loginRoute: (ctx) => const LoginScreen(),
          Routes.signupRoute: (ctx) => const SignUpScreen(),
          Routes.verifyAccountRoute: (ctx) => const VerifyAccountScreen(),
          Routes.navigatorRoute: (ctx) => const NavigatorScreen(),
          Routes.settingsRoute: (ctx) => const SettingsScreen(),
          Routes.chatRoute: (ctx) => const ChannelsScreen(),
          Routes.termsPrivacyRoute: (ctx) => const TermsPrivacyScreen(),
          Routes.profileRoute: (ctx) => const ProfileScreen(),
          Routes.languageRoute: (ctx) => const LanguageScreen(),
          Routes.chatSettingsRoute: (ctx) => const ChatSettingsScreen(),
          Routes.chatBackgroundRoute: (ctx) => const ChatBackgroundsScreen(),
          Routes.contactsRoute: (ctx) => const ContactsScreen(),
          Routes.notificationsSoundsRoute: (ctx) => const NotificationsSoundsScreen(),
          Routes.addContactScreen: (ctx) => const AddContactScreen(),
          Routes.newGroupScreen: (ctx) => const NewGroupScreen(),
          Routes.catalogScreen: (ctx) => const CatalogScreen(),
        },
      ),
    );
  }
}
