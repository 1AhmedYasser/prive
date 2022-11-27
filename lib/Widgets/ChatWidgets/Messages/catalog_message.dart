import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:prive/Resources/images.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Models/Catalogs/catalog.dart';
import 'package:prive/Models/Catalogs/catalogProduct.dart';
import 'package:prive/Screens/Catalogs/catalog_manager_screen.dart';
import 'package:prive/Screens/Catalogs/product_details_screen.dart';
import 'package:prive/Widgets/Common/cached_image.dart';

class CatalogMessage extends StatefulWidget {
  final BuildContext context;
  final Message details;
  const CatalogMessage({
    Key? key,
    required this.context,
    required this.details,
  }) : super(key: key);

  @override
  State<CatalogMessage> createState() => _CatalogMessageState();
}

class _CatalogMessageState extends State<CatalogMessage> {
  String? type;
  String? id;
  String? cid;
  String? name;
  String? description;
  String? price;
  String? owner;
  String? photo = '';
  String? photo2 = '';
  String? photo3 = '';
  @override
  void initState() {
    type = widget.details.attachments.first.extraData['ctype'] as String?;
    id = widget.details.attachments.first.extraData['id'] as String?;
    cid = widget.details.attachments.first.extraData['cid'] as String?;
    name = widget.details.attachments.first.extraData['name'] as String?;
    description = widget.details.attachments.first.extraData['description'] as String?;
    price = widget.details.attachments.first.extraData['price'] as String?;
    owner = widget.details.attachments.first.extraData['ownerId'] as String?;
    if (type == 'product') {
      photo = widget.details.attachments.first.extraData['photo1'] as String?;
      photo2 = widget.details.attachments.first.extraData['photo2'] as String?;
      photo3 = widget.details.attachments.first.extraData['photo3'] as String?;
    } else {
      photo = widget.details.attachments.first.extraData['photo'] as String?;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (type == 'product') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(
                product: CatalogProductData(
                  itemID: id,
                  itemName: name,
                  userID: owner,
                  description: description,
                  price: price,
                  photo1: photo,
                  photo2: photo2,
                  photo3: photo3,
                ),
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CatalogManagerScreen(
                catalog: CatalogData(
                  catalogeID: cid,
                  userID: owner,
                  catalogeName: name,
                  catalogePhoto: photo,
                ),
              ),
            ),
          );
        }
      },
      child: wrapAttachmentWidget(
        context,
        SizedBox(
          height: 240,
          width: type == 'product' ? 180 : 230,
          child: Column(
            children: [
              Expanded(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: photo != 'NONE'
                          ? CachedImage(
                              url: photo ?? '',
                            )
                          : Image.asset(Images.collectionsImage),
                    ),
                  ),
                ),
              ),
              Container(
                color: widget.details.user?.id == context.currentUser?.id
                    ? Colors.white.withOpacity(0.3)
                    : Colors.grey.shade400.withOpacity(0.3),
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12),
                  child: Column(
                    crossAxisAlignment: type == 'product' ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                        child: Text(
                          name ?? '',
                          style: TextStyle(
                            color: widget.details.user?.id == context.currentUser?.id ? Colors.white : Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (price != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            "$price ${"SAR".tr()}",
                            style: TextStyle(
                              color: widget.details.user?.id == context.currentUser?.id ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5, top: 5),
                child: Text(
                  'View',
                  style: TextStyle(
                    color: widget.details.user?.id == context.currentUser?.id ? Colors.white : Colors.black,
                    fontSize: 17,
                  ),
                ).tr(),
              ),
            ],
          ),
        ),
        const RoundedRectangleBorder(),
        true,
      ),
    );
  }
}
