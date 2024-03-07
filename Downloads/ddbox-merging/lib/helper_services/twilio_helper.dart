import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:ddbox/models/loading.dart';

class TwilioHelper {

  Future<void> sendOtpRequest({
    required String phoneNumber,
    required String otp,
    required Function(String) onSuccess,
    required Function(String) onFailure,
  }) async {
    final twilioSID = 'ACcdb4a1fb1caa9058e4b0831b4dd42fd0';
    final twilioAuthToken = '2881b2c188961d1e62c3e114974fcf07';
    final twilioPhoneNumber = '+16592187265';

    try {
      final response = await http.post(
        Uri.parse('https://api.twilio.com/2010-04-01/Accounts/$twilioSID/Messages.json'),
        headers: {
          'Authorization': 'Basic ' + base64Encode(utf8.encode('$twilioSID:$twilioAuthToken')),
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'To': phoneNumber,
          'From': twilioPhoneNumber,
          'Body': '$otp is your verification code for MyDrop',
        },
      );

      if (response.statusCode == 201) {
        onSuccess('OTP sent successfully!');
      } else {
        onFailure('Failed to send OTP.');
      }
    } catch (error) {
      onFailure('Error sending OTP: $error');
    }
  }

}
