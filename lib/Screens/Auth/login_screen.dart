import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:prive/Extras/resources.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String phoneNumber = "";
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
      body: Padding(
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
            const SizedBox(height: 15,),
            const Text(
                'Please confirm your country code and enter your \n phone number',
              style: TextStyle(
                fontSize: 17,
                color: Color(0xff5d5d63),
              ),
            ),
            const SizedBox(height: 20,),
            IntlPhoneField(
              iconPosition: IconPosition.trailing,
              keyboardType: const TextInputType.numberWithOptions(
                  signed: true, decimal: true),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(

                hintText:  "Mobile Number",
                labelStyle: const TextStyle(color: Color(0xff777777)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    style: BorderStyle.solid,
                      color: Theme.of(context).primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (phone) {
                phoneNumber = phone.completeNumber;
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, R.routes.verifyAccountRoute),
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
    );
  }
}
