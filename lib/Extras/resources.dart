class Images {
  static String path = "assets/images";
  String splashImage = "$path/splash_image.png";
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
}

class R {
  static Images images = Images();
  static Routes routes = Routes();
  static Constants constants = Constants();
  static Animations animations = Animations();
  static SharedPref pref = SharedPref();
}
