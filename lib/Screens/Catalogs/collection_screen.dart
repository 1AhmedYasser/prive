import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:flutter_swipe_action_cell/core/controller.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Models/Catalogs/catalog.dart';
import 'package:prive/Models/Catalogs/collection.dart';
import 'package:prive/Screens/Catalogs/new_product_screen.dart';
import 'package:prive/Screens/Catalogs/product_details_screen.dart';
import 'package:prive/UltraNetwork/ultra_constants.dart';
import '../../Models/Catalogs/catalogProduct.dart';
import '../../Resources/images.dart';
import '../../UltraNetwork/ultra_network.dart';
import '../../Widgets/Common/cached_image.dart';
import 'package:easy_localization/easy_localization.dart';

class CollectionScreen extends StatefulWidget {
  final CollectionData collection;
  final CatalogData catalog;
  const CollectionScreen({Key? key, required this.collection, required this.catalog}) : super(key: key);

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  CancelToken cancelToken = CancelToken();
  List<CatalogProductData> products = [];
  bool isEditing = false;
  SwipeActionController controller = SwipeActionController();

  @override
  void initState() {
    _getProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 60),
        child: AppBar(
          backgroundColor: Colors.grey.shade100,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarBrightness: Brightness.light,
          ),
          leading: const BackButton(
            color: Color(0xff7a8fa6),
          ),
          title: Text(
            widget.collection.collectionName ?? "",
            style: const TextStyle(
              fontSize: 23,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: [
            if (widget.catalog.userID == context.currentUser?.id)
              if (products.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() {
                      isEditing = !isEditing;
                      controller.closeAllOpenCell();
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Text(
                      isEditing ? "Done" : "Edit",
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ).tr(),
                  ),
                )
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.catalog.userID == context.currentUser?.id)
            InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewProductScreen(
                      collection: widget.collection,
                    ),
                  ),
                ).then((value) {
                  if (value == true) {
                    _getProducts();
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20, left: 18, right: 18),
                child: Row(
                  children: [
                    Image.asset(
                      Images.newCollectionGroupImage,
                      fit: BoxFit.fill,
                      width: 70,
                    ),
                    const SizedBox(width: 17),
                    Text(
                      "Add New Product".tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 17,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (widget.catalog.userID != context.currentUser?.id) const SizedBox(height: 15),
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              removeBottom: true,
              child: AnimationLimiter(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        horizontalOffset: 50,
                        child: FadeInAnimation(
                          child: SwipeActionCell(
                            isDraggable: (widget.catalog.userID == context.currentUser?.id) ? true : false,
                            controller: controller,
                            index: index,
                            key: ValueKey(products[index]),
                            trailingActions: [
                              if (widget.catalog.userID == context.currentUser?.id)
                                SwipeAction(
                                  content: Image.asset(
                                    Images.deleteChatImage,
                                    width: 15,
                                    color: Colors.red,
                                  ),
                                  color: Colors.transparent,
                                  style: const TextStyle(fontSize: 0),
                                  onTap: (handler) async {
                                    await handler(true);
                                    _deleteProduct(products[index].itemID ?? "");
                                    setState(() {
                                      products.removeAt(index);
                                    });
                                  },
                                ),
                              if (widget.catalog.userID == context.currentUser?.id)
                                SwipeAction(
                                  content: Icon(
                                    Icons.edit,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                  color: Colors.transparent,
                                  style: const TextStyle(fontSize: 0),
                                  onTap: (handler) async {
                                    await handler(false);
                                    if (mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => NewProductScreen(
                                            product: products[index],
                                            collection: widget.collection,
                                            isEdit: true,
                                          ),
                                        ),
                                      ).then((value) {
                                        if (value == true) {
                                          _getProducts();
                                        }
                                      });
                                    }
                                  },
                                ),
                            ],
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: Row(
                                children: [
                                  Visibility(
                                    visible: isEditing,
                                    child: const SizedBox(width: 15),
                                  ),
                                  Visibility(
                                    visible: isEditing,
                                    child: CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      minSize: 0,
                                      child: Icon(
                                        Icons.edit,
                                        color: Theme.of(context).primaryColorDark,
                                      ),
                                      onPressed: () {
                                        controller.openCellAt(
                                          index: index,
                                          trailing: true,
                                        );
                                      },
                                    ),
                                  ),
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProductDetailsScreen(
                                            product: products[index],
                                            collection: widget.collection,
                                          ),
                                        ),
                                      ).then((value) {
                                        _getProducts();
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 13, right: 13),
                                          child: SizedBox(
                                            width: 90,
                                            height: 90,
                                            child: Stack(
                                              children: [
                                                Positioned.fill(
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(10),
                                                    child: products[index].photo1 != "NONE"
                                                        ? CachedImage(
                                                            url: products[index].photo1 ?? "",
                                                          )
                                                        : Image.asset(
                                                            Images.collectionsImage,
                                                            fit: BoxFit.contain,
                                                          ),
                                                  ),
                                                ),
                                                // if (index % 2 != 0)
                                                //   Positioned.fill(
                                                //     child: ClipRRect(
                                                //       borderRadius:
                                                //           BorderRadius.circular(10),
                                                //       child: Container(
                                                //         color:
                                                //             Colors.black.withOpacity(
                                                //           0.2,
                                                //         ),
                                                //         child: Padding(
                                                //           padding:
                                                //               const EdgeInsets.all(
                                                //                   27),
                                                //           child: Image.asset(
                                                //             R.images.hiddenProduct,
                                                //           ),
                                                //         ),
                                                //       ),
                                                //     ),
                                                //   ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              products[index].itemName ?? "",
                                              style: const TextStyle(
                                                fontSize: 16.5,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 3.5, bottom: 3.5, right: 39),
                                              child: Text(
                                                products[index].description ?? "",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Color(0xff5d5d63),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              products[index].price?.isNotEmpty == true
                                                  ? "${products[index].price} ${"SAR"}"
                                                  : "",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xff5d5d63),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: products.length,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _getProducts() {
    UltraNetwork.request(
      context,
      getProducts,
      formData: FormData.fromMap(
        {"CollectionID": widget.collection.collectionID ?? ""},
      ),
      cancelToken: cancelToken,
    ).then((value) {
      if (value != null) {
        setState(() {
          CatalogProduct productsResponse = value;
          products = productsResponse.data ?? [];
        });
      }
    });
  }

  void _deleteProduct(String productId) {
    UltraNetwork.request(
      context,
      deleteProduct,
      showLoadingIndicator: false,
      showError: false,
      formData: FormData.fromMap(
        {"ItemID": productId},
      ),
      cancelToken: cancelToken,
    );
  }
}
