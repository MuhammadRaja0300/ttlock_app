import 'package:ddbox/models/loading.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import 'package:firebase_auth/firebase_auth.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  //Forgot password
  final FirebaseAuth _auth = FirebaseAuth.instance;
  PhoneNumber? _phoneNumber;
  final TextEditingController _emailController = TextEditingController();

  // Future<void> _sendPasswordResetSms() async {
  //   if (_phoneNumber == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Please enter a valid phone number.'),
  //       ),
  //     );
  //     return;
  //   }
  //
  //   try {
  //     await _auth.verifyPhoneNumber(
  //       phoneNumber: _phoneNumber!.phoneNumber!,
  //       timeout: const Duration(minutes: 1),
  //       verificationCompleted: (AuthCredential credential) async {
  //         await _auth.signInWithCredential(credential);
  //       },
  //       verificationFailed: (FirebaseAuthException e) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('Error: ${e.message}'),
  //           ),
  //         );
  //       },
  //       codeSent: (String verificationId, int? resendToken) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text('Verification code sent to your phone number.'),
  //           ),
  //         );
  //       },
  //       codeAutoRetrievalTimeout: (String verificationId) {
  //         // Handle code auto-retrieval timeout
  //       },
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error: $e'),
  //       ),
  //     );
  //   }
  // }

  Future<void> _resetPassword() async {
    //LoadingUtil.showLoading(context);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text,
      );
      // Reset email sent successfully
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Reset Password'),
          content: Text('Password reset email sent. Please check your email.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _emailController.text = "";
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Handle errors here
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content:
              Text('Error sending password reset email. Please try again.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text(
          'Forgot Password',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 50.0,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Text('Forgot Password? Don’t worry it happens'),
              ),
              const SizedBox(
                height: 100.0,
              ),
              // Padding(
              //   padding: const EdgeInsets.only(left: 14.0, right: 14.0),
              //   child: Container(
              //     height: 200.0,
              //     color: Colors.grey,
              //     child: Image.asset("images/forgotscreenimg.svg"),
              //   ),
              // ),
              const SizedBox(
                height: 50.0,
              ),
              const Text(
                'We will send you a verification code?',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(
                height: 50.0,
              ),
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value!.isEmpty || !value.contains('@')) {
                      return 'Please enter a valid email address.';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter Email',
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xFF17C3CE), // Border color
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.all(10.0),
              //   child: InternationalPhoneNumberInput(
              //     onInputChanged: (PhoneNumber phoneNumber) {
              //       setState(() {
              //         _phoneNumber = phoneNumber;
              //       });
              //     },
              //     selectorConfig: const SelectorConfig(
              //       selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
              //     ),
              //     ignoreBlank: false,
              //     autoValidateMode: AutovalidateMode.onUserInteraction,
              //     selectorTextStyle: const TextStyle(color: Colors.black),
              //     inputDecoration: const InputDecoration(
              //       border: OutlineInputBorder(
              //         borderRadius: BorderRadius.all(Radius.circular(15.0)),
              //         borderSide: BorderSide(
              //           color: Color(0xFF17C3CE), // Border color
              //         ),
              //       ),
              //       hintText: 'Enter your phone number',
              //       labelText: 'Enter Mobile Number',
              //       labelStyle: TextStyle(
              //         color: Color(0xFF17C3CE),
              //       ),
              //       focusedBorder: OutlineInputBorder(
              //         borderSide: BorderSide(color: Color(0xFF17C3CE)),
              //       )
              //     ),
              //   ),
              //
              // ),
              const SizedBox(
                height: 30.0,
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
                  onPressed: _resetPassword,
                  child: const Text('Send'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
