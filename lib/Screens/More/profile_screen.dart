import "dart:io";

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../Extras/resources.dart';
import '../../Helpers/stream_manager.dart';
import '../../Helpers/utils.dart';
import '../../Models/Auth/login.dart';
import '../../UltraNetwork/ultra_constants.dart';
import '../../UltraNetwork/ultra_network.dart';
import '../../Widgets/Common/cached_image.dart';
import 'more_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late File profileImage = File("");
  final imagePicker = ImagePicker();
  CancelToken cancelToken = CancelToken();

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
        ),
        leading: const BackButton(
          color: Color(0xff7a8fa6),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Utils.showAlert(
                context,
                withCancel: true,
                message: "Are You Sure You Want to Log out ?".tr(),
                okButtonText: "Yes".tr(),
                cancelButtonText: "No".tr(),
                onOkButtonPressed: () {
                  _logout();
                  Utils.saveString(R.pref.userId, "");
                  Utils.saveString(R.pref.userName, "");
                  Utils.saveString(R.pref.userFirstName, "");
                  Utils.saveString(R.pref.userLastName, "");
                  Utils.saveString(R.pref.userEmail, "");
                  Utils.saveString(R.pref.userPhone, "");
                  Utils.saveBool(R.pref.isLoggedIn, false);
                  StreamManager.disconnectUserFromStream(context);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    R.routes.loginRoute,
                    (Route<dynamic> route) => false,
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                shadowColor: Colors.transparent),
            child: Row(
              children: [
                Image.asset(
                  R.images.logoutImage,
                  fit: BoxFit.fill,
                  width: 17,
                  height: 17,
                ),
                const SizedBox(width: 7),
                const Text(
                  "Log out",
                  style: TextStyle(
                    color: Color(0xffff2d55),
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                  ),
                ).tr()
              ],
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Align(
                  alignment: Alignment.center,
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      Utils.showImagePickerSelector(context, getImage);
                    },
                    child: SizedBox(
                      height: 135,
                      width: 140,
                      child: Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          height: 110,
                          width: 110,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: (profileImage.path.isEmpty)
                                      ? CachedImage(
                                          url: context.currentUserImage ?? "",
                                          placeholder: R.images.cameraImage,
                                          containerColor: Colors.grey.shade300,
                                        )
                                      : Image.file(
                                          profileImage,
                                          fit: BoxFit.fill,
                                        ),
                                ),
                              ),
                              Positioned(
                                right: -15,
                                top: -12,
                                child: Image.asset(
                                  R.images.cameraIconImage,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.fill,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                "Online".tr(),
                style: TextStyle(
                    color: Theme.of(context).primaryColor, fontSize: 15.5),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25, right: 25, top: 35),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: buildTextField(
                            "First Name".tr(),
                            firstNameController,
                            emptyValidatorMessage:
                                "Please enter a first name".tr(),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: buildTextField(
                            "Last Name".tr(),
                            lastNameController,
                            emptyValidatorMessage:
                                "Please enter a last name".tr(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    buildTextField(
                      "Phone Number".tr(),
                      phoneNumberController,
                      enabled: false,
                      type: const TextInputType.numberWithOptions(
                        signed: true,
                        decimal: false,
                      ),
                      formatters: [FilteringTextInputFormatter.digitsOnly],
                      emptyValidatorMessage: "Please enter a phone number".tr(),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _updateProfile();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        minimumSize:
                            Size(MediaQuery.of(context).size.width, 55),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ).tr(),
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MoreScreen(),
                          ),
                        ).then((value) => setState(() {}));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColorDark,
                        minimumSize:
                            Size(MediaQuery.of(context).size.width, 55),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Settings",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ).tr(),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String hint, TextEditingController controller,
      {int maxLines = 1,
      TextInputType type = TextInputType.text,
      bool enabled = true,
      List<TextInputFormatter> formatters = const [],
      String emptyValidatorMessage = ""}) {
    return TextFormField(
      maxLines: maxLines,
      controller: controller,
      enabled: enabled,
      keyboardType: type,
      inputFormatters: formatters,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 15,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return emptyValidatorMessage;
        }
        return null;
      },
    );
  }

  Future<void> _updateProfile() async {
    Map<String, dynamic> params = {
      "UserID": context.currentUser?.id,
      "UserFirstName": firstNameController.text,
      "UserLastName": lastNameController.text,
    };

    if (profileImage.path.isNotEmpty) {
      params["UserPhoto"] = await MultipartFile.fromFile(
        profileImage.path,
        filename: "UserPhoto",
      );
    }

    if (mounted) {
      UltraNetwork.request(
        context,
        updateProfile,
        formData: FormData.fromMap(params),
        cancelToken: cancelToken,
      ).then((value) {
        if (value != null) {
          Login loginData = value;
          Utils.saveString(R.pref.userName,
              "${loginData.data?.first.userFirstName ?? ""} ${loginData.data?.first.userLastName ?? ""}");
          Utils.saveString(
              R.pref.userFirstName, loginData.data?.first.userFirstName ?? "");
          Utils.saveString(
              R.pref.userLastName, loginData.data?.first.userLastName ?? "");
          Utils.saveString(
              R.pref.userImage, loginData.data?.first.userPhoto ?? "");
          StreamManager.updateUser(context);

          Utils.showAlert(
            context,
            message: "Profile Updated Successfully".tr(),
            okButtonText: "Ok".tr(),
            onOkButtonPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          );
        }
      });
    }
  }

  void _logout() {
    UltraNetwork.request(
      context,
      logout,
      showLoadingIndicator: false,
      showError: false,
      formData: FormData.fromMap({"UserID": context.currentUser?.id}),
      cancelToken: cancelToken,
    ).then((value) {
      Utils.saveString(R.pref.token, "");
    });
  }

  void getUserInfo() async {
    firstNameController.text =
        await Utils.getString(R.pref.userFirstName) ?? "";
    lastNameController.text = await Utils.getString(R.pref.userLastName) ?? "";
    phoneNumberController.text = await Utils.getString(R.pref.userPhone) ?? "";
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
