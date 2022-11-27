import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:prive/Helpers/utils.dart';
import 'package:prive/Resources/images.dart';
import 'package:prive/Resources/shared_pref.dart';

class ChatBackgroundsScreen extends StatefulWidget {
  const ChatBackgroundsScreen({Key? key}) : super(key: key);

  @override
  State<ChatBackgroundsScreen> createState() => _ChatBackgroundsScreenState();
}

class _ChatBackgroundsScreenState extends State<ChatBackgroundsScreen> {
  bool isImageShown = false;
  String selectedImage = "";
  String previewedImage = "";
  late File galleryImage = File("");
  late File selectedGalleryImage = File("");
  final imagePicker = ImagePicker();
  bool isFileSelected = false;

  List<String> chatBackgrounds = [
    Images.chatBackground1,
    Images.chatBackground2,
    Images.chatBackground3,
    Images.chatBackground4,
    Images.chatBackground5,
    Images.chatBackground6,
    Images.chatBackground7,
    Images.chatBackground8,
    Images.chatBackground9,
    Images.chatBackground10,
    Images.chatBackground11,
    Images.chatBackground12,
    Images.chatBackground13,
  ];

  @override
  void initState() {
    _getChosenBackground();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
        ),
        leading: BackButton(
          color: const Color(0xff7a8fa6),
          onPressed: () {
            if (isImageShown) {
              setState(() {
                if (isFileSelected) {
                  isFileSelected = false;
                }
                isImageShown = false;
                galleryImage = File("");
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          "Chat Background",
          style: TextStyle(
            fontSize: 23,
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ).tr(),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: isImageShown ? buildImagePreview() : buildBackgroundsList(),
      ),
    );
  }

  Widget buildImagePreview() {
    return Column(
      children: [
        Expanded(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: isFileSelected
                ? Image.file(
                    galleryImage,
                    fit: BoxFit.fill,
                  )
                : Image.asset(
                    previewedImage,
                    fit: BoxFit.fill,
                  ),
          ),
        ),
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            setState(() {
              isImageShown = false;
              if (isFileSelected) {
                selectedGalleryImage = galleryImage;
                selectedImage = "";
                Utils.saveString(SharedPref.chosenChatBackground, selectedGalleryImage.path);
                Utils.saveBool(SharedPref.isChosenChatBackgroundAFile, true);
                Navigator.pop(context);
              } else {
                selectedImage = previewedImage;
                selectedGalleryImage = File("");
                galleryImage = File("");
                Utils.saveString(SharedPref.chosenChatBackground, selectedImage);
                Utils.saveBool(SharedPref.isChosenChatBackgroundAFile, false);
              }
            });
          },
          child: SizedBox(
            height: 100,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Align(
                alignment: Alignment.topCenter,
                child: const Text(
                  "Set Background",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ).tr(),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget buildBackgroundsList() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 22, right: 27, bottom: 15, top: 35),
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () => Utils.showImagePickerSelector(context, getImage),
              child: Row(
                children: [
                  Image.asset(
                    Images.chatBackgroundImage,
                    width: 20,
                  ),
                  const SizedBox(width: 18),
                  const Text(
                    "Select From Gallery Or Camera",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ).tr(),
                  const Expanded(child: SizedBox()),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 17,
                    color: Color(0xffc2c4ca),
                  )
                ],
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(left: 7, right: 7, top: 17, bottom: 20),
            child: MediaQuery.removePadding(
              context: context,
              removeBottom: true,
              removeTop: true,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, childAspectRatio: 0.49, crossAxisSpacing: 0),
                itemBuilder: (context, index) {
                  return InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      setState(() {
                        isImageShown = true;
                        previewedImage = chatBackgrounds[index];
                        isFileSelected = false;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Image.asset(chatBackgrounds[index]),
                              if (selectedImage == chatBackgrounds[index])
                                Positioned.fill(
                                  bottom: 10,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      height: 26,
                                      width: 26,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(color: Theme.of(context).primaryColor, width: 0.5),
                                      ),
                                      child: Icon(
                                        FontAwesomeIcons.solidCircleCheck,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: chatBackgrounds.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _getChosenBackground() async {
    bool? isAFile = await Utils.getBool(SharedPref.isChosenChatBackgroundAFile);

    if (isAFile == true) {
      galleryImage = File(await Utils.getString(SharedPref.chosenChatBackground) ?? "");
      selectedGalleryImage = galleryImage;
      selectedImage = "";
      setState(() {});
    } else {
      if (isAFile == null) {
        selectedImage = Images.chatBackground1;
      } else {
        selectedImage = await Utils.getString(SharedPref.chosenChatBackground) ?? "";
        selectedGalleryImage = File("");
        galleryImage = File("");
      }
      setState(() {});
    }
  }

  Future getImage(ImageSource source) async {
    Navigator.of(context).pop();
    final pickedFile = await imagePicker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        galleryImage = File(pickedFile.path);
        isFileSelected = true;
        isImageShown = true;
      }
    });
  }
}
