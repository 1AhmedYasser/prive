class Images {
  static String path = "assets/images";
  String splashImage = "$path/splash_image.png";
  String introImage1 = "$path/intro_image1.png";
  String introImage2 = "$path/intro_image2.png";
  String introImage3 = "$path/intro_image3.png";
}

class Animations {
}

class SharedPref {
  String firebaseToken = 'firebase_token';
  String token = 'token';
  String isLoggedIn = "is_logged_in";
  String userId = "user_id";
  String hasNewNotifications = "has_new_notifications";
  String userName = "user_name";
  String userEmail = "user_email";
  String facebookId = "facebook_Id";
  String googleId = "google_Id";
}

class Constants {
}

class Routes {
  String loginRoute = '/Login_Screen';
  String verifyAccountRoute = '/VerifyAccount_screen';
}

class R {
  static Images images = Images();
  static Routes routes = Routes();
  static Constants constants = Constants();
  static Animations animations = Animations();
  static SharedPref pref = SharedPref();
}
