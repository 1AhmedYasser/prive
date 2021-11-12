class Images {
  static String path = "assets/images";
  String splashImage = "$path/splash_image.png";
  String introImage1 = "$path/intro_image1.png";
  String introImage2 = "$path/intro_image2.png";
  String introImage3 = "$path/intro_image3.png";
  String chatTabImage = "$path/chat_tab_image.png";
  String phoneTabImage = "$path/phone_tab_image.png";
  String addTabImage = "$path/add_tab_image.png";
  String micTabImage = "$path/mic_tab_image.png";
  String moreTabImage = "$path/more_tab_image.png";
  String cameraImage = "$path/camera_image.png";
  String catalogManagerImage = "$path/catalog_manager_image.png";
  String contactsImage = "$path/contacts_image.png";
  String inviteFriendsImage = "$path/invite_friends_image.png";
  String myChannelsImage = "$path/my_channels_image.png";
  String myGroupsImage = "$path/my_groups_image.png";
  String peopleNearbyImage = "$path/people_nearby_image.png";
  String settingsImage = "$path/settings_image.png";
  String blockedUserImage = "$path/blocked_user_image.png";
  String chatImage = "$path/chat_image.png";
  String languageImage = "$path/language_image.png";
  String notificationBellImage = "$path/notification_bell_image.png";
  String logoImage = "$path/logo.png";
  String searchImage = "$path/icon_search.png";
  String profileImage = "$path/profile.png";
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
  String signupRoute = '/Signup_Screen';
  String verifyAccountRoute = '/VerifyAccount_screen';
  String navigatorRoute = '/Navigator_Screen';
  String settingsRoute = '/Settings_Screen';
  String chatRoute = '/Chat_Screen';
}

class R {
  static Images images = Images();
  static Routes routes = Routes();
  static Constants constants = Constants();
  static Animations animations = Animations();
  static SharedPref pref = SharedPref();
}
