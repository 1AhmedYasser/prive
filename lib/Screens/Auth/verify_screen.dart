import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:prive/Extras/resources.dart';

class VerifyAccountScreen extends StatefulWidget {
  final String phoneNumber;

  const VerifyAccountScreen({Key? key, this.phoneNumber = ""})
      : super(key: key);

  @override
  _VerifyAccountScreenState createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  TextEditingController codeController = TextEditingController();
  StreamController<ErrorAnimationType>? errorController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    errorController!.close();
    super.dispose();
  }

  snackBar(String? message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message!),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Verify",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 29),
              ),
              const SizedBox(height: 20),
              Text(
                "Please enter the 4 digits that has sent to your Mobile phone ${widget.phoneNumber}",
                style: const TextStyle(
                  color: Color(0xff5d5d63),
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
                  child: PinCodeTextField(
                    appContext: context,
                    pastedTextStyle: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                    length: 4,
                    blinkWhenObscuring: true,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      selectedColor: Theme.of(context).primaryColor,
                      selectedFillColor: Colors.white,
                      inactiveColor: Colors.white,
                      inactiveFillColor: Colors.white,
                      activeColor: Theme.of(context).primaryColor,
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(15),
                      fieldHeight: 80,
                      fieldWidth: 65,
                      activeFillColor: Colors.white,
                    ),
                    cursorColor: Colors.black,
                    animationDuration: const Duration(milliseconds: 300),
                    enableActiveFill: true,
                    errorAnimationController: errorController,
                    controller: codeController,
                    keyboardType: const TextInputType.numberWithOptions(
                        signed: true, decimal: false),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    boxShadows: const [
                      BoxShadow(
                        offset: Offset(0, 1),
                        color: Colors.black12,
                        blurRadius: 10,
                      )
                    ],
                    onChanged: (String value) {},
                    errorTextSpace: 30,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter Your Code'.tr();
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                   child: Row(
                        children: [
                             const Text(
                                '00:60',
                              style: TextStyle(
                                color: Color(0xff5d5d63),
                                fontSize: 16,
                                fontWeight: FontWeight.w400


                              ),
                            ),
                          
                        const Expanded(
                          child: SizedBox()),
                           TextButton(
                              onPressed: () {
                                // _resendCode();
                              },
                                  child: Text(
                                    "Resend Code".tr(),
                                    style: const TextStyle(
                                        color: Color(0xff1293a8),
                                        fontWeight: FontWeight.w400,
                                        fontSize: 17),
                                  ),
                                ),
        ]
                      ),
                    ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {},
                child: const Text(
                  "Verify Account",
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w400),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                  elevation: 0,
                  minimumSize: Size(
                    MediaQuery.of(context).size.width - 50,
                    50,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
                  ],
                ),
              ),
      ),
    );
  }
}
