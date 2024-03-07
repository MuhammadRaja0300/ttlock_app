import 'dart:async';
import 'package:chewie/chewie.dart';
import 'package:ddbox/about/about_page.dart';
import 'package:ddbox/help/help_page.dart';
import 'package:ddbox/helper_services/back_press_helper.dart';
import 'package:ddbox/logs/logs_page.dart';
import 'package:ddbox/maps/map_dashboard.dart';
import 'package:ddbox/members/add_members_page.dart';
import 'package:ddbox/models/status_model.dart';
import 'package:ddbox/notifications/notification_page.dart';
import 'package:ddbox/models/notification_service.dart';
import 'package:ddbox/profile/child_profile.dart';
import 'package:ddbox/profile/profile_page.dart';
import 'package:ddbox/settings/setting_page.dart';
import 'package:ddbox/terms/terms_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:ddbox/login/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../box_id/empty_screen.dart';
import '../models/shearedpref_model.dart';
import '../otp/otp_page.dart';

late bool unlockstate = false;
late bool lockstate = false;
late StatusModel statusModel;
var pref = SharedPref();

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  _DashboardPageState() {
    print('_DashboardPageState constructor is called.');
  }

  var gEmail;
  var gId;

  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  List<BluetoothDevice> nearbyDevices = [];
  String datasource = "";
  String dataFromFirebase = "Loading...";
  String? temp;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  double? updated_temperature = 0.0;
  double? updated_humidity;
  List<String> languages = [];
  String? selectedLanguage;
  String? address;
  var getUID;
  String _imageUrl = '';
  StreamController<double> temperatureStreamController =
      StreamController<double>();

  Stream<double> get temperatureStream => temperatureStreamController.stream;

  StreamController<double> humidityStreamController =
      StreamController<double>();

  Stream<double> get humidityStream => humidityStreamController.stream;

  // StreamController<double> locationStreamController = StreamController<double>();
  // Stream<double> get locationStream => locationStreamController.stream;

  TextEditingController _addressDashController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  String emailrt = '';
  String imageUrlrt = '';
  String firstName = '';
  String lastName = '';
  String completeName = '';
  String? adminUidInChild;
  String? uidInChild;
  String finalID = '';
  String rtmpUrl = 'rtmp://192.46.228.152:1935/static/webcam' ;

  var userid = '';

  bool isDoorUnlocked = false;

  List<dynamic> statusList = [];
  DatabaseReference? db;
  late ChewieController _chewieController;

  late VideoPlayerController _controller;

  //static String finalID = StaticId.presentId.toString();

  // Stream<DatabaseEvent> db = FirebaseDatabase.instance
  //     .ref()
  //     .child('users')
  //     .child('qqzi1ZE6NgPFBfmaOA4FpRldLTx2')
  //     .child('app_commands')
  //     .onValue;

  // var user_Uid = FirebaseAuth.instance.currentUser;

  NotificationService _notificationService = NotificationService();

  Future<void> getToken() async {
    String? token = await messaging.getToken();

// Print or use the token as needed
    print("FCM Token from DASHBOARD: $token");
    _updateFCMToken(token.toString());
  }

  void _updateFCMToken(String token) async {
    final SharedPreferences prefs = await _prefs;
    var role = prefs.getString('role_from_SP');
    if (role == 'admin') {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      // Reference to the users node in the database
      DatabaseReference userRef = _databaseReference
          .child('users')
          .child('users_details')
          .child(userId);

      // Update the FCM token
      userRef.update({'fcm_token': token});
    } else if (role == 'child') {
      updateChildFCMinAdmin(finalID, token);
    }
  }

  void updateChildFCMinAdmin(String id, String token) {
    DatabaseReference userRef = _databaseReference
        .child('users')
        .child('users_details')
        .child(id)
        .child('child_relation')
        .child(FirebaseAuth.instance.currentUser!.uid);

    // Update the FCM token
    userRef.update({'fcm_token': token});
  }

  Future<void> loadUserData() async {
    final SharedPreferences prefs = await _prefs;
    //var getUID2 = FirebaseAuth.instance.currentUser!.uid;
    var getUID2 = finalID;
    if (getUID2 != null) {
      try {
        DatabaseReference dref;
        dref = FirebaseDatabase.instance
            .ref()
            .child('users')
            .child('users_details')
            .child(finalID);
        dref.onValue.listen((DatabaseEvent event) {
          final data = event.snapshot.value;
          if (data != null && data is Map<dynamic, dynamic>) {
            Map<String, dynamic> userData = {
              'email': data['email'] ?? '',
              'profile_image_url': data['profile_image_url'] ?? '',
              'first_name': data['first_name'] ?? '',
              'last_name': data['last_name'] ?? '',
              'address': data['address'] ?? ''
            };
            var userROle = prefs.getString('role_from_SP');
            var useremail = prefs.getString('child_email');
            var username = prefs.getString('child_name');
            if (userROle == 'admin') {
              emailrt = userData['email'] ?? '';
              imageUrlrt = userData['profile_image_url'] ?? '';
              firstName = userData['first_name'] ?? '';
              lastName = userData['last_name'] ?? '';
              completeName = '${firstName + " " + lastName}';
              //updated_humidity = userData['humidity'] ?? '';
              //updated_temperature = userData['temperature'] ?? '';
              address = userData['address'] ?? '';
              setState(() {
                _addressDashController.text = address.toString();
              });
            } else {
              emailrt = useremail.toString();
              imageUrlrt = userData['profile_image_url'] ?? '';
              completeName = username.toString();
              //updated_humidity = userData['humidity'] ?? '';
              //updated_temperature = userData['temperature'] ?? '';
              address = userData['address'] ?? '';
              setState(() {
                _addressDashController.text = address.toString();
                _imageUrl = imageUrlrt;
              });
            }
          }
        });
      } catch (e) {
        if (kDebugMode) {
          print('Error fetching data: $e');
        }
      }
    }
  }

  // Future<void> fetchLanguages() async {
  //   DatabaseReference reference = FirebaseDatabase.instance.ref().child('users')
  //       .child('qqzi1ZE6NgPFBfmaOA4FpRldLTx2')
  //       .child('app_commands')
  //       .child('language');
  //   DataSnapshot snapshot = (await reference.once()).snapshot;
  //
  //   List<String> fetchedLanguages = [];
  //   //Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
  //   String? data = snapshot.value as String?;
  //
  //   // if (data != null) {
  //   //   data.forEach((key, value) {
  //   //     fetchedLanguages.add(value['language']);
  //   //   });
  //
  //     setState(() {
  //       dropdownValues.add(data.toString());
  //       selectedLanguage = dropdownValues.isNotEmpty ? dropdownValues[0] : null;
  //       // languages = data as List<String>;
  //       // selectedLanguage = languages.isNotEmpty ? languages[0] : null;
  //     });
  //   }

  Future<void> getGDataFromPref() async {
    final SharedPreferences prefs = await _prefs;
    gEmail = prefs.getString('g_email');
    gId = prefs.getString('g_userID');
    if (kDebugMode) {
      print('GET PREF Google_EMAIL = $gEmail');
      print('GET PREF Google_UID = $gId');
    }
  }

  Future<void> _getUserDataFromDatabase() async {
    final SharedPreferences prefs = await _prefs;
    try {
      DatabaseReference userRef = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child('users_details')
          .child(finalID);

      userRef.onValue.listen((DatabaseEvent event) {
        final snapshot = event.snapshot;
        if (snapshot.value != null && snapshot.value is Map<dynamic, dynamic>) {
          Map<String, dynamic> userData = Map<String, dynamic>.from(
              snapshot.value as Map<dynamic, dynamic>);
          String imageUrl = userData['profile_image_url'] ?? '';
          String useremail = userData['email'] ?? '';
          String adminuid = userData['uid'] ?? '';

          _imageUrl = imageUrl;
          print(
              'Dashboard EMAIL ........._getUserDataFromDatabase..........$useremail');
          prefs.setString('adminUid', adminuid);
        }
      });
    } catch (e) {
      print('Error getting image URL: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
    );

    _chewieController = ChewieController(
      videoPlayerController: _controller,
      aspectRatio: 16 / 9, // You can adjust the aspect ratio as needed
      autoInitialize: true,
      looping: true, // Set to true if you want the video to loop
    );
    //checkUser();
    print('Parent Id ===== $finalID');
    setState(() {
      db = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child('users_details')
          .child(finalID)
          .child('status');
    });

    setParentId();
    // print('Current static Id Is------------------ ${StaticId.presentId.toString()}');
    // print('Current final Id Is------------------ ${finalID}');
  }

  void _initializePlayer() {
    setState(() {
      _chewieController = ChewieController(
        videoPlayerController: VideoPlayerController.network(
          'rtmp://192.46.228.152:1935/static/webcam',
        ),
        aspectRatio: 16 / 9,
        autoInitialize: true,
        looping: true,
      );
    });

  }

  Future<void> onSelectNotification(String? payload) async {
    // Handle the notification when it's tapped by the user
    // You can navigate to a specific screen or perform an action here
  }

  //Get Data from FB & shown in dropdown
  final DatabaseReference gettemprature = FirebaseDatabase.instance.reference();
  List<String> _data = ['Eng', 'Arb'];
  List<String> dropdownValues = [''];
  String _selectedValue = "";

  double temperature = 25.5;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  //Drawer
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Profile',
      style: optionStyle,
    ),
    Text(
      'Index 1: Add Member',
      style: optionStyle,
    ),
    Text(
      'Index 2: Logs',
      style: optionStyle,
    ),
    Text(
      'Index 3: Setting',
      style: optionStyle,
    ),
    Text(
      'Index 4: Help & Support',
      style: optionStyle,
    ),
    Text(
      'Index 5: About',
      style: optionStyle,
    ),
    Text(
      'Index 6: Terms & Condition',
      style: optionStyle,
    ),
    Text(
      'Index 7: Log Out',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Color lightGrey = const Color(0xFFD3D3D3);

  Future<bool> _onBackPressed(BuildContext context) async {
    return await ExitConfirmationDialog.showExitDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return _onBackPressed(context);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF17C3CE),
          actions: [
            // Container(
            //   margin: const EdgeInsets.all(9), // Adjust the margin as needed
            //   decoration: BoxDecoration(
            //     shape: BoxShape.circle,
            //     color: Colors.white, // Background color of the circle
            //   ),
            //   child: IconButton(
            //     onPressed: () {
            //       // Add your action to open the drawer here
            //     },
            //     icon: const Icon(Icons.menu),
            //     color: const Color(0xFF17C3CE), // Icon color
            //   ),
            // ),
            Container(
              margin: const EdgeInsets.all(9), // Adjust the margin as needed
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white, // Background color of the circle
              ),
              child: IconButton(
                onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => MapPageGoogle()),
                  // );
                  //setData();
                  //fetchTemperature();
                },
                icon: SvgPicture.asset(
                  'images/logsicon.svg', // Replace with your image path
                  width: 50.0, // Adjust the width as needed
                  height: 50.0, // Adjust the height as needed
                  // Image color
                ),
                color: const Color(0xFF17C3CE), // Icon color
              ),
            ),
            Container(
              margin: const EdgeInsets.all(9), // Adjust the margin as needed
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white, // Background color of the circle
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationPage()),
                  );
                },
                icon: const Icon(Icons.history),
                color: const Color(0xFF17C3CE), // Icon color
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      StreamBuilder<double>(
                        stream: temperatureStream,
                        builder: (context, snapshot) {
                          double? updatedTemperature = snapshot.data;

                          Color backgroundColor = updatedTemperature != null &&
                                  updatedTemperature > 44
                              ? Colors.red
                              : Color(0xD1D1D7C9);

                          return Container(
                            height: 30.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30.0),
                              color: backgroundColor,
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 6.0, right: 6.0),
                              child: Container(
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.wb_sunny,
                                      size: 17.0,
                                      color: Color(0xfff8b62d),
                                    ),
                                    const SizedBox(width: 5.0),
                                    Text(
                                      '${updatedTemperature?.toStringAsFixed(1) ?? 'N/A'} °C',
                                      style: const TextStyle(
                                        fontSize: 15.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // Container(
                      //   height: 30.0,
                      //   decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(30.0),
                      //     // Adjust the radius as needed
                      //     color: const Color(0xFFefeeee), // Background color
                      //   ),
                      //   child: Padding(
                      //     padding: const EdgeInsets.only(left: 6.0, right: 6.0),
                      //     child: Row(
                      //       children: [
                      //         const Icon(
                      //           Icons.wb_sunny,
                      //           size: 17.0,
                      //           color: Color(0xfff8b62d),
                      //         ),
                      //         const SizedBox(
                      //           width: 5.0,
                      //         ),
                      //         Text(
                      //           '${updated_temperature?.toStringAsFixed(1)} °C',
                      //           // Temperature unit (e.g., °C for Celsius)
                      //           style: const TextStyle(
                      //             fontSize:
                      //                 15.0, // Adjust the font size as needed
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      //Humidity
                      StreamBuilder<double>(
                          stream: humidityStream,
                          builder: (context, snapshot) {
                            double? updatedTemperature = snapshot.data;

                            return Container(
                              height: 30.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30.0),
                                // Adjust the radius as needed
                                color:
                                    const Color(0xFFefeeee), // Background color
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 6.0, right: 6.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.water_drop,
                                      size: 17.0,
                                      color: Color(0xfff8b62d),
                                    ),
                                    const SizedBox(
                                      width: 5.0,
                                    ),
                                    Text(
                                      //'${updatedTemperature?.toStringAsFixed(1)} %',
                                      '${updatedTemperature?.toString() ?? 'N/A'} %',
                                      // Temperature unit (e.g., °C for Celsius)
                                      style: const TextStyle(
                                        fontSize:
                                            15.0, // Adjust the font size as needed
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                      Container(
                        height: 30.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          // Adjust the radius as needed
                          color: const Color(0xFFdcf3f9), // Background color
                        ),
                        child: Padding(
                            padding:
                                const EdgeInsets.only(left: 6.0, right: 6.0),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'images/langicon.svg',
                                  width: 25.0,
                                  height: 25.0,
                                ),
                                DropdownButton(
                                  value: selectedLanguage,
                                  items: _data.map((value) {
                                    return DropdownMenuItem(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: const TextStyle(
                                          fontSize: 12.0,
                                          fontFamily: 'Manrope',
                                          color: Color(0xFF17C3CE),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedLanguage = newValue!;
                                    });
                                  },
                                  iconEnabledColor: const Color(0xFF17C3CE),
                                ),
                              ],
                            )),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15.1),

                StreamBuilder(
                  stream: _database
                      .child('users')
                      .child('users_details')
                      .child(finalID)
                      .child('address')
                      .onValue,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      // Access the data from the snapshot
                      var data = snapshot.data!.snapshot.value;

                      return Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: SvgPicture.asset(
                              'images/location_icon.svg',
                              // Replace with your SVG asset path
                              width: 50, // Adjust the width as needed
                              height: 50,
                              // Adjust the height as needed
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: GestureDetector(
                              child: Text(
                                '${data?.toString()}',
                                // Temperature unit (e.g., °C for Celsius)
                                style: const TextStyle(
                                  fontSize: 13.0,
                                  color: Color(0xFF17C3CE),
                                  decoration: TextDecoration.underline,
                                  decorationColor: Color(0xFF17C3CE),
                                  // Adjust the font size as needed
                                ),
                              ),
                              onTap: () {
                                //final SharedPreferences prefs = await _prefs;
                                //prefs.setString('address_dashboard', $);
                                locationOnTap();
                              },
                            ),
                          ),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
                const SizedBox(
                  height: 15.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      height: 250.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        // Adjust the radius as needed
                        color: Colors.black, // Background color
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        // Adjust the radius as needed
                        child: Chewie(
                          controller: _chewieController,
                        ),
                      ),
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                StreamBuilder<DatabaseEvent>(
                  stream: db!.onValue,
                  builder: (BuildContext context,
                      AsyncSnapshot<DatabaseEvent> snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData &&
                          snapshot.data!.snapshot.value is Map) {
                        Map<dynamic, dynamic> data = snapshot
                            .data!.snapshot.value as Map<dynamic, dynamic>;

                        statusModel = StatusModel(
                          humidity: data['humidity'] as double,
                          lock_status: data['lock_status'] as bool,
                          temperature: data['temperature'] as double,
                        );

                        bool unlock = statusModel.lock_status;

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            if (unlock == true)
                              ImageButton(
                                onPressed: () {
                                  setState(() {
                                    //buildLottieAnimation();
                                    //setLockStatus(false);
                                    setBooleanValuesOfUnlock(true);
                                    //setBooleanValues(false, true);
                                    print('Image Button Pressed');
                                  });
                                },
                                image: const AssetImage(
                                    'images/un.png'), // Replace with your image path
                              ),

                            //Image.asset('images/touchtolock.png'),
                            if (unlock == false)
                              ImageButton(
                                onPressed: () {
                                  setState(() {
                                    //setLockStatus(true);
                                    setBooleanValuesOfLock(true);
                                    print('Image Button Pressed');
                                  });
                                },
                                image: const AssetImage(
                                    'images/lo.png'), // Replace with your image path
                              ),
                            //Image.asset('images/touchtounlock.png'),

                            // Text('Language: ${appCommands.language}'),
                            // Text('Lock: $lock'),
                            // Text('OTP: ${appCommands.otp}'),
                            // Text('Unlock: $unlock'),
                            const SizedBox(
                              height: 20.0,
                            ),
                            // if (lockstate) Image.asset('images/touchtounlock.png'),
                            // // Replace with the path to your "unlock.png" asset
                            // Text(lockstate ? 'Unlock' : 'Lock'),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => OtpPage()));
                                  },
                                  child: SvgPicture.asset(
                                    'images/otpdashboard.svg',
                                    // Replace with your SVG asset path
                                    width: 50, // Adjust the width as needed
                                    height: 50,
                                    // Adjust the height as needed
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 30.0,
                            ),
                            const Row(
                              children: [
                                SizedBox(
                                  width: 8.0,
                                  height: 5.0,
                                ),
                                Text(
                                  'Box Status',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 8.0),
                                SvgPicture.asset(
                                  'images/box.svg',
                                  // Replace with your image path
                                  width: 50.0, // Adjust the width as needed
                                  height: 50.0, // Adjust the height as needed
                                  // Image color
                                ),
                                //Icon(Icons.door_sliding , color: Color(0xFF17C3CE),size: 37.0,),
                                const SizedBox(
                                  width: 5.0,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (statusModel.lock_status == true)
                                      const Text(
                                        'Locked',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    if (statusModel.lock_status == true)
                                      const Text(
                                        'Your box is locked!',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    if (statusModel.lock_status == false)
                                      const Text(
                                        'Unlocked',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    if (statusModel.lock_status == false)
                                      const Text(
                                        'Your box is unlocked!',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                  ],
                                )
                              ],
                            )
                          ],
                        );
                      }
                      return const CircularProgressIndicator();
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),

                // if (lockstate == true)
                //   Image.asset('images/touchtolock.png', width: 100, height: 100),
                // if (unlockstate == true)
                //   Image.asset('images/touchtounlock.png',
                //       width: 100, height: 100),
                // if (lockstate == false || unlockstate == false) Text("No data"),
                //
                // ElevatedButton(
                //   onPressed: () {
                //     setState(() {
                //       // Toggle the lock/unlock state based on the current values
                //       lockstate = !lockstate;
                //       unlockstate = !unlockstate;
                //     });
                //   },
                //   child: Text(lockstate ? 'Unlock' : 'Lock'),
                // ),
              ],
            ),
          ),
        ),
        // Center(
        //   child: _widgetOptions[_selectedIndex],
        // ),
        drawer: Drawer(
          backgroundColor: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                width: double.infinity,
                height: 240,
                child: DrawerHeader(
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 4, color: Colors.white),
                                  boxShadow: [
                                    BoxShadow(
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      color: Color(0xFF17C3CE).withOpacity(0.6),
                                      //color: Colors.black.withOpacity(0.2),
                                    )
                                  ],
                                  shape: BoxShape.circle,
                                  image: _imageUrl != null
                                      ? DecorationImage(
                                    image: NetworkImage(_imageUrl),
                                    fit: BoxFit.fill,
                                  )
                                      :
                                    DecorationImage(
                                      image: NetworkImage('https://media.istockphoto.com/id/1300845620/vector/user-icon-flat-isolated-on-white-background-user-symbol-vector-illustration.jpg?s=612x612&w=0&k=20&c=yBeyba0hUkh14_jgv1OKqIH0CCSWU_4ckRkAoy2p73o='),
                                      fit: BoxFit.cover,
                                    )
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.5),
                                child: Text(
                                  completeName,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  emailrt,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Expanded(
                        //   child: UserAccountsDrawerHeader(
                        //     accountName: Padding(
                        //       padding: const EdgeInsets.only(top: 34.5),
                        //       child: Text(
                        //         fullnamert,
                        //         style: const TextStyle(
                        //             color: Colors.black,
                        //             fontWeight: FontWeight.bold),
                        //       ),
                        //     ),
                        //     accountEmail: Text(
                        //       emailrt,
                        //       style: const TextStyle(color: Colors.black),
                        //     ),
                        //     currentAccountPicture: CircleAvatar(
                        //       backgroundImage: NetworkImage(imageUrlrt),
                        //     ),
                        //     decoration: const BoxDecoration(
                        //       color: Colors.white,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ListTile(
                leading: SvgPicture.asset(
                  'images/settings.svg', // Replace with your image path
                  width: 26.0,
                  height: 26.0,
                  // Image color
                ),
                title: const Text('Profile'),
                selected: _selectedIndex == 0,
                onTap: () {
                  _onItemTapped(2);
                  profileRoleCheck();
                },
              ),
              ListTile(
                leading: SvgPicture.asset(
                  'images/member.svg',
                  width: 26.0,
                  height: 26.0,
                  // Image color
                ),
                title: const Text('Add Member'),
                selected: _selectedIndex == 1,
                onTap: () {
                  memberOnTap();

                  //_onItemTapped(0);
                },
              ),
              ListTile(
                leading: SvgPicture.asset(
                  'images/logs.svg', // Replace with your image path
                  width: 26.0,
                  height: 26.0,
                  // Image color
                ),
                title: const Text('Logs'),
                selected: _selectedIndex == 2,
                onTap: () {
                  _onItemTapped(1);
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LogsPage()));
                },
              ),
              ListTile(
                leading: SvgPicture.asset(
                  'images/settings.svg', // Replace with your image path
                  width: 26.0,
                  height: 26.0,
                  // Image color
                ),
                title: const Text('Setting'),
                selected: _selectedIndex == 3,
                onTap: () {
                  // Update the state of the app
                  _onItemTapped(2);
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingPage()));
                },
              ),
              ListTile(
                leading: SvgPicture.asset(
                  'images/help.svg', // Replace with your image path
                  width: 26.0,
                  height: 26.0,
                  // Image color
                ),
                title: const Text('Help & Support'),
                selected: _selectedIndex == 4,
                onTap: () {
                  // Update the state of the app
                  _onItemTapped(3);
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HelpPage()));
                },
              ),
              ListTile(
                leading: SvgPicture.asset(
                  'images/abouticon.svg', // Replace with your image path
                  width: 26.0,
                  height: 26.0,
                  // Image color
                ),
                title: const Text(
                  'About',
                  style: TextStyle(fontFamily: 'Manrope'),
                ),
                selected: _selectedIndex == 5,
                onTap: () {
                  // Update the state of the app
                  _onItemTapped(4);
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AboutPage()));
                },
              ),
              ListTile(
                leading: SvgPicture.asset(
                  'images/termsicon.svg', // Replace with your image path
                  width: 26.0,
                  height: 26.0,
                  // Image color
                ),
                title: const Text('Terms & Conditions'),
                selected: _selectedIndex == 6,
                onTap: () {
                  // Update the state of the app
                  _onItemTapped(5);
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TermsPage()));
                },
              ),
              ListTile(
                leading: SvgPicture.asset(
                  'images/logouticon.svg', // Replace with your image path
                  width: 26.0,
                  height: 26.0,
                  // Image color
                ),
                title: const Text('Signout'),
                selected: _selectedIndex == 7,
                onTap: () {
                  // Update the state of the app
                  _onItemTapped(5);
                  Navigator.pop(context); // Close the drawer
                  signOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  //get temperature from database
  Future<void> fetchTemperature() async {
    try {
      DatabaseReference dref;
      dref = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child('users_details')
          .child(finalID)
          .child('status')
          .child('temperature');
      dref.onValue.listen((DatabaseEvent event) {
        final data = event.snapshot.value;
        updated_temperature = data as double?;
        temperatureStreamController.add(updated_temperature!);
        print('Temperature = $updated_temperature ');
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  //get humidity from database
  Future<void> fetchHumidity() async {
    final SharedPreferences prefs = await _prefs;
    try {
      DatabaseReference dref;
      dref = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child('users_details')
          .child(finalID)
          .child('status')
          .child('humidity');
      dref.onValue.listen((DatabaseEvent event) {
        final data = event.snapshot.value;
        updated_humidity = double.tryParse(data.toString());
        humidityStreamController.add(updated_humidity!);

        if (kDebugMode) {
          print('Humidity = $data ');
        }
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }




  //SignOut
  void signOut() async {
    try {
      await _auth.signOut();
      _googleSignIn.signOut();
      clearPreferences();
      //pref.removeData('role_from_SP');

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      // pref.removeData('email');
      // pref.removeData('password');

      _showSnackbar("Logout Successfully");
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

  void setBooleanValues(bool lock, bool unlock) {
    DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child('users_details')
        .child(finalID)
        .child('app_commands');

    Map<String, dynamic> updateData = {
      'lock': lock,
      'unlock': unlock,
    };

    // Update the values at a specific path in Firebase
    databaseReference.update(updateData);
  }

  void setBooleanValuesOfLock(bool lock) {
    DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child('users_details')
        .child(finalID)
        .child('app_commands');

    Map<String, dynamic> updateData = {
      'lock': lock,
    };

    // Update the values at a specific path in Firebase
    databaseReference.update(updateData);
  }

  void setBooleanValuesOfUnlock(bool unlock) {
    DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child('users_details')
        .child(finalID)
        .child('app_commands');

    Map<String, dynamic> updateData = {
      'unlock': unlock,
    };

    // Update the values at a specific path in Firebase
    databaseReference.update(updateData);
  }

  void setLockStatus(bool status) {
    DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child('users_details')
        .child(finalID)
        .child('status');

    Map<String, dynamic> updateData = {
      'lock_status': status,
    };

    // Update the values at a specific path in Firebase
    databaseReference.update(updateData);
  }



  Future<void> setData() async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('name', 'Sheikh Asim');
    var vale = prefs.getString('name');
    print('PREF VALUE = $vale');
  }

  var isDashboardPage = false;

  Future<void> checkBoxId() async {
    try {
      DatabaseReference dref;
      dref = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child('users_details')
          .child(finalID)
          .child('box_id');
      dref.onValue.listen((DatabaseEvent event) {
        final data = event.snapshot.value;
        String boxValue = data.toString();
        if (boxValue.length < 6) {
          //showNonCancelablePopup();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const EmptyScreen()),
          );
          isDashboardPage = true;
        } else {
          setState(() {
            if (isDashboardPage == true) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DashboardPage()),
              );
              isDashboardPage = false;
            }
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

  Future<void> locationOnTap() async {
    final SharedPreferences prefs = await _prefs;
    var role = prefs.getString('role_from_SP');
    if (role == 'child') {
      _showSnackbar('Not Allowed');
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MapDashboard(
                  address: address.toString(),
                )),
      );
    }
  }

  void showNonCancelablePopup() {
    // Fluttertoast.showToast(
    //   msg: "ID not found",
    //   toastLength: Toast.LENGTH_LONG,
    //   gravity: ToastGravity.CENTER,
    //   timeInSecForIosWeb: 2,
    //   backgroundColor: Colors.red,
    //   textColor: Colors.white,
    //   fontSize: 16.0,
    //   webBgColor: "#e74c3c",
    // );
  }

  Future<void> memberOnTap() async {
    final SharedPreferences prefs = await _prefs;
    var role = prefs.getString('role_from_SP');
    if (role == 'child') {
      Navigator.pop(context);
      _showSnackbar('Not Allowed');
    } else {
      Navigator.pop(context); // Close the drawer
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const AddMembersPage()));
    }
  }

  static Future<void> clearPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> getMobileFromPref() async {
    final SharedPreferences prefs = await _prefs;
    userid = prefs.getString('user_uid')!;
    print('get uid from pref $userid');
  }

  Future<void> profileRoleCheck() async {
    final SharedPreferences prefs = await _prefs;
    var role = prefs.getString('role_from_SP');
    if (role == 'admin') {
      Navigator.pop(context); // Close the drawer
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ProfilePage()));
    } else if (role == 'child') {
      Navigator.pop(context); // Close the drawer
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ChildProfilePage()));
    }
  }

  Future<void> setParentId() async {
    final SharedPreferences prefs = await _prefs;
    String? parentIdFromPref = prefs.getString('parent_ID');
    finalID = parentIdFromPref.toString();
    setState(() {
      db = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child('users_details')
          .child(finalID)
          .child('status');
    });

    print('7777777777777777777777777777   imageUrl $imageUrlrt    77777777777777777777777777');
    checkBoxId();
    loadUserData();
    getGDataFromPref();
    getToken();
    fetchTemperature();
    fetchHumidity();
    selectedLanguage = 'Eng';
    //fetchLanguages();
    print('Init status is running');
    _getUserDataFromDatabase();
  }
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ChewieController>('_chewieController', _chewieController));
  }
}

class ImageButton extends StatelessWidget {
  final VoidCallback onPressed;
  final ImageProvider image;
  final double width;
  final double height;

  ImageButton({
    required this.onPressed,
    required this.image,
    this.width = 200.0,
    this.height = 230.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: image,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}

class BluetoothDevice {
  final String name;
  final String address;

  BluetoothDevice({required this.name, required this.address});
}

class TemperatureStream {
  final StreamController<double> _temperatureController =
      StreamController<double>();

  Stream<double> get temperatureStream => _temperatureController.stream;

  DatabaseReference tempReference = FirebaseDatabase.instance
      .ref()
      .child('users')
      .child('users_details')
      .child(FirebaseAuth.instance.currentUser!.uid)
      .child('status')
      .child('temperature');

  // Function to update temperature
  void updateTemperature(double temperature) {
    _temperatureController.add(temperature);
  }

  // Close the stream controller when no longer needed
  void dispose() {
    _temperatureController.close();
  }
}

Widget buildLottieAnimation() {
  return Lottie.asset(
    'assets/circular_animation.json', // Replace with your animation file path
    width: 500,
    height: 500,
    fit: BoxFit.cover,
  );
}
