import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Helpers/utils.dart';
import 'package:prive/Screens/More/more_screen.dart';
import 'package:prive/Widgets/Common/cached_image.dart';
import "dart:io";

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late File profileImage = File("");
  final imagePicker = ImagePicker();

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
              Utils.saveString(R.pref.token, "");
              Utils.saveString(R.pref.userId, "");
              Utils.saveString(R.pref.userName, "");
              Utils.saveString(R.pref.userFirstName, "");
              Utils.saveString(R.pref.userLastName, "");
              Utils.saveString(R.pref.userEmail, "");
              Utils.saveString(R.pref.userPhone, "");
              Utils.saveBool(R.pref.isLoggedIn, false);
              StreamManager.disconnectUserFromStream(context);
              Navigator.pushNamedAndRemoveUntil(context, R.routes.loginRoute,
                  (Route<dynamic> route) => false);
            },
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
                )
              ],
            ),
            style: ElevatedButton.styleFrom(
                primary: Colors.transparent,
                elevation: 0,
                shadowColor: Colors.transparent),
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
                "Online",
                style: TextStyle(
                    color: Theme.of(context).primaryColor, fontSize: 15.5),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25, right: 25, top: 35),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: buildTextField(
                              "First Name", firstNameController,
                              emptyValidatorMessage:
                                  "Please enter a first name"),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: buildTextField("Last Name", lastNameController,
                              emptyValidatorMessage:
                                  "Please enter a last name"),
                        ),
                      ],
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                    const SizedBox(height: 20),
                    buildTextField("Phone Number", phoneNumberController,
                        type: const TextInputType.numberWithOptions(
                          signed: true,
                          decimal: false,
                        ),
                        formatters: [FilteringTextInputFormatter.digitsOnly],
                        emptyValidatorMessage: "Please enter a phone number"),
                    const SizedBox(height: 20),
                    buildTextField("Bio", bioController,
                        maxLines: 4,
                        emptyValidatorMessage: "Please enter a bio"),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {}
                      },
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColor,
                        minimumSize:
                            Size(MediaQuery.of(context).size.width, 55),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MoreScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Settings",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColorDark,
                        minimumSize:
                            Size(MediaQuery.of(context).size.width, 55),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
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
      List<TextInputFormatter> formatters = const [],
      String emptyValidatorMessage = ""}) {
    return TextFormField(
      maxLines: maxLines,
      controller: controller,
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
