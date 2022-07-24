import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:flutter_swipe_action_cell/core/controller.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Screens/Catalogs/catalog_manager_screen.dart';
import 'package:prive/UltraNetwork/ultra_constants.dart';
import 'package:prive/UltraNetwork/ultra_network.dart';
import 'package:prive/Widgets/AppWidgets/Catalogs/new_catalog_collection_widget.dart';
import 'package:prive/Widgets/Common/cached_image.dart';
import '../../Models/Catalogs/catalog.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import '../Catalogs/catalog_product_sender_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({Key? key}) : super(key: key);

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  List<CatalogData> catalogs = [];
  CancelToken cancelToken = CancelToken();
  bool isLoading = true;
  bool isEditing = false;
  SwipeActionController controller = SwipeActionController();

  @override
  void initState() {
    _getCatalogs();
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
            catalogs.isEmpty && isLoading == false
                ? "Create A Catalog"
                : "Catalogs",
            style: const TextStyle(
              fontSize: 23,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ).tr(),
          actions: [
            if (catalogs.isNotEmpty)
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
      body: catalogs.isEmpty
          ? isLoading
              ? const SizedBox.shrink()
              : SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 80, bottom: 30),
                        child: Image.asset(
                          R.images.newCatalog,
                          width: MediaQuery.of(context).size.width / 3,
                        ),
                      ),
                      const Text(
                        "Create A Catalog",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                        ),
                      ).tr(),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 50, right: 50, top: 15),
                        child: Text(
                          "Send Products And Services To Your Customers And Save Space On Your Phone",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ).tr(),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 28, right: 28, top: 45),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isEditing = false;
                              controller.closeAllOpenCell();
                            });
                            showMaterialModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => SingleChildScrollView(
                                controller: ModalScrollController.of(context),
                                child: NewCatalogCollectionWidget(
                                  title: "Create New Catalog".tr(),
                                  type: "Catalog".tr(),
                                ),
                              ),
                            ).then((value) {
                              if (value == true) {
                                _getCatalogs();
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).primaryColor,
                            minimumSize:
                                Size(MediaQuery.of(context).size.width, 55),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Create Catalog",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
                          ).tr(),
                        ),
                      ),
                    ],
                  ),
                )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    setState(() {
                      isEditing = false;
                      controller.closeAllOpenCell();
                    });
                    showMaterialModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) => SingleChildScrollView(
                        controller: ModalScrollController.of(context),
                        child: NewCatalogCollectionWidget(
                          title: "Create New Catalog".tr(),
                          type: "Catalog".tr(),
                        ),
                      ),
                    ).then((value) {
                      if (value == true) {
                        _getCatalogs();
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 20, bottom: 20, left: 18, right: 18),
                    child: Row(
                      children: [
                        Image.asset(
                          R.images.newCollectionGroupImage,
                          fit: BoxFit.fill,
                          width: 70,
                        ),
                        const SizedBox(width: 17),
                        Text(
                          "Add New Catalog",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 17,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ).tr(),
                      ],
                    ),
                  ),
                ),
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
                                  controller: controller,
                                  index: index,
                                  key: ValueKey(catalogs[index]),
                                  trailingActions: [
                                    SwipeAction(
                                      content: Image.asset(
                                        R.images.deleteChatImage,
                                        width: 15,
                                        color: Colors.red,
                                      ),
                                      color: Colors.transparent,
                                      style: const TextStyle(fontSize: 0),
                                      onTap: (handler) async {
                                        await handler(true);
                                        _removeCatalog(
                                            catalogs[index].catalogeID ?? "");
                                        setState(() {
                                          catalogs.removeAt(index);
                                        });
                                      },
                                    ),
                                    SwipeAction(
                                      content: Icon(
                                        Icons.edit,
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                      color: Colors.transparent,
                                      style: const TextStyle(fontSize: 0),
                                      onTap: (handler) async {
                                        await handler(false);
                                        showMaterialModalBottomSheet(
                                          context: context,
                                          backgroundColor: Colors.transparent,
                                          builder: (context) =>
                                              SingleChildScrollView(
                                            controller:
                                                ModalScrollController.of(
                                                    context),
                                            child: NewCatalogCollectionWidget(
                                              title: "Edit Catalog".tr(),
                                              type: "Catalog".tr(),
                                              isEdit: true,
                                              catalog: catalogs[index],
                                            ),
                                          ),
                                        ).then((value) {
                                          if (value == true) {
                                            _getCatalogs();
                                          }
                                        });
                                      },
                                    ),
                                    SwipeAction(
                                      content: Icon(
                                        Icons.send,
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                      color: Colors.transparent,
                                      style: const TextStyle(fontSize: 0),
                                      onTap: (handler) async {
                                        await handler(false);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CatalogProductSenderScreen(
                                              catalog: catalogs[index],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
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
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 15),
                                            child: Icon(
                                              Icons.edit,
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                            ),
                                          ),
                                          onPressed: () {
                                            controller.openCellAt(
                                              index: index,
                                              trailing: true,
                                            );
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CatalogManagerScreen(
                                                  catalog: catalogs[index],
                                                ),
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 20),
                                            child: ListTile(
                                              leading: catalogs[index]
                                                          .catalogePhoto ==
                                                      "NONE"
                                                  ? Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.5),
                                                            spreadRadius: 0.3,
                                                            blurRadius: 2,
                                                          ),
                                                        ],
                                                      ),
                                                      child: Image.asset(
                                                        R.images
                                                            .collectionsImage,
                                                        fit: BoxFit.fill,
                                                        height: 70,
                                                        width: 73,
                                                      ),
                                                    )
                                                  : Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.5),
                                                            spreadRadius: 0.3,
                                                            blurRadius: 2,
                                                          ),
                                                        ],
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        child: SizedBox(
                                                          height: 70,
                                                          width: 73,
                                                          child: CachedImage(
                                                            url: catalogs[index]
                                                                    .catalogePhoto ??
                                                                "",
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                              title: Text(
                                                catalogs[index].catalogeName ??
                                                    "",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 17,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: catalogs.length,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _getCatalogs() {
    UltraNetwork.request(
      context,
      getCatalogs,
      formData: FormData.fromMap(
        {"UserID": context.currentUser?.id},
      ),
      cancelToken: cancelToken,
    ).then((value) {
      isLoading = false;
      if (value != null) {
        setState(() {
          Catalog catalogsResponse = value;
          catalogs = catalogsResponse.data ?? [];
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  void _removeCatalog(String catalogId) {
    UltraNetwork.request(
      context,
      deleteCatalog,
      showError: false,
      showLoadingIndicator: false,
      formData: FormData.fromMap(
        {"CatalogeID": catalogId},
      ),
      cancelToken: cancelToken,
    ).then((value) {
      setState(() {});
    });
  }
}
