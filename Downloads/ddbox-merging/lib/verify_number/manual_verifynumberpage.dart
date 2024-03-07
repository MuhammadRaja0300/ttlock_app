import 'dart:convert';
import 'dart:math';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:ddbox/helper_services/back_press_helper.dart';
import 'package:ddbox/helper_services/twilio_helper.dart';
import 'package:ddbox/login/loginpage.dart';
import 'package:ddbox/maps/maps_manual.dart';
import 'package:ddbox/models/loading.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class VerifyNumberPage extends StatefulWidget {
  const VerifyNumberPage({super.key});

  @override
  State<VerifyNumberPage> createState() => _VerifyNumberPageState();
}

class _VerifyNumberPageState extends State<VerifyNumberPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  var fno;
  String? completeMobileNo;
  String randomOTP = '';
  TextEditingController _otpController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  late String selectedCountryCode;
  String verificationId = "";
  String? smsCode;

  @override
  void initState() {
    super.initState();
    selectedCountryCode = '+971';
  }
  Future<bool> _onBackPressed(BuildContext context) async {
    return await ExitConfirmationDialog.replaceBack(context, LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        return _onBackPressed(context);
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CountryCodePicker(
                            onChanged: (CountryCode code) {
                              setState(() {
                                selectedCountryCode = code.dialCode!;
                              });
                            },
                            initialSelection: 'AE',
                            // Initial country selection
                            favorite: ['+971', 'AE'],
                            // Favorite countries
                            showCountryOnly: false,
                            showOnlyCountryWhenClosed: true,
                            alignLeft: false,
                            showDropDownButton: true,
                            searchDecoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Color(0xFF17C3CE), width: 2.0),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextFormField(
                          controller: _mobileController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Mobile Number',
                            prefixText: selectedCountryCode,
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color(0xFF17C3CE), width: 2.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Enter Mobile Number';
                            }
                            return null;
                          },
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.all(10.0),
                      //   child: InternationalPhoneNumberInput(
                      //     onInputChanged: (PhoneNumber phoneNumber) {
                      //       _phoneNumber = phoneNumber;
                      //     },
                      //     selectorConfig: const SelectorConfig(
                      //       selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                      //
                      //     ),
                      //     ignoreBlank: false,
                      //     autoValidateMode: AutovalidateMode.onUserInteraction,
                      //     selectorTextStyle: const TextStyle(color: Colors.black),
                      //     inputDecoration: const InputDecoration(
                      //       border: OutlineInputBorder(),
                      //       hintText: 'Enter your phone number',
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(height: 20),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0),
                        // Space from the sides
                        width: double.infinity,
                        // Full width
                        height: 60.0,
                        child: FilledButton(
                          style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Color(0xFF17C3CE)),
                          ),
                          onPressed: _validateAndSubmit,
                          child: const Text('Send OTP'),
                        ),
                      ),
                      // ElevatedButton(
                      //   onPressed: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(builder: (context) => const SignupPage()),
                      //     );
                      //     //_verifyPhoneNumber('+923008175646'); // Replace with the user's phone number
                      //   },
                      //   child: const Text('go to signup'),
                      // ),
                      Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Enter OTP',
                            hintText: 'Enter OTP Code',
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color(0xFF17C3CE), width: 2.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onChanged: (value) {
                            smsCode = value;
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0),
                        // Space from the sides
                        width: double.infinity,
                        // Full width
                        height: 60.0,
                        child: FilledButton(
                          style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Color(0xFF17C3CE)),
                          ),
                          onPressed: () {
                            String enteredOTP =
                                _otpController.text.toString().trim();
                            if (enteredOTP!.isEmpty) {
                              _showSnackbar('Enter OTP');
                            } else if (enteredOTP == randomOTP) {
                              LoadingUtil.hideLoading(context);
                              saveMobileNoInPref(completeMobileNo.toString());
                              _showSnackbar('OTP Matched ');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MapPageManual()),
                              );
                            } else {
                              _showSnackbar('Invalid OTP');
                            }
                          },
                          child: const Text('Submit'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void sendOTP(String phoneNumber, String randomOTP) {
    TwilioHelper twilioHelper = TwilioHelper();
    twilioHelper.sendOtpRequest(
      phoneNumber: phoneNumber,
      otp: randomOTP,
      onSuccess: (message) {
        _showSnackbar(message);
        LoadingUtil.hideLoading(context);
      },
      onFailure: (error) {
        _showSnackbar('${error}');
        LoadingUtil.hideLoading(context);
      },
    );
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  //OTP functions
  Future<bool> checkIfMobileNumberExists(String phoneNumber) async {
    final FirebaseDatabase _database = FirebaseDatabase.instance;
    try {
      // Check if the mobile number already exists in the Realtime Database
      DatabaseEvent snapshot = await _database
          .ref()
          .child('users')
          .child('users_details')
          .orderByChild('mobile_no')
          .equalTo(phoneNumber)
          .once();

      return snapshot.snapshot.value != null;
    } catch (error) {
      print('Error checking mobile number: $error');
      return false;
    }
  }

  void _validateAndSubmit() async {
    LoadingUtil.showLoading(context);
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      String e164PhoneNumber =
          '${selectedCountryCode.trim()}${_mobileController.text.trim()}';
      completeMobileNo =
          '${selectedCountryCode.trim()}${_mobileController.text.trim()}';
      print('iscode ===? ${selectedCountryCode.trim()}');
      print('mobile no===>${_mobileController.text.trim()}');
      //_verifyPhoneNumber(e164PhoneNumber);

      randomOTP = (100000 + Random().nextInt(899999)).toString();
      LoadingUtil.hideLoading(context);
      _showOtpDialog(randomOTP);
      //sendOTP(e164PhoneNumber, randomOTP);
    }
  }

  //Convert string to E146 format

  void _verifyPhoneNumber(String phoneNumber) async {
    bool mobileNumberExists = await checkIfMobileNumberExists(
        phoneNumber); // Implement this function to check mobile number existence.

    if (mobileNumberExists == true) {
      // Mobile number already exists, show a message and do not proceed with OTP verification.
      print('Mobile number already exists. Cannot send OTP.');
      _showSnackbar('Mobile number already exists. Cannot send OTP.');
    } else {
      //sendOTP(phoneNumber);
    }
  }

  //submit sms code
  void _submitSmsCode(String smsCode) async {
    LoadingUtil.showLoading(context);
    final SharedPreferences prefs = await _prefs;

    try {} catch (e) {
      LoadingUtil.hideLoading(context);
      print("Error: $e");
      //_showSnackbar("$e");
    }
  }

  void _showSnackbar(String msg) {
    final snackbar = SnackBar(
      content: Text('$msg'),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  static Future<void> clearPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> saveMobileNoInPref(String value) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('mobileNumber', value);
  }

  Future<void> _showOtpDialog(String otp) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('OTP'),
          content: Text('$otp is your verification code for MyDrop'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _otpController.text = otp.toString();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
