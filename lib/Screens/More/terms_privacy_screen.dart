import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TermsPrivacyScreen extends StatefulWidget {
  final bool isTerms;

  const TermsPrivacyScreen({Key? key, this.isTerms = true}) : super(key: key);

  @override
  _TermsPrivacyScreenState createState() => _TermsPrivacyScreenState();
}

class _TermsPrivacyScreenState extends State<TermsPrivacyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
        ),
        leading: const BackButton(
          color: Color(0xff7a8fa6),
        ),
        title: Text(
          widget.isTerms ? "Terms & Conditions" : "Privacy Policy",
          style: const TextStyle(
            fontSize: 23,
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: const SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 30),
            child: Text(
              "Terms and Conditions\nWelcome to Prive!\nThese terms and conditions outline the rules and regulations for the use of Prive's Website, located at www.Prive.com.By accessing this website we assume you accept these terms and conditions. Do not continue to use Prive if you do not agree to take all of the terms and conditions stated on this page.CookiesWe employ the use of cookies. By accessing Prive, you agreed to use cookies in agreement with the Prive's Privacy Policy.Most interactive websites use cookies to let us retrieve the user’s details for each visit. Cookies are used by our website to enable the functionality of certain areas to make it easier for people visiting our website. Some of our affiliate/advertising partners may also use cookies.LicenseUnless otherwise stated, Prive and/or its licensors own the intellectual property rights for all material on Prive. All intellectual property rights are reserved. You may access this from Prive for your own personal use subjected to restrictions set in these terms and conditions.You must not Republish material from PriveSell, rent or sub-license material from Prive ",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }
}
