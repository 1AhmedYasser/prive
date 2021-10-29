import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CachedImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final String placeholder;
  final double placeholderPadding;
  final Color containerColor;
  final bool withLoading;

  const CachedImage(
      {Key? key,
        this.url = "",
        this.placeholder = "",
        this.placeholderPadding = 13,
        this.fit = BoxFit.fill,
        this.containerColor = const Color(0xffeeeeee),
        this.withLoading = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      fadeInDuration: const Duration(milliseconds: 0),
      fadeOutDuration: const Duration(milliseconds: 0),
      imageUrl: url,
      fit: fit,
      placeholder: (context, url) => placeholder.isEmpty
          ? Container(
        color: containerColor,
        child: withLoading
            ? const SpinKitThreeBounce(
          color: Color(0xff3a1782),
          size: 28,
        )
            : null,
      )
          : Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(placeholderPadding),
          child: Image.asset(
            placeholder,
            fit: BoxFit.fill,
          ),
        ),
      ),
      errorWidget: (context, url, error) => placeholder.isEmpty
          ? Container(
        color: containerColor,
        child: withLoading
            ? const SpinKitThreeBounce(
          color: Color(0xff3a1782),
          size: 28,
        )
            : null,
      )
          : Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(placeholderPadding),
          child: Image.asset(
            placeholder,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}