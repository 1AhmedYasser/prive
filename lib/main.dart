import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  EasyLocalization.logger.enableBuildModes = [];
  await Firebase.initializeApp();
  // final chatPersistentClient = StreamChatPersistenceClient(
  //   logLevel: Level.INFO,
  //   connectionMode: ConnectionMode.regular,
  // );
  final client = StreamChatClient(R.constants.streamKey);
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

class Prive extends StatelessWidget {
  Prive({Key? key, required this.client}) : super(key: key);

  final StreamChatClient client;
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
      ],
      child: MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: theme,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          child = botToastBuilder(context, child);
          return StreamChat(
            client: client,
            streamChatThemeData:
                StreamChatThemeData.fromTheme(theme).copyWith(),
            child: StreamChatCore(
              client: client,
              child: ChannelsBloc(
                child: UsersBloc(
                  child: child,
                ),
              ),
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
          R.routes.notificationsSoundsRoute: (ctx) =>
              const NotificationsSoundsScreen(),
          R.routes.addContactScreen: (ctx) => const AddContactScreen(),
          R.routes.newGroupScreen: (ctx) => const NewGroupScreen(),
          R.routes.catalogScreen: (ctx) => const CatalogScreen(),
        },
      ),
    );
  }
}
