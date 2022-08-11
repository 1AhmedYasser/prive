import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_contacts/properties/phone.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prive/Helpers/utils.dart';
import 'package:prive/Widgets/AppWidgets/prive_appbar.dart';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:prive/Widgets/Common/cached_image.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../../Extras/resources.dart';

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({Key? key}) : super(key: key);

  @override
  _AddContactScreenState createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late File profileImage = File("");
  final imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 60),
        child: PriveAppBar(title: "Add Contact".tr()),
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
                                          url: "",
                                          containerColor: Colors.grey.shade300,
                                        )
                                      : Image.file(
                                          profileImage,
                                          fit: BoxFit.fill,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25, right: 25, top: 35),
                child: Column(
                  children: [
                    buildTextField(
                        "First Name (Required)".tr(), firstNameController,
                        emptyValidatorMessage:
                            "Please enter a first name".tr()),
                    const SizedBox(height: 20),
                    buildTextField(
                        "Last Name (Optional)".tr(), lastNameController,
                        emptyValidatorMessage: "Please enter a last name".tr(),
                        validate: false),
                    const SizedBox(height: 20),
                    buildTextField("Phone Number".tr(), phoneNumberController,
                        type: const TextInputType.numberWithOptions(
                          signed: true,
                          decimal: false,
                        ),
                        formatters: [FilteringTextInputFormatter.digitsOnly],
                        emptyValidatorMessage:
                            "Please enter a phone number".tr()),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          Uint8List? bytes;
                          if (profileImage.path.isNotEmpty) {
                            bytes = profileImage.readAsBytesSync();
                          }
                          final newContact = Contact()
                            ..name.first = firstNameController.text
                            ..name.last = lastNameController.text
                            ..thumbnail = bytes
                            ..photo = bytes
                            ..phones = [
                              Phone(phoneNumberController.text),
                            ];
                          await newContact.insert();
                          loadContacts();
                          if (mounted) {
                            Utils.showAlert(context,
                                    message: "Contact Added Successfully".tr(),
                                    alertImage: R.images.alertSuccessImage)
                                .then(
                              (value) => Navigator.pop(context),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColor,
                        minimumSize:
                            Size(MediaQuery.of(context).size.width, 55),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Add Contact",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
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
      List<TextInputFormatter> formatters = const [],
      String emptyValidatorMessage = "",
      bool validate = true}) {
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
        if (validate) {
          if (value == null || value.isEmpty) {
            return emptyValidatorMessage;
          }
          return null;
        } else {
          return null;
        }
      },
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

  void loadContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
    } else {
      List contacts = await Utils.fetchContacts(context);
      List<User> users = contacts.first;
      String usersMap = jsonEncode(users);
      Utils.saveString(R.pref.myContacts, usersMap);
    }
  }
}
