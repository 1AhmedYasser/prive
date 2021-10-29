import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:prive/Screens/Auth/verify_screen.dart';
import 'package:prive/Screens/Main/home_screen.dart';
import 'package:provider/provider.dart';

import 'Extras/resources.dart';
import 'Screens/Auth/login_screen.dart';
import 'UltraNetwork/ultra_network.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  EasyLocalization.logger.enableBuildModes = [];
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const Prive(),
    ),
  );
}

class Prive extends StatelessWidget {
  const Prive({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        theme: ThemeData(
          primaryColor: const Color(0xff3cc7bd),
          fontFamily: 'SFPro',
        ),
        debugShowCheckedModeBanner: false,
        builder: BotToastInit(),
        navigatorObservers: [BotToastNavigatorObserver()],
        home: const HomeScreen(),
        routes: {
          R.routes.loginRoute: (ctx) => const LoginScreen(),
          R.routes.verifyAccountRoute: (ctx) => const VerifyAccountScreen(),
        },
      ),
    );
  }
}
