import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Helpers/notifications_manager.dart';
import 'package:prive/Helpers/screen_slider.dart';
import 'package:prive/Widgets/Common/intro_slider_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int activeIndex = 0;

  final _introSliders = [
    IntroSliderWidget(
        image: R.images.introImage1,
        title: "Messaging & Calls",
        description: "Voice and video calls\nFree .. secure"),
    IntroSliderWidget(
        image: R.images.introImage2,
        title: "Online Market",
        description: "Make your catalog and start sell your products online"),
    IntroSliderWidget(
        image: R.images.introImage3,
        title: "Chat Room",
        description: "Join chat room and take\nto your favorite room"),
  ];

  @override
  void initState() {
    NotificationsManager.setupNotifications(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: ScreenSlider(_introSliders, _pageController, (page) {
                setState(() {
                  activeIndex = page;
                });
              }),
            ),
            const SizedBox(height: 30),
            AnimatedSmoothIndicator(
              activeIndex: activeIndex,
              count: 3,
              duration: const Duration(milliseconds: 200),
              effect: const SlideEffect(
                spacing: 7.5,
                radius: 10,
                dotWidth: 7.5,
                dotHeight: 7.5,
                paintStyle: PaintingStyle.fill,
                strokeWidth: 1.5,
                dotColor: Color(0xff96d4dc),
                activeDotColor: Color(0xff1293a8),
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, R.routes.loginRoute),
              child: const Text(
                "Start Messaging",
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w400),
              ),
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).primaryColor,
                elevation: 0,
                minimumSize: Size(
                  MediaQuery.of(context).size.width - 50,
                  50,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.055,
            ),
          ],
        ),
      ),
    );
  }
}
