import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/UltraNetwork/ultra_constants.dart';
import '../../Helpers/Utils.dart';
import '../../Models/Catalogs/catalogProduct.dart';
import '../../Models/Catalogs/collection.dart';
import '../../UltraNetwork/ultra_network.dart';
import '../../Widgets/AppWidgets/prive_appbar.dart';

class NewProductScreen extends StatefulWidget {
  final CollectionData collection;
  final CatalogProductData? product;
  final bool isEdit;
  const NewProductScreen(
      {Key? key, required this.collection, this.product, this.isEdit = false})
      : super(key: key);

  @override
  State<NewProductScreen> createState() => _NewProductScreenState();
}

class _NewProductScreenState extends State<NewProductScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController productNameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final imagePicker = ImagePicker();
  List<File> productImages = [];
  CancelToken cancelToken = CancelToken();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 60),
        child: const PriveAppBar(title: "Add Products Or Services"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 130,
              child: ListView.builder(
                itemCount: 4,
                itemBuilder: (context, index) {
                  return InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      if (index == 0) {
                        Utils.showImagePickerSelector(context, getImage);
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: 15, left: index == 0 ? 25 : 0, right: 13),
                      child: Container(
                        decoration: BoxDecoration(
                          color: index == 0
                              ? const Color(0xff7a8fa6)
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: 130,
                        height: 50,
                        child: index == 0
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 20),
                                      child: Image.asset(
                                        R.images.newProductCameraImage,
                                        width: 60,
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.only(top: 10, bottom: 15),
                                    child: Text(
                                      "Add Images",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                ],
                              )
                            : productImages.length > index - 1
                                ? Stack(
                                    children: [
                                      Positioned.fill(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.file(
                                            productImages[index - 1],
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 5,
                                        right: 7,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              productImages.removeAt(index - 1);
                                            });
                                          },
                                          child: const Icon(
                                            Icons.remove_circle_outlined,
                                            color: Colors.red,
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                : const SizedBox(),
                      ),
                    ),
                  );
                },
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25, right: 25, top: 35),
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: buildTextField(
                      "Product Or Service Name",
                      productNameController,
                      emptyValidatorMessage:
                          "Please enter a product or service name",
                    ),
                  ),
                  const SizedBox(height: 20),
                  buildTextField(
                    "Price (Optional)",
                    priceController,
                    emptyValidatorMessage: "Please enter a product price",
                  ),
                  const SizedBox(height: 20),
                  buildTextField(
                    "Description (Optional)",
                    descriptionController,
                    maxLines: 4,
                    emptyValidatorMessage: "Please enter a product description",
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (widget.isEdit) {
                        } else {
                          _createProduct();
                        }
                      }
                    },
                    child: const Text(
                      "Save",
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
                  const SizedBox(height: 25),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String hint, TextEditingController controller,
      {int maxLines = 1,
      TextInputType type = TextInputType.text,
      List<TextInputFormatter> formatters = const [],
      String emptyValidatorMessage = ""}) {
    return TextFormField(
      maxLines: maxLines,
      controller: controller,
      keyboardType: type,
      inputFormatters: formatters,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        hintText: hint,
        filled: true,
        fillColor: Colors.white30,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 15,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return emptyValidatorMessage;
        }
        return null;
      },
    );
  }

  Future getImage(ImageSource source, bool isVideo) async {
    Navigator.of(context).pop();
    final pickedFile = await imagePicker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        if (productImages.length < 3) {
          setState(() {
            productImages.add(File(pickedFile.path));
          });
        }
      }
    });
  }

  void _createProduct() async {
    Map<String, dynamic> parameters = {
      "UserID": context.currentUser?.id,
      "ItemName": productNameController.text,
      "CollectionID": widget.collection.collectionID ?? "",
      "Price": priceController.text,
      "Description": descriptionController.text
    };

    if (productImages.isNotEmpty) {
      parameters["Photo1"] = await MultipartFile.fromFile(productImages[0].path,
          filename: "Photo1");
    }

    if (productImages.length >= 2) {
      parameters["Photo2"] = await MultipartFile.fromFile(productImages[1].path,
          filename: "Photo2");
    }

    if (productImages.length >= 3) {
      parameters["Photo3"] = await MultipartFile.fromFile(productImages[2].path,
          filename: "Photo3");
    }

    UltraNetwork.request(
      context,
      addProduct,
      formData: FormData.fromMap(
        parameters,
      ),
      cancelToken: cancelToken,
    ).then((value) {
      if (value != null) {
        Utils.showAlert(
          context,
          message: "Product Added To ${widget.collection.collectionName}",
        ).then((value) => Navigator.pop(context, true));
      }
    });
  }
}
