import 'package:flutter/material.dart';
import 'package:prive/Widgets/Common/cached_image.dart';

class MapThumbnailWidget extends StatelessWidget {
  const MapThumbnailWidget({
    Key? key,
    required this.lat,
    required this.long,
  }) : super(key: key);

  final double lat;
  final double long;

  String get _constructUrl => Uri(
        scheme: 'https',
        host: 'maps.googleapis.com',
        port: 443,
        path: '/maps/api/staticmap',
        queryParameters: {
          'center': '$lat,$long',
          'zoom': '18',
          'size': '700x500',
          'maptype': 'roadmap',
          'key': 'AIzaSyCkYgschahRvE2oDkNRGhOP2kDRMED2AJw',
          'markers': 'color:red|$lat,$long'
        },
      ).toString();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: SizedBox(
        height: 300.0,
        width: 500.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: CachedImage(
            url: _constructUrl,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
