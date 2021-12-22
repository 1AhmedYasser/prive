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
  String logoutImage = "$path/logout_image.png";
  String cameraIconImage = "$path/camera_icon_image.png";
  String cameraPlaceholder = "$path/camera_placeholder.png";
  String chatBackgroundImage = "$path/chat_background_image.png";
  String colorTheme1 = "$path/color_theme_1.png";
  String colorTheme2 = "$path/color_theme_2.png";
  String colorTheme3 = "$path/color_theme_3.png";
  String colorTheme4 = "$path/color_theme_4.png";
  String colorTheme5 = "$path/color_theme_5.png";
  String undoImage = "$path/undo_image.png";
  String attachmentImage = "$path/attachment_image.png";
  String chatMoreImage = "$path/chat_more_image.png";
  String emojiImage = "$path/emoji_image.png";
  String recordMicImage = "$path/record_mic_image.png";
  String videoCallImage = "$path/video_call_image.png";
  String voiceCallImage = "$path/voice_call_image.png";
  String chatBackground1 = "$path/chat_background1.png";
  String chatBackground2 = "$path/chat_background2.png";
  String chatBackground3 = "$path/chat_background3.png";
  String chatBackground4 = "$path/chat_background4.png";
  String chatBackground5 = "$path/chat_background5.png";
  String chatBackground6 = "$path/chat_background6.png";
  String chatBackground7 = "$path/chat_background7.png";
  String chatBackground8 = "$path/chat_background8.png";
  String chatBackground9 = "$path/chat_background9.png";
  String chatBackground10 = "$path/chat_background10.png";
  String chatBackground11 = "$path/chat_background11.png";
  String chatBackground12 = "$path/chat_background12.png";
  String chatBackground13 = "$path/chat_background13.png";
  String seenImage = "$path/seen_image.png";
  String sentImage = "$path/sent_image.png";
  String clearHistoryImage = "$path/clear_history_image.png";
  String deleteChatImage = "$path/delete_chat_image.png";
  String muteNotificationsImage = "$path/mute_notifications_image.png";
  String searchChatImage = "$path/search_chat_image.png";
  String addContactImage = "$path/add_contact_image.png";
  String attachmentCameraImage = "$path/attachment_camera_image.png";
  String catalogImage = "$path/catalog_image.png";
  String contactImage = "$path/contact_image.png";
  String galleryImage = "$path/gallery_image.png";
  String loadContactsListImage = "$path/load_contacts_list_image.png";
  String musicImage = "$path/music_image.png";
  String newCatalogImage = "$path/new_catalog_image.png";
  String newChannelImage = "$path/new_channel_image.png";
  String newGroupImage = "$path/new_group_image.png";
  String newSecretChatImage = "$path/new_secret_chat_image.png";
  String closeCall = "$path/close_call.png";
}

class Animations {
  static String path = "assets/animations";
  String emptyChannels = "$path/EmptyChannels.json";
}

class Sounds {
  static String path = "assets/sounds";
  String calling = "$path/calling.mp3";
  String sendMessage = "$path/send_message.mp3";
}

class SharedPref {
  String firebaseToken = 'firebase_token';
  String token = 'token';
  String isLoggedIn = "is_logged_in";
  String userId = "user_id";
  String hasNewNotifications = "has_new_notifications";
  String userName = "user_name";
  String userFirstName = "user_first_name";
  String userLastName = "user_last_name";
  String userEmail = "user_email";
  String userPhone = "user_phone";
  String userImage = "user_image";
  String facebookId = "facebook_Id";
  String googleId = "google_Id";
  String chosenChatBackground = "chosen_chat_background";
  String isChosenChatBackgroundAFile = "is_chosen_chat_background_a_file";
}

class Constants {
  String streamKey = 'tv3c4tjhs5kw';
}

class Routes {
  String loginRoute = '/Login_Screen';
  String signupRoute = '/Signup_Screen';
  String verifyAccountRoute = '/VerifyAccount_screen';
  String navigatorRoute = '/Navigator_Screen';
  String settingsRoute = '/Settings_Screen';
  String chatRoute = '/Chat_Screen';
  String termsPrivacyRoute = '/termsPrivacy_Screen';
  String profileRoute = '/profile_Screen';
  String languageRoute = '/language_Screen';
  String chatSettingsRoute = '/chatSettings_Screen';
  String chatBackgroundRoute = '/chatBackground_Screen';
  String contactsRoute = '/contacts_Screen';
  String notificationsSoundsRoute = '/notificationsSounds_Screen';
  String addContactScreen = '/addContact_Screen';
  String newGroupScreen = '/newGroup_Screen';
}

class R {
  static Images images = Images();
  static Sounds sounds = Sounds();
  static Routes routes = Routes();
  static Constants constants = Constants();
  static Animations animations = Animations();
  static SharedPref pref = SharedPref();
}
