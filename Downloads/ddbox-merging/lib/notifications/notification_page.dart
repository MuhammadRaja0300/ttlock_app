import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:ddbox/helper_services/sqflite_helper.dart';
import 'package:ddbox/models/static_id_class.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  Stream<List<Map<String, dynamic>>>? _notificationsStream;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<Map<String, dynamic>> notifications = [];
  String timeStampString = '';
  String globalMinutes = '';
  List<Map<String, dynamic>> result = [];

  late Database _database;

  String finalID = '';

  Future<void> setParentId() async {
    final SharedPreferences prefs = await _prefs;
    String? parentIdFromPref = prefs.getString('parent_ID');
    finalID = parentIdFromPref.toString();
        setState(() {
          _notificationsStream = fetchNotificationsAsStream(finalID);

        });




  }

  @override
  void initState() {
    super.initState();
     // _initDatabase();
     // fetchData();
    setState(() {

      setParentId();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Records',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Container(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _notificationsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                final notifications = snapshot.data!;
                return Container(
                  child: ListView.builder(
                    itemCount: result.length,
                    itemBuilder: (context, index) {
                      final notification = result[index];
                      return Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 5,
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: _getIconForTitle(notification['title']),
                            // SvgPicture.asset(
                            //   'images/lockstatusnotificationicon.svg', // Replace with your image path
                            //   width: 38.0,
                            //   height: 38.0,
                            //   // Image color
                            // ),
                            title: Text(
                              notification['title'],
                              style: TextStyle(fontSize: 12.0),
                            ),
                            trailing: Text(notification['timestamp'],
                                style: TextStyle(fontSize: 12.0)),
                            onTap: () {
                              // Handle notification tap (e.g., navigate to a specific page)
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else {
                return const Center(child: Text('No notifications available'));
              }
            },
          ),
        ),
      ),
    );
  }







  Stream<List<Map<String, dynamic>>> fetchNotificationsAsStream(String fid) {
    DateTime now = DateTime.now();
    DatabaseReference _notificationsRef = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child('users_details')
        .child('notifications')
        .child(fid);

    return _notificationsRef.onValue.map((event) {
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic>? values = snapshot.value as Map<dynamic, dynamic>?;

      // Clear the result list before each update
      result.clear();

      if (values != null) {
        DateTime now = DateTime.now();
        values.forEach((key, value) {
          int timestamp = value['timestamp'];
          // Convert timestamp to DateTime object
          DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
          print("date time: $dateTime");
          print("now: $now");

          // Format the DateTime object into a string
          String formattedTimestamp =
              DateFormat.yMd().add_Hms().format(dateTime);

          Duration difference = now.difference(dateTime);

          print("difference: $difference");
          String formattedTime = formatTimestamp(difference, dateTime);

          result.add({
            'title': value['title'],
            'body': value['body'],
            'timestamp': formattedTime,
            'timestamp_o': value['timestamp'],
          });
        });
        result.sort((a, b) => b['timestamp_o'].compareTo(a['timestamp_o']));
        print('Sorted result: $result');
        //saveNotificationsToLocalDatabase(result);
      }

      return result;
    });
  }

  Future<void> saveNotificationsToLocalDatabase(List<Map<String, dynamic>> notifications) async {
    print('saveNotificationsToLocalDatabase Function called');
    for (var notification in notifications) {
      await DatabaseHelper.instance.insertNotification(notification);

    }
    fetchNotifications();
  }
  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    Database db = await DatabaseHelper.instance.database;
    print('fetched Notifications done');
    return await db.query('notifications', orderBy: 'timestamp_o DESC');
  }


  String formatTimestamp(Duration difference, DateTime dateTime) {
    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays == 1) {
      return 'yesterday at ${DateFormat('HH:mm:ss').format(dateTime)}';
    } else if (difference.inDays > 1) {
      return DateFormat('HH:mm:ss dd/MM/yyyy').format(dateTime);
    } else {
      return DateFormat('HH:mm:ss dd/MM/yyyy').format(dateTime);
    }
  }
}

Widget _getIconForTitle(String title) {
  //print('title :::: $title');
  if (title == 'Box is Knocked') {
    return SvgPicture.asset(
      'images/doorisknocked.svg',
      width: 38.0,
      height: 38.0,
    );
  } else if (title == 'The Box Is Locked') {
    return SvgPicture.asset(
      'images/lockstatusnotificationicon.svg',
      width: 38.0,
      height: 38.0,
    );
  } else if (title == 'The Box Is Unlocked') {
    return SvgPicture.asset(
      'images/lockstatusnotificationicon.svg',
      width: 38.0,
      height: 38.0,
    );
  } else if (title == 'Temperature is increased ') {
    return SvgPicture.asset(
      'images/doorisknocked.svg',
      width: 38.0,
      height: 38.0,
    );
  } else {
    return SvgPicture.asset(
      'images/lockstatusnotificationicon.svg',
      width: 38.0,
      height: 38.0,
    );
    // Return a default icon or null if needed
    // return SizedBox.shrink();
  }
}


