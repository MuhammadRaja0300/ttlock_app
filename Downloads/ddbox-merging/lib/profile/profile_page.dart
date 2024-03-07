import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:ddbox/models/loading.dart';
import 'package:ddbox/models/static_id_class.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String firstName = '';
  String lastName = '';
  String completeName = '';
  String uid = '';
  String email = '';
  String pnumber = '';
  String nationalId = '';
  int boxId = 0;
  String finalID = '';
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  //DatabaseReference ref = FirebaseDatabase.instance.ref();

  ImagePicker _imagePicker = ImagePicker();
  XFile? _pickedImage;
  SharedPreferences? prefs;
  String getUID = '';
  String? _imageUrl;

  Future<void> setParentId() async {
    final SharedPreferences prefs = await _prefs;
    String? parentIdFromPref = prefs.getString('parent_ID');
    finalID = parentIdFromPref.toString();
    setState(() {
      _getImageUrlFromDatabase(finalID);
      fetchDataFromFirebase(finalID);
      _pickedImage = null;
      // _imagePicker = ImagePicker();
    });

  }

  //Init State
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setParentId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.only(left: 15, top: 20, right: 15),
          child: GestureDetector(
            onTap: () {
              //FocusScope.of(context).unfocus();
              //_pickImage();
            },
            child: ListView(
              children: [
                Center(
                  child: Stack(
                    children: [
                      InkWell(
                        onTap: () {
                          if(_imageUrl!.isNotEmpty){
                            _showImageDialog(context, _imageUrl.toString());
                          }else{
                            _showSnackbar('Image not found');
                          }

                        },
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(width: 4, color: Colors.white),
                            boxShadow: [
                              BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 10,
                                color: Color(0xFF17C3CE).withOpacity(0.6),
                              ),
                            ],
                            shape: BoxShape.circle,
                            image: _pickedImage != null
                                ? DecorationImage(
                              image: FileImage(File(_pickedImage!.path)),
                              fit: BoxFit.cover,
                            )
                                : _imageUrl != null
                                ? DecorationImage(
                              image: NetworkImage(_imageUrl!),
                              fit: BoxFit.cover,
                            )
                                : DecorationImage(
                              image: NetworkImage('https://media.istockphoto.com/id/1300845620/vector/user-icon-flat-isolated-on-white-background-user-symbol-vector-illustration.jpg?s=612x612&w=0&k=20&c=yBeyba0hUkh14_jgv1OKqIH0CCSWU_4ckRkAoy2p73o='),
                              fit: BoxFit.cover,
                            ),
                          ),

                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF17C3CE),
                              border: Border.all(
                                width: 4,
                                color: Colors.white,
                              ),
                            ),
                            child: Icon(
                              Icons.edit,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Column(
                  children: [
                    Row(
                      children: [
                        Text('Personal Information',
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left),
                      ],
                    ),
                    const SizedBox(height: 8),
                    //Name
                    InkWell(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => const GeneralPage()),
                        // );
                      },
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 0.5,
                                  blurRadius: 3,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            height: 60.0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    'Name',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: 'Manrope',
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        completeName.toString().trim(),
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontFamily: 'Manrope',
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    //Email
                    InkWell(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => const GeneralPage()),
                        // );
                      },
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 0.5,
                                  blurRadius: 3,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            height: 60.0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    'Email',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: 'Manrope',
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        email.toString().trim(),
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontFamily: 'Manrope',
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    //Phone Number
                    InkWell(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => const GeneralPage()),
                        // );
                      },
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 0.5,
                                  blurRadius: 3,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            height: 60.0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    'Phone Number',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: 'Manrope',
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        pnumber.toString().trim(),
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontFamily: 'Manrope',
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(right: 5.0),
                                      child: Icon(
                                        Icons.arrow_forward,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    //National ID
                    InkWell(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => const GeneralPage()),
                        // );
                      },
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 0.5,
                                  blurRadius: 3,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            height: 60.0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    'National ID',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: 'Manrope',
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        nationalId.toString().trim(),
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontFamily: 'Manrope',
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    //Box ID
                    InkWell(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => const GeneralPage()),
                        // );
                      },
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 0.5,
                                  blurRadius: 3,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            height: 60.0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    'Box ID',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: 'Manrope',
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        boxId.toString(),
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontFamily: 'Manrope',
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    //U ID
                    InkWell(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => const GeneralPage()),
                        // );
                      },
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 0.5,
                                  blurRadius: 3,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            height: 60.0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    'User ID',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: 'Manrope',
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        uid.toString(),
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontFamily: 'Manrope',
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
                        onPressed: () {
                          _uploadImageToStorage();
                        },
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Functions

  //Image Picker
  Future<void> _pickImage() async {
    XFile? pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _pickedImage = pickedImage;
      });
    }
  }

  Future<void> fetchDataFromFirebase(String id) async {
      try {
        DatabaseReference dref;
        dref = FirebaseDatabase.instance
            .ref()
            .child('users')
            .child('users_details')
            .child(id);
        dref.onValue.listen((DatabaseEvent event) {
            final data = event.snapshot.value;
            if (data != null && data is Map<dynamic, dynamic>) {
              Map<String, dynamic> userData = {
                'first_name': data['first_name'] ?? '',
                'last_name': data['last_name'] ?? '',
                'email': data['email'] ?? '',
                'national_id': data['national_id'] ?? '',
                'mobile_no': data['mobile_no'] ?? '',
                'box_id': data['box_id'] ?? 0,
                'uid': data['uid'] ?? 0,
              };

              setState(() {
                firstName = userData['first_name'] ?? '';
                lastName = userData['last_name'] ?? '';
                completeName = "${firstName + " " + lastName}";
                email = userData['email'] ?? '';
                nationalId = userData['national_id'] ?? '';
                pnumber = userData['mobile_no'] ?? '';
                boxId = userData['box_id'] ?? 0;
                uid = userData['uid'] ?? '';

                print('Email from db = ${email.toString()}');
              });

            }

        });
      } catch (e) {
        if (kDebugMode) {
          print('Error fetching data: $e');
        }
      }

  }

  Future<void> _uploadImageToStorage() async {
    try {
      if (_pickedImage != null) {
        File imageFile = File(_pickedImage!.path);

        // Read the file as bytes
        List<int> imageBytes = await imageFile.readAsBytes();

        // Convert List<int> to Uint8List
        Uint8List uint8List = Uint8List.fromList(imageBytes);

        // Generate a random string for the image name
        String randomString = _generateRandomString();

        // Initialize notification
        final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
        const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'progress_channel',
          'Progress Channel',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
          onlyAlertOnce: true,
          indeterminate: false,
          progress: 0, // Initial progress
          maxProgress: 100, // Maximum progress value
        );
        const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

        // Upload image to Firebase Storage as JPEG with a random name
        firebase_storage.UploadTask task = firebase_storage
            .FirebaseStorage.instance
            .ref('user_images/${finalID}/$randomString.jpg')
            .putData(
          uint8List,
          firebase_storage.SettableMetadata(
            contentType: 'image/jpeg',
          ),
        );

        // Listen for changes in the task
        task.snapshotEvents.listen((firebase_storage.TaskSnapshot snapshot) {
          double progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;

          // Update notification with progress
          flutterLocalNotificationsPlugin.show(
            0, // Notification ID
            'Uploading Image', // Notification title
            'Progress: ${progress.toInt()}%',
            platformChannelSpecifics,
            payload: 'item x',
          );

          // Dismiss notification when upload is complete
          if (snapshot.bytesTransferred == snapshot.totalBytes) {
            flutterLocalNotificationsPlugin.cancel(0);
          }
        });

        // Get the uploaded image URL
        String imageUrl = await task.then((snapshot) => snapshot.ref.getDownloadURL());

        // Update Firebase Realtime Database with the image URL
        await updateDatabaseWithImageUrl(imageUrl);
      }
    } catch (e) {
      print('Error uploading image: $e');
      _showSnackbar('Select Image First');
    }
  }

  Future<void> updateDatabaseWithImageUrl(String imageUrl) async {
    try {
      // Update the user's data in the Realtime Database with the image URL
      DatabaseReference userRef = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child('users_details')
          .child(finalID);

      await userRef.update({
        'profile_image_url': imageUrl,
      });

      print('Image uploaded and database updated successfully!');
      LoadingUtil.hideLoading(context);
      _showSnackbar('Image Updated!');
    } catch (e) {
      print('Error updating database: $e');
    }
  }

  String _generateRandomString() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        10,
        (_) => chars.codeUnitAt(
          random.nextInt(chars.length),
        ),
      ),
    );
  }

  void _showSnackbar(String msg) {
    final snackbar = SnackBar(
      content: Text('$msg'),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }



  Future<void> _getImageUrlFromDatabase(String id) async {
    final SharedPreferences prefs = await _prefs;
    try {
      DatabaseReference userRef = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child('users_details')
          .child(id);

      userRef.onValue.listen((DatabaseEvent event) {
        final snapshot = event.snapshot;
        if (snapshot.value != null && snapshot.value is Map<dynamic, dynamic>) {
          Map<String, dynamic> userData = Map<String, dynamic>.from(
              snapshot.value as Map<dynamic, dynamic>);
          String imageUrl = userData['profile_image_url'] ?? '';
          if (imageUrl.isNotEmpty) {
            setState(() {
              _imageUrl = imageUrl;
              prefs.setString('image_url', imageUrl);
              var img_url = prefs.getString('image_url');
              imageUrl= img_url.toString();
              print('IMAGE ======///// $_imageUrl');
            });



          } else {
            print('_ImageUrl is null');
          }
        }
      });
    } catch (e) {
      print('Error getting image URL: $e');
    }
  }

  Future<void> _showImageDialog(BuildContext context, String imageUrl) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: double.maxFinite,
            child: Image.network(imageUrl, fit: BoxFit.contain),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validation;
  final String hintText;
  final String labelText;

  const CustomTextField({
    required this.controller,
    required this.validation,
    required this.hintText,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validation,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        hintText: hintText,
        labelText: labelText,
      ),
    );
  }
}
