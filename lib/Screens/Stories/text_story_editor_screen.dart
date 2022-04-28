import 'package:flutter/material.dart';

class TextStoryEditorScreen extends StatefulWidget {
  const TextStoryEditorScreen({Key? key}) : super(key: key);

  @override
  State<TextStoryEditorScreen> createState() => _TextStoryEditorScreenState();
}

class _TextStoryEditorScreenState extends State<TextStoryEditorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.clear,
            size: 27,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Icon(
            Icons.title,
            size: 27,
          ),
          Padding(
            padding: EdgeInsets.only(right: 22.5, left: 15),
            child: Icon(
              Icons.color_lens_rounded,
              size: 27,
            ),
          )
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.only(left: 50, right: 50),
          child: TextField(
            textAlignVertical: TextAlignVertical.center,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30, color: Colors.white),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: "Type A Status",
              hintStyle: TextStyle(fontSize: 30, color: Colors.white),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
