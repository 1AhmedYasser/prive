import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prive/Extras/resources.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../Models/Catalogs/catalogProduct.dart';
import '../../Widgets/Common/cached_image.dart';

class ProductDetailsScreen extends StatefulWidget {
  final CatalogProductData? product;
  const ProductDetailsScreen({Key? key, this.product}) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int activeSliderIndex = 0;
  List<Widget> sliderWidgets = [];
  List<Map> moreMenu = [];
  List<String> moreMenuTitles = [
    "Edit",
    //"Hide",
    "Delete",
  ];

  @override
  void initState() {
    getSlider();
    fillMenu();
    super.initState();
  }

  void getSlider() {
    if (widget.product?.photo1 != null && widget.product?.photo1 != "NONE") {
      sliderWidgets.add(
        _buildSliderContainer(widget.product?.photo1 ?? "", 0),
      );
    }
    if (widget.product?.photo2 != null && widget.product?.photo2 != "NONE") {
      sliderWidgets.add(
        _buildSliderContainer(widget.product?.photo2 ?? "", 0),
      );
    }
    if (widget.product?.photo3 != null && widget.product?.photo3 != "NONE") {
      sliderWidgets.add(
        _buildSliderContainer(widget.product?.photo3 ?? "", 0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
        ),
        leading: const BackButton(
          color: Color(0xff7a8fa6),
        ),
        actions: [
          GestureDetector(
            onTap: () {},
            child: Image.asset(
              R.images.forwardOutlined,
              width: 25,
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(left: 20, right: 20),
          //   child: GestureDetector(
          //     onTap: () {},
          //     child: Image.asset(
          //       R.images.shareIcon,
          //       width: 21,
          //     ),
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 20),
            child: CoolDropdown(
              dropdownList: moreMenu,
              isAnimation: false,
              dropdownItemPadding: EdgeInsets.zero,
              onChange: (dropdownItem) {
                switch (dropdownItem['value']) {
                  case "Edit":
                    print("Edit Product");
                    break;
                  case "Hide":
                    print("Hide Product");
                    break;
                  case "Delete":
                    print("Delete Product");
                    break;
                  default:
                    break;
                }
              },
              resultHeight: 62,
              resultWidth: 30,
              dropdownWidth: 170,
              dropdownHeight: 70, //110,
              dropdownItemHeight: 30,
              dropdownItemGap: 10,
              labelIconGap: 15,
              onOpen: (open) {
                // if (widget.channel.isMuted) {
                //   setState(() {
                //     chatMoreMenuTitles[2] = "UnMute";
                //     fillMenu();
                //   });
                // } else {
                //   setState(() {
                //     chatMoreMenuTitles[2] = "Mute";
                //     fillMenu();
                //   });
                // }
              },
              dropdownItemTopGap: 0,
              resultIcon: const Icon(
                Icons.more_vert_rounded,
                color: Color(0xff7a8fa6),
                size: 35,
              ),
              resultBD: const BoxDecoration(color: Colors.transparent),
              resultIconLeftGap: 0,
              dropdownItemBottomGap: 0,
              resultPadding: EdgeInsets.zero,
              resultIconRotation: true,
              resultIconRotationValue: 1,
              dropdownItemReverse: true,
              isDropdownLabel: true,
              unselectedItemTS: const TextStyle(
                fontSize: 15,
                color: Color(0xff232323),
              ),
              selectedItemTS: const TextStyle(
                fontSize: 15,
                color: Color(0xff232323),
              ),
              dropdownItemMainAxis: MainAxisAlignment.start,
              isResultLabel: false,
              dropdownItemAlign: Alignment.centerLeft,
              isResultIconLabel: false,
              dropdownPadding: const EdgeInsets.all(20),
              isTriangle: false,
              selectedItemPadding: EdgeInsets.zero,
              resultAlign: Alignment.center,
              resultMainAxis: MainAxisAlignment.center,
              selectedItemBD: const BoxDecoration(color: Colors.transparent),
              triangleWidth: 0,
              triangleHeight: 0,
              triangleAlign: 'center',
              dropdownAlign: 'right',
              gap: 10,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSlider(),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(top: 11, bottom: 11),
                child: AnimatedSmoothIndicator(
                  activeIndex: activeSliderIndex,
                  count: sliderWidgets.length,
                  duration: const Duration(milliseconds: 200),
                  effect: SlideEffect(
                    spacing: 10,
                    radius: 5,
                    dotWidth: 8,
                    dotHeight: 8,
                    paintStyle: PaintingStyle.fill,
                    strokeWidth: 1.5,
                    dotColor:
                        Theme.of(context).primaryColorDark.withOpacity(0.4),
                    activeDotColor: Theme.of(context).primaryColorDark,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 60,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product?.itemName ?? "",
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Text(
                      widget.product?.description ?? "",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff5d5d63),
                      ),
                    ),
                  ),
                  Text(
                    widget.product?.price?.isEmpty == true
                        ? ""
                        : "${widget.product?.price ?? ""} SAR",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: ElevatedButton(
                onPressed: () {},
                child: const Text(
                  "Send Message",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                  minimumSize: Size(MediaQuery.of(context).size.width, 55),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  CarouselSlider _buildSlider() {
    return CarouselSlider(
      options: CarouselOptions(
          height: 265,
          viewportFraction: 1,
          enableInfiniteScroll: true,
          autoPlay: false,
          autoPlayInterval: const Duration(seconds: 3),
          onPageChanged: (page, reason) {
            setState(() {
              activeSliderIndex = page;
            });
          }),
      items: sliderWidgets,
    );
  }

  Widget _buildSliderContainer(String url, int index) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {},
      child: Container(
        width: double.maxFinite,
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
        decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(0)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(0),
          child: CachedImage(
            url: url,
          ),
        ),
      ),
    );
  }

  void fillMenu() {
    moreMenu.clear();
    for (var i = 0; i < moreMenuTitles.length; i++) {
      moreMenu.add({
        'label': moreMenuTitles[i],
        'value': moreMenuTitles[i],
      });
    }
  }
}
