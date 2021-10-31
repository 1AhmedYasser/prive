import 'package:bot_toast/bot_toast.dart';
import 'package:country_calling_code_picker/country.dart';
import 'package:country_calling_code_picker/functions.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Helpers/utils.dart';
import 'package:prive/Models/login.dart';
import 'package:prive/Screens/Auth/verify_screen.dart';
import 'package:prive/UltraNetwork/ultra_constants.dart';
import 'dart:io';

import 'package:prive/UltraNetwork/ultra_network.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isPhoneNumberValid = false;
  String phoneNumber = "";
  String countryName = "";
  TextEditingController phoneController = TextEditingController();
  CancelToken cancelToken = CancelToken();
  bool loading = false;

  PhoneNumber initialNumber =
      PhoneNumber(isoCode: Platform.localeName.split('_').last);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Phone Number',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                'Please confirm your country code and enter your phone number',
                style: TextStyle(
                  fontSize: 17,
                  color: Color(0xff5d5d63),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              InternationalPhoneNumberInput(
                initialValue: initialNumber,
                onInputChanged: (PhoneNumber number) async {
                  phoneNumber = number.phoneNumber.toString();
                  Country? country = await getCountryByCountryCode(
                      context, number.isoCode ?? "EG");
                  countryName = country?.name ?? "United States";
                },
                onInputValidated: (valid) {
                  isPhoneNumberValid = valid;
                },
                validator: (value) {
                  if (!isPhoneNumberValid) {
                    return "Enter A Valid Phone Number";
                  }
                  return null;
                },
                selectorConfig: const SelectorConfig(
                  selectorType: PhoneInputSelectorType.DROPDOWN,
                  setSelectorButtonAsPrefixIcon: true,
                  trailingSpace: false,
                ),
                ignoreBlank: false,
                inputDecoration: InputDecoration(
                  hintText: "Phone Number",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  errorBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                autoValidateMode: AutovalidateMode.disabled,
                selectorTextStyle: const TextStyle(color: Colors.black),
                textFieldController: phoneController,
                formatInput: true,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (loading == false) {
                      loading = true;
                      UltraNetwork.request(
                        context,
                        login,
                        cancelToken: cancelToken,
                        formData: FormData.fromMap({
                          "UserPhone": phoneNumber,
                          "FirebaseToken":
                          await Utils.getString(R.pref.firebaseToken),
                          "Country": countryName
                        }),
                      ).then((value) {
                        loading = false;
                        Login login = value;
                        if (login.success == true) {
                          LoginData? loginData = value.data?[0];
                          Utils.saveString(R.pref.token, loginData?.token ?? "");
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  VerifyAccountScreen(
                                    phoneNumber: phoneNumber,
                                    loginData: loginData,
                                  ),
                            ),
                          );
                        }
                      });
                    }
                  }
                },
                child: const Text(
                  "Next",
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

  @override
  void dispose() {
    BotToast.removeAll();
    super.dispose();
  }
}
