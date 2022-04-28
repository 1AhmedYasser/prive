import 'package:prive/Models/Auth/login.dart';
import 'package:prive/Models/Call/prive_call.dart';
import 'package:prive/Models/Stories/stories.dart';
import 'package:prive/UltraNetwork/ultra_helpers.dart';
import 'package:prive/UltraNetwork/ultra_request.dart';

const baseUrl = "https://sae-marketing.com/Prive/API/";

// Auth
final login = UltraRequest("${baseUrl}LogInUser.php", UMethods.post, Login());
final signup =
    UltraRequest("${baseUrl}CompleteProfileUser.php", UMethods.post, Login());

// Calls
final makeACall = UltraRequest(
    "${baseUrl}Tools-master/DynamicKey/AgoraDynamicKey/php/sample/RtcTokenBuilderSample.php",
    UMethods.post,
    PriveCall());

// Stories
final getStories =
    UltraRequest("${baseUrl}GetStories.php", UMethods.post, Stories());
