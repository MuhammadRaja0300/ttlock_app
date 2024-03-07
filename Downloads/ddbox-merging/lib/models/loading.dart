import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingOverlay extends StatelessWidget {
  final String text;

  LoadingOverlay({Key? key, this.text = 'Loading...'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitWave(
        color: Color(0xFF0D6F7A), // Choose your desired color
        size: 80.0
      ),
    );
  }
}

class LoadingUtil {
  static showLoading(BuildContext context, {String text = 'Loading...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoadingOverlay(text: text);
      },
    );
  }
  static showLoadingWithMSG(BuildContext context, String text) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoadingOverlay(text: text);
      },
    );
  }

  static hideLoading(BuildContext context) {
    Navigator.of(context).pop();
  }
}
