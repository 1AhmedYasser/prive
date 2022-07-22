import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prive/Extras/resources.dart';
import 'dart:io';
import 'package:prive/Helpers/utils.dart';
import 'package:easy_localization/easy_localization.dart';

class ChatBackgroundsScreen extends StatefulWidget {
  const ChatBackgroundsScreen({Key? key}) : super(key: key);

  @override
  _ChatBackgroundsScreenState createState() => _ChatBackgroundsScreenState();
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
    R.images.chatBackground1,
    R.images.chatBackground2,
    R.images.chatBackground3,
    R.images.chatBackground4,
    R.images.chatBackground5,
    R.images.chatBackground6,
    R.images.chatBackground7,
    R.images.chatBackground8,
    R.images.chatBackground9,
    R.images.chatBackground10,
    R.images.chatBackground11,
    R.images.chatBackground12,
    R.images.chatBackground13,
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
                Utils.saveString(
                    R.pref.chosenChatBackground, selectedGalleryImage.path);
                Utils.saveBool(R.pref.isChosenChatBackgroundAFile, true);
                Navigator.pop(context);
              } else {
                selectedImage = previewedImage;
                selectedGalleryImage = File("");
                galleryImage = File("");
                Utils.saveString(R.pref.chosenChatBackground, selectedImage);
                Utils.saveBool(R.pref.isChosenChatBackgroundAFile, false);
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
            padding:
                const EdgeInsets.only(left: 22, right: 27, bottom: 15, top: 35),
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () => Utils.showImagePickerSelector(context, getImage),
              child: Row(
                children: [
                  Image.asset(
                    R.images.chatBackgroundImage,
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
            padding:
                const EdgeInsets.only(left: 7, right: 7, top: 17, bottom: 20),
            child: MediaQuery.removePadding(
              context: context,
              removeBottom: true,
              removeTop: true,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.49,
                    crossAxisSpacing: 0),
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
                                  child: Align(
                                    child: Container(
                                      height: 26,
                                      width: 26,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: 0.5),
                                      ),
                                      child: Icon(
                                        FontAwesomeIcons.solidCheckCircle,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                  ),
                                  bottom: 10,
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
    bool? isAFile = await Utils.getBool(R.pref.isChosenChatBackgroundAFile);

    if (isAFile == true) {
      galleryImage =
          File(await Utils.getString(R.pref.chosenChatBackground) ?? "");
      selectedGalleryImage = galleryImage;
      selectedImage = "";
      setState(() {});
    } else {
      if (isAFile == null) {
        selectedImage = R.images.chatBackground1;
      } else {
        selectedImage =
            await Utils.getString(R.pref.chosenChatBackground) ?? "";
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
