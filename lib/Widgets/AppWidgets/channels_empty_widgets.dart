import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:prive/Extras/resources.dart';

class ChannelsEmptyState extends StatelessWidget {
  final String title;
  final String message;

  const ChannelsEmptyState(
      {Key? key,
      required AnimationController animationController,
      this.title = "No Messages Yet",
      this.message = "Start Chatting With Your Friends Right Now"})
      : _animationController = animationController,
        super(key: key);

  final AnimationController _animationController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            R.animations.emptyChannels,
            width: MediaQuery.of(context).size.width / 1.6,
            fit: BoxFit.fill,
            controller: _animationController,
            onLoaded: (composition) {
              _animationController
                ..duration = composition.duration
                ..forward()
                ..repeat(min: 0.2, max: 1);
            },
          ),
          const SizedBox(height: 25),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
          )
        ],
      ),
    );
  }
}
