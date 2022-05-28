import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Models/Catalogs/catalog.dart';
import 'package:prive/Models/Catalogs/collection.dart';
import 'package:prive/UltraNetwork/ultra_constants.dart';
import 'package:prive/Widgets/Common/cached_image.dart';
import '../../../Helpers/Utils.dart';
import '../../../UltraNetwork/ultra_network.dart';
import 'package:prive/Helpers/stream_manager.dart';

class NewCatalogCollectionWidget extends StatefulWidget {
  final String title;
  final String type;
  final bool isCatalog;
  final bool withImage;
  final String? catalogId;
  final CatalogData? catalog;
  final CollectionData? collection;
  final bool isEdit;
  const NewCatalogCollectionWidget({
    Key? key,
    this.title = "",
    this.type = "",
    this.isCatalog = true,
    this.withImage = true,
    this.catalogId,
    this.catalog,
    this.collection,
    this.isEdit = false,
  }) : super(key: key);

  @override
  State<NewCatalogCollectionWidget> createState() =>
      _NewCatalogCollectionWidgetState();
}

class _NewCatalogCollectionWidgetState
    extends State<NewCatalogCollectionWidget> {
  TextEditingController nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late File image = File("");
  final imagePicker = ImagePicker();
  CancelToken cancelToken = CancelToken();

  @override
  void initState() {
    if (widget.catalog != null) {
      nameController.text = widget.catalog?.catalogeName ?? "";
    } else if (widget.collection != null) {
      nameController.text = widget.collection?.collectionName ?? "";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25),
          topLeft: Radius.circular(25),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 35, bottom: 25),
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                "What Will Be Your ${widget.type} Name ?",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                keyboardType: TextInputType.text,
                cursorColor: const Color(0xff777777),
                decoration: InputDecoration(
                  hintText: "${widget.type} Name",
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 23, vertical: 10),
                  labelStyle: const TextStyle(
                    color: Color(0xff777777),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(12),
                    ),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(12),
                    ),
                    borderSide: BorderSide(
                        color: Theme.of(context).primaryColor, width: 2),
                  ),
                  errorBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                    borderSide: BorderSide(color: Colors.red, width: 2),
                  ),
                  focusedErrorBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                    borderSide: BorderSide(color: Colors.red, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter A ${widget.type} Name';
                  }
                  return null;
                },
              ),
              if (widget.withImage)
                Padding(
                  padding: const EdgeInsets.only(top: 25, bottom: 20),
                  child: Text(
                    "Select a ${widget.type} Image (Optional)",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (widget.withImage)
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    Utils.showImagePickerSelector(context, getImage);
                  },
                  child: Container(
                    width: 85,
                    height: 85,
                    child: image.path.isEmpty
                        ? widget.catalog?.catalogePhoto == "NONE" ||
                                widget.catalog == null
                            ? Padding(
                                padding: const EdgeInsets.all(15),
                                child: Image.asset(
                                  R.images.newProductCameraImage,
                                  fit: BoxFit.contain,
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: CachedImage(
                                  url: widget.catalog?.catalogePhoto ?? "",
                                ),
                              )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(
                              image,
                              fit: BoxFit.fill,
                            ),
                          ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade500.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 50),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (widget.isCatalog) {
                        if (!widget.isEdit) {
                          _createCatalog();
                        } else {
                          _updateCatalog(widget.catalog?.catalogeID ?? "");
                        }
                      } else {
                        if (widget.isEdit) {
                          _updateCollection(widget.catalogId ?? "",
                              widget.collection?.collectionID ?? "");
                        } else {
                          _createCollection(widget.catalogId ?? "");
                        }
                      }
                    }
                  },
                  child: Text(
                    "${widget.isEdit ? "Edit" : "Create"} ${widget.type}",
                    style: const TextStyle(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future getImage(ImageSource source, bool isVideo) async {
    Navigator.of(context).pop();
    final pickedFile = await imagePicker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
      }
    });
  }

  Future<void> _createCatalog() async {
    Map<String, dynamic> parameters = {
      "UserID": context.currentUser?.id,
      "CatalogeName": nameController.text
    };

    if (image.path.isNotEmpty) {
      parameters["CatalogePhoto"] =
          await MultipartFile.fromFile(image.path, filename: "CatalogePhoto");
    }

    UltraNetwork.request(
      context,
      addCatalog,
      formData: FormData.fromMap(
        parameters,
      ),
      cancelToken: cancelToken,
    ).then((value) {
      if (value != null) {
        Navigator.pop(context, true);
      }
    });
  }

  Future<void> _updateCatalog(String catalogId) async {
    Map<String, dynamic> parameters = {
      "CatalogeID": catalogId,
      "CatalogeName": nameController.text
    };

    if (image.path.isNotEmpty) {
      parameters["CatalogePhoto"] =
          await MultipartFile.fromFile(image.path, filename: "CatalogePhoto");
    }

    UltraNetwork.request(
      context,
      updateCatalog,
      formData: FormData.fromMap(
        parameters,
      ),
      cancelToken: cancelToken,
    ).then((value) {
      if (value != null) {
        Navigator.pop(context, true);
      }
    });
  }

  void _createCollection(String catalogId) async {
    Map<String, dynamic> parameters = {
      "UserID": context.currentUser?.id,
      "CatalogeID": catalogId,
      "CollectionName": nameController.text
    };

    if (image.path.isNotEmpty) {
      parameters["CollectionPhoto"] =
          await MultipartFile.fromFile(image.path, filename: "CollectionPhoto");
    }

    UltraNetwork.request(
      context,
      addCollection,
      formData: FormData.fromMap(
        parameters,
      ),
      cancelToken: cancelToken,
    ).then((value) {
      if (value != null) {
        Navigator.pop(context, true);
      }
    });
  }

  Future<void> _updateCollection(String catalogId, String collectionId) async {
    Map<String, dynamic> parameters = {
      "CatalogeID": catalogId,
      "CollectionID": collectionId,
      "CollectionName": nameController.text
    };

    if (image.path.isNotEmpty) {
      parameters["CollectionPhoto"] =
          await MultipartFile.fromFile(image.path, filename: "CollectionPhoto");
    }

    UltraNetwork.request(
      context,
      updateCollection,
      formData: FormData.fromMap(
        parameters,
      ),
      cancelToken: cancelToken,
    ).then((value) {
      if (value != null) {
        Navigator.pop(context, true);
      }
    });
  }
}
