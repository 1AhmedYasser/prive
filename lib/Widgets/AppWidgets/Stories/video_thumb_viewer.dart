import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
// import 'package:video_thumbnail/video_thumbnail.dart';

class VideoThumbViewer extends StatefulWidget {
  final String videoUrl;
  const VideoThumbViewer({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<VideoThumbViewer> createState() => _VideoThumbViewerState();
}

class _VideoThumbViewerState extends State<VideoThumbViewer> {
  File videoThumbnail = File("");

  @override
  void initState() {
    //_getVideoThumb();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FadeInImage(
      key: UniqueKey(),
      placeholder: MemoryImage(
        kTransparentImage,
      ),
      imageErrorBuilder: (context, ob, stackTrace) => Container(
        color: const Color(0xffeeeeee),
      ),
      placeholderErrorBuilder: (context, ob, stackTrace) => Container(
        color: const Color(0xffeeeeee),
      ),
      image: FileImage(videoThumbnail),
      fadeOutDuration: const Duration(
        milliseconds: 100,
      ),
      fadeInDuration: const Duration(
        milliseconds: 100,
      ),
      fit: BoxFit.fill,
    );
  }

  // void _getVideoThumb() async {
  //   await VideoThumbnail.thumbnailFile(
  //     video: widget.videoUrl,
  //     thumbnailPath: (await getTemporaryDirectory()).path,
  //     quality: 50,
  //   ).then((value) {
  //     videoThumbnail = File(value ?? "");
  //     setState(() {});
  //   });
  // }
}
