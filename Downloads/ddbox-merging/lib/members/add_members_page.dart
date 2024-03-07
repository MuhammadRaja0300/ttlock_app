import 'dart:math';

import 'package:another_flushbar/flushbar.dart';
import 'package:ddbox/members/members.dart';
import 'package:ddbox/models/loading.dart';
import 'package:ddbox/models/parent_child_relation_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddMembersPage extends StatefulWidget {
  const AddMembersPage({super.key});

  @override
  State<AddMembersPage> createState() => _AddMembersPageState();
}

class _AddMembersPageState extends State<AddMembersPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? adminAuth;
  late String fcmToken;
  final DatabaseReference _userRef =
      FirebaseDatabase.instance.ref().child("users").child("users_details");

  //validate mobile number and submit
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'US');
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String finalID = '';

  Future<void> setParentId() async {
    final SharedPreferences prefs = await _prefs;
    String? parentIdFromPref = prefs.getString('parent_ID');
    finalID = parentIdFromPref.toString();

    setState(() {
      adminAuth = finalID;
    });
  }

  @override
  initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      setParentId();
    });
  }


  // Future<void> sendRandomPasswordEmail(String email) async {
  //   try {
  //     FirebaseAuth auth = FirebaseAuth.instance;
  //
  //     // Generate a random password
  //     String randomPassword = generateRandomPassword();
  //
  //     // Create the user with the generated password
  //     await auth.createUserWithEmailAndPassword(
  //       email: email,
  //       password: randomPassword,
  //     );
  //
  //     // Send a password reset email to the user
  //     await auth.sendPasswordResetEmail(email: email);
  //
  //     print('Password email sent successfully!');
  //     _showSnackbar('Password email sent successfully!');
  //     // You can navigate to a new screen or show a confirmation message here
  //   } catch (e) {
  //     print('Error sending password email: $e');
  //   }
  // }

  String generateRandomPassword() {
    final random = Random();

    // Add 'MyDrop' at the beginning of the password
    String password = 'MyDrop';

    // Add random characters to the password
    const charset =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    password +=
        List.generate(8, (index) => charset[random.nextInt(charset.length)])
            .join();

    // Add a random 8-digit OTP
    String otp = List.generate(8, (index) => random.nextInt(10)).join();
    password += otp;

    return password;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const Members()));
          },
          child: Icon(Icons.person),
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Add New Member',
          style: TextStyle(
              fontSize: 15.0,
              color: Colors.black,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 10.0,
                    ),
                    const Text(
                      'Add Your  New member/User',
                      style: TextStyle(color: Colors.black),
                    ),
                    const Text(
                        'Please enter complete information to add new user'),
                    const SizedBox(
                      height: 30.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          hintText: 'Name',
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.blue, width: 2.0),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
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
                                color: Colors.blue, width: 2.0),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: InternationalPhoneNumberInput(
                        onInputChanged: (PhoneNumber phoneNumber) {
                          _phoneNumber = phoneNumber;
                        },
                        selectorConfig: const SelectorConfig(
                          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                        ),
                        ignoreBlank: false,
                        autoValidateMode: AutovalidateMode.onUserInteraction,
                        selectorTextStyle: const TextStyle(color: Colors.black),
                        inputDecoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter your phone number',
                        ),
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
                          String name = _fullNameController.text.toString();
                          String email = _emailController.text.toString();
                          String mob = _phoneNumber.toString();
                          if(name.isNotEmpty && email.isNotEmpty && mob.isNotEmpty){
                            createChildUser();
                          }else{
                            _showSnackbar('All fields required');
                          }

                          //_showSnackbar('number ${_phoneNumber.phoneNumber}');

                          // if(_formKey.currentState!.validate()){
                          //
                          //
                          // }
                        },
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }


  Future<void> createChildUser() async {
    LoadingUtil.showLoading(context);
    final SharedPreferences prefs = await _prefs;
    String? userEmail = _emailController.text;
    try {
      // bool userExists = await checkUserExistsInDatabase(user as User?);
      // if (userExists) {
      //   LoadingOverlay.hide(context);
      //   _showSnackbar('User already exist please try login');
      // } else {
      String randomPassword = generateRandomPassword();
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: userEmail,
        password: randomPassword,
      );
      // Send a password reset email to the user
      await _auth.sendPasswordResetEmail(email: userEmail);

      String childIdFB = userCredential.user!.uid.toString();
      String? adminIdFB = prefs.getString('adminUid');

      ParentChildRelation parentChildRelation = ParentChildRelation(
          adminID: adminIdFB.toString(), childID: childIdFB);
      _userRef
          .child(adminIdFB.toString())
          .child('child_relation')
          .child(childIdFB.toString())
          .set({
        'admin_ID': parentChildRelation.adminID,
        'child_ID': parentChildRelation.childID,
        'full_name': _fullNameController.text.toString(),
        'child_email': _emailController.text.toString(),
        'child_mobile': _phoneNumber.phoneNumber.toString()
      });

      _userRef.child(childIdFB).set({
        'admin_ID': parentChildRelation.adminID,
        'child_ID': parentChildRelation.childID,
        'full_name': _fullNameController.text.toString(),
        'child_email': _emailController.text.toString(),
        'child_mobile': _phoneNumber.phoneNumber.toString()
      });

      // User signed up successfully
      // print("Admin ID ==> ${parentChildRelation.adminID}");
      // print("Child ID ==> ${parentChildRelation.childID}");
      LoadingUtil.hideLoading(context);
      _showSuccessPopup(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddMembersPage()));
      // }

      // Add user data to the Realtime Database
    } catch (e) {
      LoadingUtil.hideLoading(context);
      if (e is FirebaseAuthException) {
        // Check if the error is due to a user already existing
        if (e.code == 'email-already-in-use') {
          // Display a message indicating that the user already exists
          print("User already exists with this email.");
          _showSnackbar("User already exists with this email.");
        } else {
          // Handle other sign-up errors
          print("Error: ${e.message}");
        }
      }
    }
  }

  void _showSuccessPopup(BuildContext context) {
    Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Container(
        child: Flushbar(
          title: "Success",
          message: "Child added successfully!",
          icon: Icon(
            Icons.check,
            size: 28.0,
            color: Colors.green,
          ),
          duration: Duration(seconds: 3),
          flushbarStyle: FlushbarStyle.FLOATING,
          flushbarPosition: FlushbarPosition.TOP,
          forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
          reverseAnimationCurve: Curves.fastOutSlowIn,
        )..show(context),
      ),
    );
  }

  Future<bool> checkUserExistsInDatabase(User? user) async {
    final databaseReference = FirebaseDatabase.instance.ref();
    DataSnapshot dataSnapshot;

    try {
      DatabaseEvent databaseEvent = await databaseReference
          .child('users')
          .child('users_details')
          .orderByChild(
              'email') // Assuming 'email' is the key you want to check
          .equalTo(user!.email) // Check if the email matches the user's email
          .once();

      dataSnapshot = databaseEvent.snapshot;

      if (dataSnapshot.value != null) {
        // User with the same email exists in the database
        print('User already exists in the database');
        return true;
      } else {
        // User doesn't exist in the database
        createChildUser();
        print('User does not exist in the database');

        return false;
      }
    } catch (error) {
      print('Error checking user existence in the database: $error');
      return false;
    }
  }

  void _showSnackbar(String msg) {
    final snackbar = SnackBar(
      content: Text('$msg'),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}
