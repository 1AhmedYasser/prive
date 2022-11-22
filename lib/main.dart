import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:prive/Providers/call_provider.dart';
import 'package:prive/Providers/channels_provider.dart';
import 'package:prive/Providers/stories_provider.dart';
import 'package:prive/Providers/volume_provider.dart';
import 'package:prive/Screens/Auth/signup_screen.dart';
import 'package:prive/Screens/Auth/verify_screen.dart';
import 'package:prive/Screens/Main/home_screen.dart';
import 'package:prive/Screens/Main/navigator_screen.dart';
import 'package:prive/Screens/MainMenu/add_contact_screen.dart';
import 'package:prive/Screens/MainMenu/catalog_screen.dart';
import 'package:prive/Screens/MainMenu/contacts_screen.dart';
import 'package:prive/Screens/MainMenu/new_group_screen.dart';
import 'package:prive/Screens/More/Settings/chat_backgrounds_screen.dart';
import 'package:prive/Screens/More/Settings/chat_settings_screen.dart';
import 'package:prive/Screens/More/Settings/notifications_sounds_screen.dart';
import 'package:prive/Screens/More/profile_screen.dart';
import 'package:prive/Screens/More/settings_screen.dart';
import 'package:prive/Screens/More/Settings/terms_privacy_screen.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'Extras/resources.dart';
import 'Screens/Auth/login_screen.dart';
import 'Screens/Home/channels_screen.dart';
import 'Screens/More/Settings/language_screen.dart';
import 'UltraNetwork/ultra_network.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  EasyLocalization.logger.enableBuildModes = [];
  await Firebase.initializeApp();
  // final chatPersistentClient = StreamChatPersistenceClient(
  //   logLevel: Level.INFO,
  //   connectionMode: ConnectionMode.regular,
  // );
  final client = StreamChatClient(R.constants.streamKey, logLevel: Level.OFF);
  // client.chatPersistenceClient = chatPersistentClient;
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
          R.routes.loginRoute: (ctx) => const LoginScreen(),
          R.routes.signupRoute: (ctx) => const SignUpScreen(),
          R.routes.verifyAccountRoute: (ctx) => const VerifyAccountScreen(),
          R.routes.navigatorRoute: (ctx) => const NavigatorScreen(),
          R.routes.settingsRoute: (ctx) => const SettingsScreen(),
          R.routes.chatRoute: (ctx) => const ChannelsScreen(),
          R.routes.termsPrivacyRoute: (ctx) => const TermsPrivacyScreen(),
          R.routes.profileRoute: (ctx) => const ProfileScreen(),
          R.routes.languageRoute: (ctx) => const LanguageScreen(),
          R.routes.chatSettingsRoute: (ctx) => const ChatSettingsScreen(),
          R.routes.chatBackgroundRoute: (ctx) => const ChatBackgroundsScreen(),
          R.routes.contactsRoute: (ctx) => const ContactsScreen(),
          R.routes.notificationsSoundsRoute: (ctx) => const NotificationsSoundsScreen(),
          R.routes.addContactScreen: (ctx) => const AddContactScreen(),
          R.routes.newGroupScreen: (ctx) => const NewGroupScreen(),
          R.routes.catalogScreen: (ctx) => const CatalogScreen(),
        },
      ),
    );
  }
}
