import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Helpers/utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:prive/Widgets/Common/cached_image.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late File profileImage = File("");
  final imagePicker = ImagePicker();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int selectedGender = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                const Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
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
                              R.images.cameraImage,
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
                const Padding(
                  padding: EdgeInsets.only(left: 35, right: 35),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Gender (Optional)",
                      style: TextStyle(
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
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(5),
                    child: CachedImage(
                      url:
                          "https://me.kaspersky.com/content/ar-ae/images/repository/isc/2020/9910/a-guide-to-qr-codes-and-how-to-scan-qr-codes-2.png",
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.only(left: 35, right: 35),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "By Signing Up,",
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff7a8fa6)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 35, right: 35, top: 5),
                  child: Row(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "You Agree To The ",
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff7a8fa6)),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () {},
                          child: Text(
                            "Terms & Conditions",
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
                  onPressed: () =>
                      Navigator.pushNamed(context, R.routes.navigatorRoute),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w400),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                    elevation: 0,
                    minimumSize: Size(
                      MediaQuery.of(context).size.width - 50,
                      50,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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
                  color: selectedGender == index
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
                borderRadius: BorderRadius.circular(30)),
            child: CircleAvatar(
              backgroundColor: selectedGender == index
                  ? Theme.of(context).primaryColor
                  : Colors.transparent,
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
            title,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Padding buildField(String title, TextEditingController controller,
      {TextInputType type = TextInputType.name,
      List<TextInputFormatter> formatters = const []}) {
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          hintText: title,
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

  Future getImage(ImageSource source) async {
    Navigator.of(context).pop();
    final pickedFile = await imagePicker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        profileImage = File(pickedFile.path);
      }
    });
  }
}
