import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/Helpers/utils.dart';
import 'package:prive/Models/Auth/login.dart';
import 'package:prive/Screens/Auth/signup_screen.dart';
import 'package:timer_count_down/timer_count_down.dart';
import '../../UltraNetwork/ultra_loading_indicator.dart';

class VerifyAccountScreen extends StatefulWidget {
  final String phoneNumber;
  final LoginData? loginData;

  const VerifyAccountScreen({Key? key, this.phoneNumber = "", this.loginData}) : super(key: key);

  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? verificationId;
  TextEditingController codeController = TextEditingController();
  StreamController<ErrorAnimationType>? errorController;
  final _formKey = GlobalKey<FormState>();
  bool isTimerOn = true;

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    phoneSignIn();
    super.initState();
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
        leading: const BackButton(
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Verify".tr(),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 29),
              ),
              const SizedBox(height: 20),
              Text(
                "${"Please enter the 6 digits that has sent to your Mobile phone".tr()} ${widget.phoneNumber}",
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
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
                  child: PinCodeTextField(
                    appContext: context,
                    pastedTextStyle: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                    length: 6,
                    blinkWhenObscuring: true,
                    animationType: AnimationType.fade,
                    mainAxisAlignment: MainAxisAlignment.center,
                    pinTheme: PinTheme(
                      selectedColor: Theme.of(context).primaryColor,
                      selectedFillColor: Colors.white,
                      inactiveColor: Colors.white,
                      inactiveFillColor: Colors.white,
                      activeColor: Theme.of(context).primaryColor,
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(15),
                      fieldHeight: MediaQuery.of(context).size.height * 0.075,
                      fieldWidth: MediaQuery.of(context).size.width * 0.104,
                      activeFillColor: Colors.white,
                      fieldOuterPadding: const EdgeInsets.all(5),
                    ),
                    cursorColor: Colors.black,
                    animationDuration: const Duration(milliseconds: 300),
                    enableActiveFill: true,
                    errorAnimationController: errorController,
                    controller: codeController,
                    keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: false),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    boxShadows: const [
                      BoxShadow(
                        offset: Offset(0, 1),
                        color: Colors.black12,
                        blurRadius: 5,
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
                    if (isTimerOn)
                      Countdown(
                        seconds: 60,
                        build: (BuildContext context, double time) => Text(
                          time.toInt().toString(),
                          style: const TextStyle(
                            color: Color(0xff5d5d63),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        interval: const Duration(milliseconds: 100),
                        onFinished: () {
                          setState(() {
                            isTimerOn = false;
                          });
                        },
                      ),
                    const Expanded(child: SizedBox()),
                    TextButton(
                      onPressed: () {
                        if (isTimerOn == false) {
                          phoneSignIn();
                          setState(() {
                            isTimerOn = true;
                          });
                        }
                      },
                      style: TextButton.styleFrom(shadowColor: Colors.transparent),
                      child: Text(
                        "Resend Code".tr(),
                        style: TextStyle(
                          color: isTimerOn ? Colors.grey : const Color(0xff1293a8),
                          fontWeight: FontWeight.w400,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    BotToast.showAnimationWidget(
                        toastBuilder: (context) {
                          return const IgnorePointer(child: UltraLoadingIndicator());
                        },
                        animationDuration: const Duration(milliseconds: 0),
                        groupKey: "loading");
                    PhoneAuthCredential credential = PhoneAuthProvider.credential(
                      verificationId: verificationId ?? "",
                      smsCode: codeController.text,
                    );
                    await _auth.signInWithCredential(credential).then((value) {
                      BotToast.removeAll("loading");
                      if (widget.loginData?.accountState == "NewAccount") {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUpScreen(
                              phoneNumber: widget.phoneNumber,
                              loginData: widget.loginData,
                            ),
                          ),
                        );
                      } else {
                        StreamManager.connectUserToStream(this.context).then((value) {
                          Navigator.pushNamedAndRemoveUntil(
                              this.context, R.routes.navigatorRoute, (Route<dynamic> route) => false);
                          Utils.saveBool(R.pref.isLoggedIn, true);
                        });
                      }
                    }).catchError((error) {
                      Utils.showAlert(context,
                          message: "You Entered An Invalid Code".tr(), alertImage: R.images.alertInfoImage);
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  elevation: 0,
                  minimumSize: Size(
                    MediaQuery.of(context).size.width - 50,
                    50,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Verify Account".tr(),
                  style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> phoneSignIn() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: _onVerificationCompleted,
      verificationFailed: _onVerificationFailed,
      codeSent: _onCodeSent,
      codeAutoRetrievalTimeout: _onCodeTimeout,
    );
  }

  _onVerificationCompleted(PhoneAuthCredential authCredential) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (authCredential.smsCode != null) {
      print(authCredential.smsCode);
      try {
        await user!.linkWithCredential(authCredential);
      } on FirebaseAuthException catch (_) {
        await _auth.signInWithCredential(authCredential);
      }
    }
  }

  _onVerificationFailed(FirebaseAuthException exception) {
    if (exception.code == 'invalid-phone-number') {
      print("The phone number entered is invalid!");
    }
  }

  _onCodeSent(String verificationId, int? forceResendingToken) {
    this.verificationId = verificationId;
    print("Code Sent");
  }

  _onCodeTimeout(String timeout) {
    print("code timeout");
  }

  @override
  void dispose() {
    BotToast.removeAll("loading");
    errorController!.close();
    super.dispose();
  }
}
