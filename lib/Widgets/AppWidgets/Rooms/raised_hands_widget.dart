import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../Common/cached_image.dart';

class RaisedHandsWidget extends StatefulWidget {
  const RaisedHandsWidget({Key? key}) : super(key: key);

  @override
  State<RaisedHandsWidget> createState() => _RaisedHandsWidgetState();
}

class _RaisedHandsWidgetState extends State<RaisedHandsWidget> {
  List<bool> raisedHands = [true, false, true];
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25),
          topLeft: Radius.circular(25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 30, left: 30, right: 30),
            child: Text(
              "Raised Hands (4)",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                removeBottom: true,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: 3,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            raisedHands[index] = !raisedHands[index];
                          });
                        },
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: const SizedBox(
                                child: CachedImage(
                                  url:
                                      "https://cdnb.artstation.com/p/assets/images/images/032/393/609/large/anya-valeeva-annie-fan-art-2020.jpg?1606310067",
                                ),
                                height: 60,
                                width: 60,
                              ),
                            ),
                            const SizedBox(width: 15),
                            const Text(
                              "Ahmed Yasser",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                            SizedBox(
                              width: 30,
                              child: Icon(
                                raisedHands[index]
                                    ? FontAwesomeIcons.microphone
                                    : FontAwesomeIcons.microphoneSlash,
                                color: raisedHands[index]
                                    ? const Color(0xff7a8fa6)
                                    : Colors.red,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Icon(
                                  raisedHands[index]
                                      ? FontAwesomeIcons.check
                                      : null,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: raisedHands[index]
                                    ? Theme.of(context).primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: raisedHands[index]
                                      ? Theme.of(context).primaryColor
                                      : const Color(0xff7a8fa6),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
