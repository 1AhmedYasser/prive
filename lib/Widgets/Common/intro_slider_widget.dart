import 'package:flutter/material.dart';

class IntroSliderWidget extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const IntroSliderWidget(
      {Key? key,
      required this.image,
      required this.title,
      required this.description})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(
            height: 120,
          ),
          Expanded(
            child: SizedBox(
              child: Image.asset(
                image,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xff230469),
                fontSize: 30),
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width - 150,
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  fontSize: 17),
            ),
          )
        ],
      ),
    );
  }
}
