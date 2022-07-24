import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class EmptyStateWidget extends StatefulWidget {
  final String image;
  final String title;
  final String description;
  final String buttonText;
  final Function onButtonPressed;
  final MainAxisAlignment columnMainAxis;

  const EmptyStateWidget(
      {Key? key,
      this.image = "",
      this.title = "",
      this.description = "",
      this.buttonText = "",
      required this.onButtonPressed,
      this.columnMainAxis = MainAxisAlignment.center})
      : super(key: key);

  @override
  _EmptyStateWidgetState createState() => _EmptyStateWidgetState();
}

class _EmptyStateWidgetState extends State<EmptyStateWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: widget.columnMainAxis,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: SizedBox(
              height: 200,
              child: Image.asset(
                widget.image,
                fit: BoxFit.fill,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
          ).tr(),
          if (widget.description.isNotEmpty)
            const SizedBox(
              height: 20,
            ),
          if (widget.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 50, right: 50),
              child: Text(
                widget.description,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    color: Color(0xff777777)),
              ).tr(),
            ),
          const SizedBox(
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 60, right: 60),
            child: ElevatedButton(
              onPressed: () => widget.onButtonPressed(),
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).primaryColor,
                minimumSize: Size(MediaQuery.of(context).size.width, 53),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                widget.buttonText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ).tr(),
            ),
          ),
          const SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }
}
