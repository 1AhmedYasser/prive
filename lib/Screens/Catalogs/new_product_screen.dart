import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prive/Extras/resources.dart';

import '../../Models/Catalogs/collection.dart';
import '../../Widgets/AppWidgets/prive_appbar.dart';

class NewProductScreen extends StatefulWidget {
  final CollectionData collection;
  const NewProductScreen({Key? key, required this.collection})
      : super(key: key);

  @override
  State<NewProductScreen> createState() => _NewProductScreenState();
}

class _NewProductScreenState extends State<NewProductScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController productNameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  List<File> productImages = [];

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
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Padding(
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
                                  padding: EdgeInsets.only(top: 10, bottom: 15),
                                  child: Text(
                                    "Add Images",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              ],
                            )
                          : Container(),
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
                      if (_formKey.currentState!.validate()) {}
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
}
