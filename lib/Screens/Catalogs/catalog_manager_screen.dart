import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:prive/Widgets/Common/cached_image.dart';

import '../../Extras/resources.dart';
import '../../Widgets/AppWidgets/Catalogs/new_catalog_collection_widget.dart';

class CatalogManagerScreen extends StatefulWidget {
  const CatalogManagerScreen({Key? key}) : super(key: key);

  @override
  State<CatalogManagerScreen> createState() => _CatalogManagerScreenState();
}

class _CatalogManagerScreenState extends State<CatalogManagerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
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
                  const Flexible(
                    flex: 1,
                    child: Text(
                      "Food",
                      textAlign: TextAlign.center,
                      style: TextStyle(
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
                child: const CachedImage(
                  url:
                      "https://ddragon.leagueoflegends.com/cdn/img/champion/splash/Annie_22.jpg",
                ),
              ),
            ),
          ),
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
                    child: const NewCatalogCollectionWidget(
                      title: "Create New Catalog",
                      type: "Catalog",
                      withImage: false,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 20, bottom: 10, left: 13, right: 13),
                child: Row(
                  children: [
                    Image.asset(
                      R.images.newCollectionGroupImage,
                      fit: BoxFit.fill,
                      width: 70,
                    ),
                    const SizedBox(width: 17),
                    Text(
                      "Add New Collection",
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
              (context, index) {
                return Column(
                  children: [
                    ListTile(
                      title: const Text(
                        'Italian',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        "9 Items",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: TextButton(
                        onPressed: () {},
                        child: Text(
                          "See All",
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                      ),
                    ),
                    MediaQuery.removePadding(
                      child: ListView.separated(
                        itemBuilder: (context, index) {
                          return Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 13, right: 13),
                                child: SizedBox(
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: const CachedImage(
                                            url:
                                                "https://images.pexels.com/photos/396547/pexels-photo-396547.jpeg?auto=compress&cs=tinysrgb&h=350",
                                          ),
                                        ),
                                      ),
                                      if (index % 2 != 0)
                                        Positioned.fill(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Container(
                                              color: Colors.black.withOpacity(
                                                0.2,
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(27),
                                                child: Image.asset(
                                                  R.images.hiddenProduct,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  width: 90,
                                  height: 90,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Handmade Bag",
                                    style: TextStyle(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(top: 3.5, bottom: 3.5),
                                    child: Text(
                                      "Awsome Hand Bag",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xff5d5d63),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "60 SAR",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff5d5d63),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          );
                        },
                        shrinkWrap: true,
                        itemCount: 3,
                        physics: const NeverScrollableScrollPhysics(),
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(height: 20);
                        },
                      ),
                      context: context,
                      removeTop: true,
                      removeBottom: true,
                    )
                  ],
                );
              },
              childCount: 2,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 40),
          )
        ],
      ),
    );
  }
}
