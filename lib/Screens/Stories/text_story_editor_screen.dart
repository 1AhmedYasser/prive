import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prive/UltraNetwork/ultra_constants.dart';
import 'package:prive/UltraNetwork/ultra_network.dart';
import 'package:screenshot/screenshot.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class TextStoryEditorScreen extends StatefulWidget {
  final Color backgroundColor;
  const TextStoryEditorScreen({Key? key, required this.backgroundColor}) : super(key: key);

  @override
  State<TextStoryEditorScreen> createState() => _TextStoryEditorScreenState();
}

class _TextStoryEditorScreenState extends State<TextStoryEditorScreen> {
  final Random _random = Random();
  Color? _backgroundColor;
  List<String> availableFonts = GoogleFonts.asMap().keys.toList();
  TextStyle textFont = const TextStyle(fontSize: 30, color: Colors.white);
  TextEditingController statusController = TextEditingController();
  var focusNode = FocusNode();
  File? _capturedImage;
  bool capturingImage = false;
  ScreenshotController screenshotController = ScreenshotController();
  CancelToken cancelToken = CancelToken();

  @override
  void initState() {
    _backgroundColor = widget.backgroundColor;
    focusNode.requestFocus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          leading: !capturingImage
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    size: 27,
                  ),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
          actions: !capturingImage
              ? [
                  GestureDetector(
                    onTap: () => changeFont(),
                    child: const Icon(
                      Icons.title,
                      size: 27,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 22.5, left: 15),
                    child: GestureDetector(
                      onTap: () {
                        changeColor();
                      },
                      child: const Icon(
                        Icons.color_lens_rounded,
                        size: 27,
                      ),
                    ),
                  )
                ]
              : [],
        ),
        body: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 50, right: 50, bottom: 50),
                child: TextField(
                  controller: statusController,
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.center,
                  focusNode: focusNode,
                  onChanged: (value) => setState(() {}),
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  style: textFont,
                  maxLines: null,
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: 'Type A Status'.tr(),
                    hintStyle: textFont,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            if (statusController.text.isNotEmpty && !capturingImage)
              Positioned(
                bottom: 50,
                right: 30,
                child: FloatingActionButton(
                  elevation: 0,
                  onPressed: () => captureImage(),
                  child: const Icon(
                    Icons.send,
                    size: 27,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  void captureImage() async {
    setState(() {
      capturingImage = true;
    });
    focusNode.unfocus();
    Future.delayed(const Duration(milliseconds: 500), () {
      screenshotController.capture(delay: const Duration(milliseconds: 120)).then((capturedImage) async {
        if (capturedImage != null) {
          final tempDir = await getTemporaryDirectory();
          File storyFile = await File('${tempDir.path}/story.png').create();
          storyFile.writeAsBytesSync(capturedImage);
          _capturedImage = storyFile;
          _addStory();
        }
        setState(() {
          capturingImage = false;
        });
      });
    });
  }

  void _addStory() async {
    UltraNetwork.request(
      context,
      addStory,
      showError: false,
      formData: FormData.fromMap({
        'UserID': context.currentUser?.id,
        'Type': 'Photos',
        'Content': await MultipartFile.fromFile(
          _capturedImage?.path ?? '',
          filename: 'story',
        ),
      }),
      cancelToken: cancelToken,
    ).then((value) => Navigator.pop(context));
  }

  void changeColor() {
    setState(() {
      _backgroundColor = Color.fromARGB(
        _random.nextInt(256),
        _random.nextInt(256),
        _random.nextInt(256),
        _random.nextInt(256),
      );
    });
  }

  void changeFont() {
    setState(() {
      textFont = GoogleFonts.getFont(
        availableFonts[_random.nextInt(availableFonts.length)],
        fontSize: 30,
        color: Colors.white,
      );
    });
  }
}
