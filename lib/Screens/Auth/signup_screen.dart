import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Helpers/utils.dart';
import 'package:prive/Models/Auth/login.dart';
import 'package:prive/Resources/images.dart';
import 'package:prive/Resources/routes.dart';
import 'package:prive/Resources/shared_pref.dart';
import 'package:prive/UltraNetwork/ultra_constants.dart';
import 'package:prive/UltraNetwork/ultra_network.dart';
import 'package:prive/Widgets/Common/cached_image.dart';

class SignUpScreen extends StatefulWidget {
  final String phoneNumber;
  final LoginData? loginData;

  const SignUpScreen({Key? key, this.phoneNumber = "", this.loginData}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late File profileImage = File("");
  final imagePicker = ImagePicker();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  CancelToken cancelToken = CancelToken();
  final _formKey = GlobalKey<FormState>();
  int selectedGender = 0;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 100),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Sign Up".tr(),
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    Utils.showImagePickerSelector(context, getImage);
                  },
                  child: Container(
                    height: 85,
                    width: 85,
                    decoration: BoxDecoration(
                      color: const Color(0xff7a8fa6),
                      borderRadius: BorderRadius.circular(27),
                    ),
                    child: profileImage.path.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(23),
                            child: Image.asset(
                              Images.cameraImage,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(27),
                            child: Image.file(profileImage, fit: BoxFit.fill),
                          ),
                  ),
                ),
                const SizedBox(height: 45),
                buildField("First Name (Required)", firstNameController),
                const SizedBox(height: 20),
                buildField("Last Name (Optional)", lastNameController),
                const SizedBox(height: 20),
                buildField(
                  "Age (Optional)",
                  ageController,
                  type: const TextInputType.numberWithOptions(
                    signed: true,
                    decimal: false,
                  ),
                  formatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 23),
                Padding(
                  padding: const EdgeInsets.only(left: 35, right: 35),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Gender (Optional)".tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 35, right: 35),
                  child: Row(
                    children: [
                      buildGender("Male", 0),
                      const SizedBox(width: 40),
                      buildGender("Female", 1),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  height: 110,
                  width: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(5),
                    child: CachedImage(
                      url:
                          "https://me.kaspersky.com/content/ar-ae/images/repository/isc/2020/9910/a-guide-to-qr-codes-and-how-to-scan-qr-codes-2.png",
                      containerColor: Colors.transparent,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 35, right: 35),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "By Signing Up,".tr(),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff7a8fa6),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 35, right: 35, top: 5),
                  child: Row(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "You Agree To The ".tr(),
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: Color(0xff7a8fa6)),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () {},
                          child: Text(
                            "Terms & Conditions".tr(),
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (profileImage.path.isEmpty) {
                        Utils.showAlert(context,
                            message: "Please Choose An Image".tr(), alertImage: Images.alertInfoImage);
                      } else {
                        if (loading == false) {
                          List<int> imageBytes = await profileImage.readAsBytes();
                          String base64Image = base64Encode(imageBytes);
                          loading = true;
                          if (mounted) {
                            UltraNetwork.request(
                              context,
                              signup,
                              cancelToken: cancelToken,
                              formData: FormData.fromMap({
                                "UserFirstName": firstNameController.text,
                                "UserLastName": lastNameController.text,
                                "UserPhoto": base64Image,
                                "UserGender": selectedGender == 0 ? "Male" : "Female",
                                "UserBarCode": "783473487",
                                "UserID": widget.loginData?.userID
                              }),
                            ).then((value) {
                              loading = false;
                              Login signup = value;
                              if (signup.success == true) {
                                LoginData? signupData = signup.data?[0];
                                Utils.saveString(SharedPref.token, signupData?.token ?? "");
                                Utils.saveString(SharedPref.userId, signupData?.userID ?? "");
                                Utils.saveString(SharedPref.userImage, signupData?.userPhoto ?? "");
                                Utils.saveString(SharedPref.userPhone, signupData?.userPhone ?? "");
                                Utils.saveString(SharedPref.userFirstName, signupData?.userFirstName ?? "");
                                Utils.saveString(SharedPref.userLastName, signupData?.userLastName ?? "");
                                Utils.saveString(SharedPref.userName,
                                    "${signupData?.userFirstName ?? ""} ${signupData?.userLastName ?? ""}");
                                StreamManager.connectUserToStream(context);
                                Utils.saveBool(SharedPref.isLoggedIn, true);
                                Navigator.pushReplacementNamed(context, Routes.navigatorRoute);
                              }
                            });
                          }
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    elevation: 0,
                    minimumSize: Size(
                      MediaQuery.of(context).size.width - 50,
                      55,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Sign Up".tr(),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildGender(String title, int index) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        setState(() {
          selectedGender = index;
        });
      },
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
                border: Border.all(
                  color: selectedGender == index ? Theme.of(context).primaryColor : Colors.grey,
                ),
                borderRadius: BorderRadius.circular(30)),
            child: CircleAvatar(
              backgroundColor: selectedGender == index ? Theme.of(context).primaryColor : Colors.transparent,
              radius: 12,
              child: selectedGender == index
                  ? const Icon(
                      Icons.done,
                      color: Colors.white,
                      size: 15,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title.tr(),
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Padding buildField(String title, TextEditingController controller,
      {TextInputType type = TextInputType.name, List<TextInputFormatter> formatters = const []}) {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        inputFormatters: formatters,
        cursorColor: const Color(0xff777777),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          hintText: title.tr(),
          hintStyle: const TextStyle(color: Color(0xff777777)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(13),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.shade200,
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(13),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(13),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please Enter Your First Name'.tr();
          }
          return null;
        },
      ),
    );
  }

  Future getImage(ImageSource source, bool isVideo) async {
    Navigator.of(context).pop();
    final pickedFile = await imagePicker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        profileImage = File(pickedFile.path);
      }
    });
  }
}
