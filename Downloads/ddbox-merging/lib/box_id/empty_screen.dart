

import 'package:ddbox/dashboard/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../login/loginpage.dart';
import '../models/shearedpref_model.dart';

class EmptyScreen extends StatefulWidget {

  const EmptyScreen({super.key});

  @override
  State<EmptyScreen> createState() => _EmptyScreenState();
}

class _EmptyScreenState extends State<EmptyScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String finalID = '';

  Future<void> setParentId() async {
    final SharedPreferences prefs = await _prefs;
    String? parentIdFromPref = prefs.getString('parent_ID');
    finalID = parentIdFromPref.toString();
      checkBoxId(finalID);


  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      checkBoxId(finalID);
    });

  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool shouldLogout = (await _showLogoutConfirmationDialog(context)) as bool;
        return shouldLogout;
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 50.0,),
                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text('Box id not found please contact with DDBOX help center'),

                ),
                SizedBox(height: 80.0,),
                SvgPicture.asset(
                  'images/boxidinotfoundicon.svg',
                  // Replace with your SVG asset path
                  width: 120, // Adjust the width as needed
                  height: 120,
                  // Adjust the height as needed
                )
              ],
            )
          )
          ),
        ),
    );

  }

  Future<Future> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User canceled the action
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed the action
                signOut();
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      pref.removeData('email');
      pref.removeData('password');
      _showSnackbar("SignOut Successfully");
    } catch (e) {
      print('Error signing out: $e');
    }

  }
  void _showSnackbar(String msg) {
    final snackbar = SnackBar(
      content: Text('$msg'),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
  Future<void> checkBoxId(String id) async {
    try {
      DatabaseReference dref;
      dref = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child('users_details')
          .child(id)
          .child('box_id');
      dref.onValue.listen((DatabaseEvent event) {
        final data = event.snapshot.value;
        String boxValue = data.toString();
        if (boxValue.length > 6) {
          //showNonCancelablePopup();
            //_showSnackbar("Box_Id added");
          setState(() {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardPage()),
            );
          });


        }
        if (kDebugMode) {
          print('box_id = $data ');
        }
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }
}
