import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class UltraLoadingIndicator extends StatefulWidget {
  const UltraLoadingIndicator({Key? key}) : super(key: key);

  @override
  State<UltraLoadingIndicator> createState() => _UltraLoadingIndicatorState();
}

class _UltraLoadingIndicatorState extends State<UltraLoadingIndicator> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SpinKitDoubleBounce(
            color: Theme.of(context).primaryColor,
            size: 60,
          ),
        ),
      ),
    );
  }
}
