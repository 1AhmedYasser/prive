import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prive/Models/Catalogs/catalog.dart';
import 'package:prive/Models/Catalogs/catalog_product.dart';
import 'package:prive/UltraNetwork/ultra_loading_indicator.dart';
import 'package:prive/Widgets/ChatWidgets/channel_item_widget.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class CatalogProductSenderScreen extends StatefulWidget {
  final CatalogData? catalog;
  final CatalogProductData? product;
  const CatalogProductSenderScreen({Key? key, this.catalog, this.product}) : super(key: key);

  @override
  State<CatalogProductSenderScreen> createState() => _CatalogProductSenderScreenState();
}

class _CatalogProductSenderScreenState extends State<CatalogProductSenderScreen> {
  bool isSelectedEnabled = false;
  List<Channel> selectedChannels = [];
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
        ),
        title: Text(
          'Send To'.tr(),
          style: const TextStyle(color: Colors.black),
        ),
        leading: const BackButton(
          color: Color(0xff7a8ea6),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: TextButton(
              style: ButtonStyle(
                overlayColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
              ),
              onPressed: () {
                setState(() {
                  isSelectedEnabled = !isSelectedEnabled;
                });
              },
              child: Text(
                isSelectedEnabled ? 'Unselect' : 'Select',
                style: const TextStyle(color: Colors.black, fontSize: 17),
              ).tr(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // SearchTextField(
          //   controller: searchController,
          //   showCloseButton: searchController.text.isNotEmpty ? true : false,
          //   onChanged: (value) {
          //     setState(() {});
          //   },
          // ),
          Expanded(
            child: StreamChannelListView(
              controller: StreamChannelListController(
                client: StreamChat.of(context).client,
                filter: Filter.and(
                  [
                    Filter.equal('type', 'messaging'),
                    Filter.in_(
                      'members',
                      [
                        StreamChatCore.of(context).currentUser!.id,
                      ],
                    ),
                    if (searchController.text.isNotEmpty) Filter.autoComplete('name', searchController.text)
                  ],
                ),
                channelStateSort: const [SortOption('last_message_at')],
                presence: true,
                limit: 20,
              ),
              emptyBuilder: (context) => const SizedBox.shrink(),
              separatorBuilder: (context, channels, index) => const SizedBox.shrink(),
              errorBuilder: (context, error) => Center(
                child: Text(
                  'Error: $error',
                  textAlign: TextAlign.center,
                ),
              ),
              loadingBuilder: (context) => const UltraLoadingIndicator(),
              itemBuilder: (context, channels, index, tile) {
                // print(channel.createdBy?.name);
                // if (channel.name == null) {
                //   print(
                //       "Channel Name: ${channel.state?.members.firstWhere((element) => element.userId != StreamChatCore.of(context).currentUser?.id).user?.name}");
                // } else {
                //   print("Channel Name: ${channel.name}");
                // }
                return InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    if (isSelectedEnabled) {
                      setState(() {
                        if (selectedChannels.contains(channels[index])) {
                          selectedChannels.remove(channels[index]);
                        } else {
                          selectedChannels.add(channels[index]);
                        }
                      });
                    } else {
                      if (widget.product != null) {
                        channels[index].sendMessage(
                          Message(
                            text: '',
                            type: 'product',
                            attachments: [
                              Attachment(
                                type: 'product',
                                uploadState: const UploadState.success(),
                                title: widget.product?.itemName,
                                imageUrl: widget.product?.photo1,
                                extraData: {
                                  'id': widget.product?.itemID,
                                  'name': widget.product?.itemName,
                                  'description': widget.product?.description,
                                  'price': widget.product?.price,
                                  'photo1': widget.product?.photo1,
                                  'photo2': widget.product?.photo2,
                                  'photo3': widget.product?.photo3,
                                  'ownerId': widget.product?.userID,
                                  'ctype': 'product'
                                },
                              )
                            ],
                          ),
                        );
                      } else if (widget.catalog != null) {
                        channels[index].sendMessage(
                          Message(
                            text: '',
                            type: 'catalog',
                            attachments: [
                              Attachment(
                                type: 'catalog',
                                title: widget.catalog?.catalogeName,
                                imageUrl: widget.catalog?.catalogePhoto,
                                thumbUrl: widget.catalog?.catalogePhoto,
                                uploadState: const UploadState.success(),
                                extraData: {
                                  'cid': widget.catalog?.catalogeID,
                                  'name': widget.catalog?.catalogeName,
                                  'photo': widget.catalog?.catalogePhoto,
                                  'ownerId': widget.catalog?.userID,
                                  'ctype': 'catalog'
                                },
                              ),
                            ],
                          ),
                        );
                      }

                      Navigator.pop(context);
                    }
                  },
                  child: isSelectedEnabled
                      ? Row(
                          children: [
                            Expanded(
                              child: ChannelItemWidget(
                                channel: channels[index],
                                isForward: true,
                              ),
                            ),
                            IgnorePointer(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 23, right: 10),
                                child: Checkbox(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  value: selectedChannels.contains(channels[index]) ? true : false,
                                  onChanged: (value) {},
                                ),
                              ),
                            )
                          ],
                        )
                      : ChannelItemWidget(
                          channel: channels[index],
                          isForward: true,
                        ),
                );
              },
            ),
          ),
          if (isSelectedEnabled)
            Padding(
              padding: const EdgeInsets.only(bottom: 45),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: selectedChannels.isNotEmpty ? Theme.of(context).primaryColorDark : Colors.grey,
                  elevation: 0,
                  minimumSize: Size(MediaQuery.of(context).size.width - 100, 50),
                ),
                onPressed: () {
                  if (selectedChannels.isNotEmpty) {
                    for (var channel in selectedChannels) {
                      if (widget.product != null) {
                        channel.sendMessage(
                          Message(
                            text: '',
                            type: 'product',
                            attachments: [
                              Attachment(
                                type: 'product',
                                uploadState: const UploadState.success(),
                                title: widget.product?.itemName,
                                imageUrl: widget.product?.photo1,
                                extraData: {
                                  'id': widget.product?.itemID,
                                  'name': widget.product?.itemName,
                                  'description': widget.product?.description,
                                  'price': widget.product?.price,
                                  'photo1': widget.product?.photo1,
                                  'photo2': widget.product?.photo2,
                                  'photo3': widget.product?.photo3,
                                  'ownerId': widget.product?.userID,
                                  'ctype': 'product'
                                },
                              )
                            ],
                          ),
                        );
                      } else if (widget.catalog != null) {
                        channel.sendMessage(
                          Message(
                            text: '',
                            type: 'catalog',
                            attachments: [
                              Attachment(
                                type: 'catalog',
                                uploadState: const UploadState.success(),
                                title: widget.catalog?.catalogeName,
                                imageUrl: widget.catalog?.catalogePhoto,
                                thumbUrl: widget.catalog?.catalogePhoto,
                                extraData: {
                                  'cid': widget.catalog?.catalogeID,
                                  'name': widget.catalog?.catalogeName,
                                  'photo': widget.catalog?.catalogePhoto,
                                  'ownerId': widget.catalog?.userID,
                                  'ctype': 'catalog'
                                },
                              )
                            ],
                          ),
                        );
                      }
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  'Forward'.tr(),
                  style: const TextStyle(
                    fontSize: 17.5,
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
