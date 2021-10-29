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

class _ScreenSliderState extends State<ScreenSlider>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => _animateSlider());
  }

  void _animateSlider() {
    Future.delayed(const Duration(seconds: 2)).then((_) {
      int nextPage = widget._controller.page!.round() + 1;
      if (nextPage == widget._list.length) {
        nextPage = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    PageIndicatorContainer container = PageIndicatorContainer(
      child: PageView(
        onPageChanged: (page) {
          widget.onChange(page);
        },
        children: widget._list,
        controller: widget._controller,
      ),
      length: widget._list.length,
      indicatorColor: Colors.transparent,
      shape: IndicatorShape.circle(size: 13),
      indicatorSelectorColor: Colors.transparent,
    );

    return Stack(
      children: <Widget>[
        FutureBuilder(
          future: Future.value(true),
          builder: (BuildContext context, AsyncSnapshot<void> snap) {
            if (!snap.hasData) {
              return Container();
            }
            return Container();
          },
        ),
        Container(
          color: Colors.white,
          child: container,
          margin: const EdgeInsets.only(bottom: 0),
        ),
      ],
    );
  }
}

class SliderBox extends StatelessWidget {
  final Widget child;

  const SliderBox({required Key key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(10), child: child);
  }
}
