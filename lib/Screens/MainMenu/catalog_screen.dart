import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Screens/Catalogs/catalog_manager_screen.dart';
import 'package:prive/Widgets/AppWidgets/Catalogs/new_catalog_collection_widget.dart';
import '../../Widgets/AppWidgets/prive_appbar.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({Key? key}) : super(key: key);

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  List<String> catalogs = ["Food", "Cool"];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 60),
        child: PriveAppBar(
            title: catalogs.isEmpty ? "Create A Catalog" : "Catalogs"),
      ),
      body: catalogs.isEmpty
          ? SizedBox(
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
                  ),
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
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 28, right: 28, top: 45),
                    child: ElevatedButton(
                      onPressed: () {
                        showMaterialModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) => SingleChildScrollView(
                            controller: ModalScrollController.of(context),
                            child: const NewCatalogCollectionWidget(
                              title: "Create New Catalog",
                              type: "Catalog",
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "Create Catalog",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColor,
                        minimumSize:
                            Size(MediaQuery.of(context).size.width, 55),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
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
                    showMaterialModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) => SingleChildScrollView(
                        controller: ModalScrollController.of(context),
                        child: const NewCatalogCollectionWidget(
                          title: "Create New Catalog",
                          type: "Catalog",
                        ),
                      ),
                    );
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
                        ),
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
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const CatalogManagerScreen(),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    child: ListTile(
                                      leading: Image.asset(
                                        R.images.collectionsImage,
                                        fit: BoxFit.fill,
                                        height: 52,
                                        width: 73,
                                      ),
                                      title: Text(
                                        catalogs[index],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ),
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
                )
              ],
            ),
    );
  }
}
