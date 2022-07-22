import 'package:flutter/material.dart';
import 'package:page_indicator/page_indicator.dart';

class ScreenSlider extends StatefulWidget {
  final List<Widget> _list;

  final PageController _controller;
  final Function onChange;

  const ScreenSlider(this._list, this._controller, this.onChange, {Key? key})
      : super(key: key);

  @override
  _ScreenSliderState createState() => _ScreenSliderState();
}

class _ScreenSliderState extends State<ScreenSlider> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          color: Colors.white,
          child: PageIndicatorContainer(
            child: PageView(
              onPageChanged: (page) {
                widget.onChange(page);
              },
              children: widget._list,
              controller: widget._controller,
              allowImplicitScrolling: true,
            ),
            length: widget._list.length,
            indicatorColor: Colors.transparent,
            shape: IndicatorShape.circle(size: 13),
            indicatorSelectorColor: Colors.transparent,
          ),
          margin: const EdgeInsets.only(bottom: 0),
        ),
      ],
    );
  }
}
