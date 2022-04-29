import 'package:prive/Models/Auth/login.dart';
import 'package:prive/Models/Call/call_logs.dart';
import 'package:prive/Models/Call/prive_call.dart';
import 'package:prive/Models/Common/status_response.dart';
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
final getCallLogs =
    UltraRequest("${baseUrl}GetAllCalles.php", UMethods.post, CallLogs());
final addCall = UltraRequest(
    "${baseUrl}AddCallUserAPI.php", UMethods.post, StatusResponse());
final answerOrCancelCall = UltraRequest(
    "${baseUrl}AnswerOrCancelCall.php", UMethods.post, StatusResponse());
final deleteOneCall = UltraRequest(
    "${baseUrl}DeleteOneCall.php", UMethods.post, StatusResponse());
final deleteAllCalls = UltraRequest(
    "${baseUrl}DeleteAllCalls.php", UMethods.post, StatusResponse());

// Stories
final getStories =
    UltraRequest("${baseUrl}GetStories.php", UMethods.post, Stories());
final deleteStory =
    UltraRequest("${baseUrl}DeleteStory.php", UMethods.post, StatusResponse());
final addStory = UltraRequest(
    "${baseUrl}AddStoryUserAPI.php", UMethods.post, StatusResponse());
