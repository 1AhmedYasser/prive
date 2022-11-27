import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Screens/Catalogs/product_details_screen.dart';
import 'package:prive/UltraNetwork/ultra_constants.dart';
import 'package:prive/Widgets/Common/cached_image.dart';
import '../../Models/Catalogs/catalog.dart';
import '../../Models/Catalogs/collection.dart';
import '../../Resources/images.dart';
import '../../UltraNetwork/ultra_network.dart';
import '../../Widgets/AppWidgets/Catalogs/new_catalog_collection_widget.dart';
import 'collection_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class CatalogManagerScreen extends StatefulWidget {
  final CatalogData catalog;
  const CatalogManagerScreen({Key? key, required this.catalog}) : super(key: key);

  @override
  State<CatalogManagerScreen> createState() => _CatalogManagerScreenState();
}

class _CatalogManagerScreenState extends State<CatalogManagerScreen> {
  bool isLoading = true;
  CancelToken cancelToken = CancelToken();
  List<CollectionData> collections = [];

  @override
  void initState() {
    _getCollections();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: collections.isEmpty && isLoading == false
          ? PreferredSize(
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
                title: const Text(
                  "Catalog Manger",
                  style: TextStyle(
                    fontSize: 23,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ).tr(),
              ),
            )
          : null,
      body: isLoading
          ? const SizedBox.shrink()
          : collections.isEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 80, bottom: 30),
                        child: Image.asset(
                          Images.newCatalog,
                          width: MediaQuery.of(context).size.width / 3,
                        ),
                      ),
                      const Text(
                        "${"Organize Your Catalog"}\n${"For Better Sales"}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 23,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 50, right: 50, top: 15),
                        child: Text(
                          "Create Collections To Make Your Item Easier To Find And Your Catalog More Interesting To Browse"
                              .tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 28, right: 28, top: 45),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              // isEditing = false;
                              // controller.closeAllOpenCell();
                            });

                            showMaterialModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => SingleChildScrollView(
                                controller: ModalScrollController.of(context),
                                child: NewCatalogCollectionWidget(
                                  title: "Create New Collection".tr(),
                                  type: "Collection".tr(),
                                  withImage: false,
                                  catalogId: widget.catalog.catalogeID,
                                  isCatalog: false,
                                ),
                              ),
                            ).then((value) {
                              if (value == true) {
                                _getCollections();
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            minimumSize: Size(MediaQuery.of(context).size.width, 55),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Create Collections".tr(),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 200.0,
                      floating: true,
                      pinned: true,
                      snap: true,
                      backgroundColor: Theme.of(context).primaryColorDark,
                      elevation: 0,
                      flexibleSpace: FlexibleSpaceBar(
                        titlePadding: EdgeInsets.zero,
                        centerTitle: true,
                        title: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Flexible(
                              flex: 3,
                              child: Container(),
                            ),
                            Flexible(
                              flex: 1,
                              child: Text(
                                widget.catalog.catalogeName ?? "",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: Container(),
                            ),
                          ],
                        ),
                        background: ShaderMask(
                          shaderCallback: (rect) {
                            return const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black38],
                            ).createShader(
                              Rect.fromLTRB(0, -140, rect.width, rect.height - 20),
                            );
                          },
                          blendMode: BlendMode.darken,
                          child: CachedImage(
                            url: widget.catalog.catalogePhoto ?? "",
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                    if (widget.catalog.userID == context.currentUser?.id)
                      SliverToBoxAdapter(
                        child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            showMaterialModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => SingleChildScrollView(
                                controller: ModalScrollController.of(context),
                                child: NewCatalogCollectionWidget(
                                  title: "Create New Collection".tr(),
                                  type: "Collection".tr(),
                                  withImage: false,
                                  isCatalog: false,
                                  catalogId: widget.catalog.catalogeID,
                                ),
                              ),
                            ).then((value) {
                              if (value == true) {
                                _getCollections();
                              }
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 10, left: 13, right: 13),
                            child: Row(
                              children: [
                                Image.asset(
                                  Images.newCollectionGroupImage,
                                  fit: BoxFit.fill,
                                  width: 70,
                                ),
                                const SizedBox(width: 17),
                                Text(
                                  "Add New Collection".tr(),
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
                      ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, collectionIndex) {
                          return Column(
                            children: [
                              InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CollectionScreen(
                                        collection: collections[collectionIndex],
                                        catalog: widget.catalog,
                                      ),
                                    ),
                                  ).then((value) => _getCollections());
                                },
                                child: ListTile(
                                  title: Text(
                                    collections[collectionIndex].collectionName ?? "",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    collections[collectionIndex].itemsNum == "1"
                                        ? "1 ${"Item"}"
                                        : "${collections[collectionIndex].itemsNum} ${"Items"}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  trailing: Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (widget.catalog.userID == context.currentUser?.id)
                                          GestureDetector(
                                            child: Icon(
                                              Icons.edit,
                                              size: 20,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                            onTap: () {
                                              AwesomeDialog(
                                                  context: context,
                                                  animType: AnimType.scale,
                                                  dialogType: DialogType.noHeader,
                                                  title: collections[collectionIndex].collectionName ?? "",
                                                  desc: 'Select Your Choice'.tr(),
                                                  btnOkText: "Edit".tr(),
                                                  btnCancelText: "Delete".tr(),
                                                  btnOkColor: Theme.of(context).primaryColor,
                                                  btnOkOnPress: () {
                                                    showMaterialModalBottomSheet(
                                                      context: context,
                                                      backgroundColor: Colors.transparent,
                                                      builder: (context) => SingleChildScrollView(
                                                        controller: ModalScrollController.of(context),
                                                        child: NewCatalogCollectionWidget(
                                                          title: "Edit Collection".tr(),
                                                          type: "Collection".tr(),
                                                          withImage: false,
                                                          isCatalog: false,
                                                          isEdit: true,
                                                          collection: collections[collectionIndex],
                                                          catalogId: widget.catalog.catalogeID,
                                                        ),
                                                      ),
                                                    ).then((value) {
                                                      if (value == true) {
                                                        _getCollections();
                                                      }
                                                    });
                                                  },
                                                  btnCancelOnPress: () {
                                                    _removeCollection(collections[collectionIndex].collectionID ?? "");
                                                    setState(() {
                                                      collections.removeAt(collectionIndex);
                                                    });
                                                  }).show();
                                            },
                                          ),
                                        const SizedBox(width: 13),
                                        Text(
                                          "See All".tr(),
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Theme.of(context).primaryColorDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              MediaQuery.removePadding(
                                context: context,
                                removeTop: true,
                                removeBottom: true,
                                child: ListView.separated(
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProductDetailsScreen(
                                              product: collections[collectionIndex].products?[index],
                                              collection: collections[collectionIndex],
                                            ),
                                          ),
                                        ).then((value) {
                                          if (value == true) {
                                            _getCollections();
                                          }
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
                                                      child:
                                                          collections[collectionIndex].products?[index].photo1 != "NONE"
                                                              ? CachedImage(
                                                                  url: collections[collectionIndex]
                                                                          .products?[index]
                                                                          .photo1 ??
                                                                      "",
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
                                                  //           BorderRadius
                                                  //               .circular(10),
                                                  //       child: Container(
                                                  //         color: Colors.black
                                                  //             .withOpacity(
                                                  //           0.2,
                                                  //         ),
                                                  //         child: Padding(
                                                  //           padding:
                                                  //               const EdgeInsets
                                                  //                   .all(27),
                                                  //           child: Image.asset(
                                                  //             R.images
                                                  //                 .hiddenProduct,
                                                  //           ),
                                                  //         ),
                                                  //       ),
                                                  //     ),
                                                  //   ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  collections[collectionIndex].products?[index].itemName ?? "",
                                                  style: const TextStyle(
                                                    fontSize: 16.5,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 3.5, bottom: 3.5, right: 39),
                                                  child: Text(
                                                    collections[collectionIndex].products?[index].description ?? "",
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
                                                  collections[collectionIndex].products?[index].price?.isNotEmpty ==
                                                          true
                                                      ? "${collections[collectionIndex].products?[index].price} SAR"
                                                      : "",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(0xff5d5d63),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                  shrinkWrap: true,
                                  itemCount: collections[collectionIndex].products?.length ?? 0,
                                  physics: const NeverScrollableScrollPhysics(),
                                  separatorBuilder: (BuildContext context, int index) {
                                    return const SizedBox(height: 20);
                                  },
                                ),
                              )
                            ],
                          );
                        },
                        childCount: collections.length,
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 40),
                    )
                  ],
                ),
    );
  }

  void _getCollections() {
    UltraNetwork.request(
      context,
      getCollections,
      formData: FormData.fromMap(
        {"CatalogeID": widget.catalog.catalogeID},
      ),
      cancelToken: cancelToken,
    ).then((value) {
      isLoading = false;
      if (value != null) {
        setState(() {
          Collection collectionsResponse = value;
          collections = collectionsResponse.data ?? [];
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  void _removeCollection(String collectionId) {
    UltraNetwork.request(
      context,
      deleteCollection,
      showError: false,
      showLoadingIndicator: false,
      formData: FormData.fromMap(
        {"CollectionID": collectionId},
      ),
      cancelToken: cancelToken,
    ).then((value) {
      setState(() {});
    });
  }
}
