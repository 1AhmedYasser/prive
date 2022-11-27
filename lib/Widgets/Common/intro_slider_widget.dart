import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class IntroSliderWidget extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const IntroSliderWidget({
    Key? key,
    required this.image,
    required this.title,
    required this.description,
  }) : super(key: key);

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
            child: Padding(
              padding: EdgeInsets.all(
                MediaQuery.of(context).size.width * 0.030,
              ),
              child: SizedBox(
                child: Image.asset(
                  image,
                  fit: BoxFit.contain,
                ),
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
              color: Color(0xff232323),
              fontSize: 32,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width - 150,
            child: AutoSizeText(
              description,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                color: Color(0xff5d5d63),
                fontSize: 22,
              ),
            ),
          )
        ],
      ),
    );
  }
}
