import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:prive/Extras/resources.dart';

import '../../../Helpers/Utils.dart';

class NewCatalogCollectionWidget extends StatefulWidget {
  final String title;
  final String type;
  final bool isCatalog;
  final bool withImage;
  const NewCatalogCollectionWidget(
      {Key? key,
      this.title = "",
      this.type = "",
      this.isCatalog = true,
      this.withImage = true})
      : super(key: key);

  @override
  State<NewCatalogCollectionWidget> createState() =>
      _NewCatalogCollectionWidgetState();
}

class _NewCatalogCollectionWidgetState
    extends State<NewCatalogCollectionWidget> {
  TextEditingController catalogNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late File image = File("");
  final imagePicker = ImagePicker();

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
                controller: catalogNameController,
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
                        ? Padding(
                            padding: const EdgeInsets.all(19),
                            child: Image.asset(
                              R.images.newProductCameraImage,
                              fit: BoxFit.contain,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(20),
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
                    if (_formKey.currentState!.validate()) {}
                  },
                  child: Text(
                    "Create ${widget.type}",
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
}
