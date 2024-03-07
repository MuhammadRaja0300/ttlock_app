import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExitConfirmationDialog {
  static Future<bool> showExitDialog(BuildContext context) async {
    bool exit = false;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Exit'),
        content: Text('Are you sure you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
              exit = false;
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Store the last screen information before exiting
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('lastScreen', 'Dashboard'); // Replace 'YourScreenName' with the actual screen name
              Navigator.of(context).pop(true);
              exit = true;
              SystemNavigator.pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );

    return exit;
  }

  static  replaceBack(BuildContext context , Widget pageName) async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => pageName),
    );

  }
  static Future<void> pushBack(BuildContext context , Widget pageName) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => pageName),
    );

  }
}
