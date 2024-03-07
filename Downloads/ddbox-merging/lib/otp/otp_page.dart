
import 'dart:math';
import 'package:ddbox/models/static_id_class.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dashboard/dashboard.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({Key? key}) : super(key: key);

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  int otpNo = 0;
  bool regenerateClickable = true;
  String? getPinCode;

  bool timerStarted = false;
  bool differentTimer = false;
  int differenceInSeconds = 0;
  late DateTime endTimeIs;
  bool reGenerated = false;

  Future<void> setOtpTrue() async {
    //var getUID2 = FirebaseAuth.instance.currentUser;
    var getUID2 = StaticId.presentId.toString();
    if (getUID2 != null) {
      final databaseReference = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child('users_details')
          .child(getUID2)
          .child('app_commands')
          .child('otp');
      databaseReference.set(true);
      DateTime currentTime = DateTime.now();
      DateTime newTime = currentTime.add(Duration(minutes: 3));
      print('Current Time: $currentTime');
      print('New Time: $newTime');
      final otpStateRef = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child('users_details')
          .child(getUID2)
          .child('app_commands')
          .child('otp_state');
      otpStateRef.set('$newTime');
      fetchOTP();
      timerStarted = true;
      reGenerated = false;

    }
  }
  Future<void> fetchTime() async {
    try {
      DatabaseReference dref;
      dref = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child('users_details')
          .child(StaticId.presentId)
          .child('app_commands')
          .child('otp_state');
      dref.onValue.listen((DatabaseEvent event) {
        final data = event.snapshot.value;
        String stringTime = data.toString().trim();
        try{
          DateTime dateTime = DateTime.parse(stringTime);
          int intOtpTime = dateTime.millisecondsSinceEpoch;

          //int intOtpTime = int.parse(stringTime.toString());
          print('************* DB time in Int $intOtpTime *************');
          DateTime currentTime = DateTime.now();
          int intCurrentTime = currentTime.millisecondsSinceEpoch;
          //print('************* Time in Int $intCurrentTime *************');
          if(intCurrentTime < intOtpTime){
            //_showSnackbar('Current Time Is Small');

            setState(() {
              timerStarted = true;
              differentTimer = true;
              reGenerated = true;
              //_showSnackbar('reGenerated = true');
              fetchOTP();
              // int test = intOtpTime  - intCurrentTime;
              Duration difference = dateTime.difference(currentTime);
              differenceInSeconds = difference.inSeconds;
              differenceInSeconds = differenceInSeconds * 1000;
              endTimeIs = DateTime.now().add(Duration(seconds: differenceInSeconds));
              //print('Date Diff : $differenceInSeconds');
              // _showSnackbar(differenceInSeconds.toString());
            });

          }else{
            //_showSnackbar('Current Time Is Large');
            differentTimer = false;
            reGenerated = false;
            //_showSnackbar('reGenerated = false');

          }
        }catch (e){
          print('Error converting string to DateTime: $e');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  Future<void> setOtpFalse() async {
    var getUID2 = FirebaseAuth.instance.currentUser;
    if (getUID2 != null) {
      final databaseReference = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child('users_details')
          .child(StaticId.presentId)
          .child('otp');
      databaseReference.set(false);
    }
  }

  void genreteOTP() {
    Random random = Random();
    // Generate a random 4-digit number
    otpNo = random.nextInt(9000) + 1000;
    timerStarted = true;

    print('Random 4-digit number: $otpNo');
    // Update the value in Firebase

  }
  Future<void> fetchOTP()async  {
    try {
      DatabaseReference dref;
      dref = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child('users_details')
          .child(StaticId.presentId)
          .child('status')
          .child('pincode');
      dref.onValue.listen((DatabaseEvent event) {
        final pin = event.snapshot.value;
        if(pin != null){
          setState(() {
            getPinCode = pin.toString();
          });

        }else if(pin == 'None'){
          setState(() {
            getPinCode = '0';
            //_showSnackbar('OTP is null');
          });

        }


        if (kDebugMode) {
          print('PIN CODE = $pin ');
        }
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }
  void genreteOTPInBackground() {
    // Run your OTP generation logic here
    genreteOTP();
    print('OTP generated in the background!');
  }

  // void startBackgroundTask() {
  //   Workmanager().registerOneOffTask(
  //     "1",
  //     "simpleTask",
  //     inputData: <String, dynamic>{},
  //   );
  // }

  void calculateEndTime() {
    // Convert the duration in seconds to a DateTime object
    endTimeIs = DateTime.now().add(Duration(seconds: differenceInSeconds));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchTime();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'OTP',
          style: TextStyle(
              color: Colors.black,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.bold),
        ),
        //iconTheme: const IconThemeData(color: Colors.black),
        // leading: IconButton(
        //   onPressed: () {
        //     Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //             builder: (context) => const DashboardPage()));
        //   },
        //   icon: const Icon(
        //     Icons.arrow_back,
        //     color: Colors.black,
        //   ),
        // ),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 10.0,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 5.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [

                      if(reGenerated == false)
                      Container(
                        margin: const EdgeInsets.all(9),
                        width: 140.0, // Adjust the margin as needed
                        decoration: const BoxDecoration(
                          shape: BoxShape.rectangle,

                          // Background color of the circle
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(// Background color
                            // Other properties like padding, elevation, shape, etc.
                          ),
                          onPressed: () {
                            setState(() {
                              setOtpTrue();
                              //genreteOTP();
                              Future.delayed(const Duration(minutes: 3), () {
                                stopTimer();
                              });
                            });
                          },
                          child: Text(
                            'Generate',
                            style: TextStyle(color: Color(0xFF17C3CE)),
                          ),
                        ),

                      ),
                      if(reGenerated == true)
                        Container(
                          margin: const EdgeInsets.all(9),
                          width: 140.0, // Adjust the margin as needed
                          decoration: const BoxDecoration(
                            shape: BoxShape.rectangle,

                            // Background color of the circle
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom( // Background color
                              // Other properties like padding, elevation, shape, etc.
                            ),
                            onPressed: () {
                              setState(() {
                                setOtpTrue();
                                //genreteOTP();
                                Future.delayed(const Duration(minutes: 3), () {
                                  stopTimer();
                                });
                              });
                            },
                            child: Text(
                              'Regenerate',
                              style: TextStyle(color: Color(0xFF17C3CE)),
                            ),
                          ),

                        ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
                //FilledButton(onPressed: () {}, child: Text("$otpNo")),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Your generated OTP",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0),
                      ),
                      if (otpNo != null)
                        Container(
                          width: 130.0,
                          height: 30.0,
                          decoration: BoxDecoration(
                            color: Color(0xEEEEEEE),
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                // Shadow color and opacity
                                spreadRadius: 2,
                                // How far the shadow spreads
                                blurRadius: 4,
                                // The size of the shadow blur
                                offset: const Offset(0, 4), // Offset of the shadow
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              '$getPinCode',
                              style: const TextStyle(fontSize: 24),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 30.0,
                ),
                if (!timerStarted)
                  Text(
                    '00 : 02 : 59',
                    style: TextStyle(fontSize: 22.0),
                  ),
                if (timerStarted && ! differentTimer)
                  CountdownTimer(
                    endTime: DateTime.now().millisecondsSinceEpoch +
                        180000, // 60 seconds
                    textStyle: TextStyle(fontSize: 24),
                    onEnd: () {
                      setState(() {
                        timerStarted = false;
                        otpNo = 0;
                        reGenerated = false;
                      });
                    },
                  ),
                if(differentTimer)

                  CountdownTimer(
                    endTime: DateTime.now().millisecondsSinceEpoch + differenceInSeconds,
                    textStyle: TextStyle(fontSize: 24),
                    onEnd: () {
                      differentTimer = false;
                      differenceInSeconds = 0;
                      otpNo = 0;
                      reGenerated = false;
                    },
                  ),
                // Container(
                //   margin: const EdgeInsets.all(9),
                //   width: 80.0, // Adjust the margin as needed
                //   decoration: const BoxDecoration(
                //     shape: BoxShape.rectangle,
                //     // Background color of the circle
                //   ),
                //   child: IconButton(
                //     onPressed: () {},
                //     icon: SvgPicture.asset(
                //       'images/copy.svg',
                //       // Replace with your image path
                //       width: 100.0, // Adjust the width as needed
                //       height: 100.0,
                //       fit: BoxFit.fitWidth, // Adjust the height as needed
                //       // Image color
                //     ),
                //     color: const Color(0xFF17C3CE), // Icon color
                //   ),
                // ),

                SizedBox(
                  height: 30.0,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(// Background color
                    // Other properties like padding, elevation, shape, etc.
                  ),
                  onPressed: () {
                    if (getPinCode == null) {
                      _showSnackbar("Otp not found");
                    } else {
                      shareOTP(getPinCode.toString());
                    }
                  },
                  child: Text('Share OTP', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          )),
    );
  }

  void shareOTP(String otpText) {
    Share.share(otpText);
  }

  void _showSnackbar(String msg) {
    final snackbar = SnackBar(
      content: Text('$msg'),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  void stopTimer() {
    timerStarted = false;
    // Update the value in Firebase
    setOtpFalse();
  }



}