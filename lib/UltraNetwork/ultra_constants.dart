import 'package:prive/Models/login.dart';
import 'package:prive/UltraNetwork/ultra_helpers.dart';
import 'package:prive/UltraNetwork/ultra_request.dart';

const baseUrl = "https://sae-marketing.com/Prive/API/";

// Auth
final login = UltraRequest("${baseUrl}LogInUser.php", UMethods.post, Login());
final signup = UltraRequest("${baseUrl}CompleteProfileUser.php", UMethods.post, Login());

