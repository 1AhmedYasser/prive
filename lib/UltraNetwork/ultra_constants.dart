import 'package:prive/Models/Auth/login.dart';
import 'package:prive/Models/Call/call_logs.dart';
import 'package:prive/Models/Call/prive_call.dart';
import 'package:prive/Models/Catalogs/catalog.dart';
import 'package:prive/Models/Catalogs/catalog_product.dart';
import 'package:prive/Models/Catalogs/collection.dart';
import 'package:prive/Models/Common/status_response.dart';
import 'package:prive/Models/Stories/stories.dart';
import 'package:prive/UltraNetwork/ultra_helpers.dart';
import 'package:prive/UltraNetwork/ultra_request.dart';

const baseUrl = 'https://sae-marketing.com/Prive/API/';

// Auth
final login = UltraRequest('${baseUrl}LogInUser.php', UMethods.post, Login());
final signup = UltraRequest('${baseUrl}CompleteProfileUser.php', UMethods.post, Login());
final logout = UltraRequest('${baseUrl}LogoutUser.php', UMethods.post, StatusResponse());

// Calls
final makeACall = UltraRequest(
  '${baseUrl}Tools-master/DynamicKey/AgoraDynamicKey/php/sample/RtcTokenBuilderSample.php',
  UMethods.post,
  PriveCall(),
);
final roomToken = UltraRequest(
  '${baseUrl}Tools-master/DynamicKey/AgoraDynamicKey/php/sample/AhmedToken.php',
  UMethods.post,
  PriveCall(),
);
final sendInvitations = UltraRequest(
  '${baseUrl}SendInvitation.php',
  UMethods.post,
  StatusResponse(),
);
final getCallLogs = UltraRequest('${baseUrl}GetAllCalles.php', UMethods.post, CallLogs());
final addCall = UltraRequest(
  '${baseUrl}AddCallUserAPI.php',
  UMethods.post,
  StatusResponse(),
);
final answerOrCancelCall = UltraRequest(
  '${baseUrl}AnswerOrCancelCall.php',
  UMethods.post,
  StatusResponse(),
);
final deleteOneCall = UltraRequest(
  '${baseUrl}DeleteOneCall.php',
  UMethods.post,
  StatusResponse(),
);
final deleteAllCalls = UltraRequest(
  '${baseUrl}DeleteAllCalls.php',
  UMethods.post,
  StatusResponse(),
);

// Catalogs
final addCatalog = UltraRequest(
  '${baseUrl}AddCatalogAPI.php',
  UMethods.post,
  StatusResponse(),
);
final deleteCatalog = UltraRequest(
  '${baseUrl}DeleteCatalogAPI.php',
  UMethods.post,
  StatusResponse(),
);
final getCatalogs = UltraRequest('${baseUrl}GetCatalogAPI.php', UMethods.post, Catalog());
final updateCatalog = UltraRequest(
  '${baseUrl}UpdateCatalogAPI.php',
  UMethods.post,
  StatusResponse(),
);
final addCollection = UltraRequest(
  '${baseUrl}AddCollectionAPI.php',
  UMethods.post,
  StatusResponse(),
);
final deleteCollection = UltraRequest(
  '${baseUrl}DeleteCollectionAPI.php',
  UMethods.post,
  StatusResponse(),
);
final getCollections = UltraRequest(
  '${baseUrl}GetCollectionsAPI.php',
  UMethods.post,
  Collection(),
);
final updateCollection = UltraRequest(
  '${baseUrl}UpdateCollectionAPI.php',
  UMethods.post,
  StatusResponse(),
);
final addProduct = UltraRequest('${baseUrl}AddItemAPI.php', UMethods.post, StatusResponse());
final deleteProduct = UltraRequest(
  '${baseUrl}DeleteItemAPI.php',
  UMethods.post,
  StatusResponse(),
);
final getProducts = UltraRequest('${baseUrl}GetItems.php', UMethods.post, CatalogProduct());
final updateProduct = UltraRequest(
  '${baseUrl}UpdateItemAPI.php',
  UMethods.post,
  StatusResponse(),
);

// Stories
final getStories = UltraRequest('${baseUrl}GetStories.php', UMethods.post, Stories());
final deleteStory = UltraRequest('${baseUrl}DeleteStory.php', UMethods.post, StatusResponse());
final addStory = UltraRequest(
  '${baseUrl}AddStoryUserAPI.php',
  UMethods.post,
  StatusResponse(),
);
final viewStory = UltraRequest(
  '${baseUrl}MakeReviewAPI.php',
  UMethods.post,
  StatusResponse(),
);

// Profile
final updateProfile = UltraRequest('${baseUrl}UpdateProfile.php', UMethods.post, Login());
