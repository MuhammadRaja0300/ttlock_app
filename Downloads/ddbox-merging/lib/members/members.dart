import 'package:ddbox/dashboard/dashboard.dart';
import 'package:ddbox/helper_services/back_press_helper.dart';
import 'package:ddbox/members/add_members_page.dart';
import 'package:ddbox/models/static_id_class.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Members extends StatefulWidget {
  const Members({Key? key}) : super(key: key);

  @override
  State<Members> createState() => _MembersState();
}

class _MembersState extends State<Members> {
  List<Map<String, dynamic>> result = [];
  Stream<List<Map<String, dynamic>>>? _membersStream;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  String finalID = '';

  Future<void> setParentId() async {
    final SharedPreferences prefs = await _prefs;
    String? parentIdFromPref = prefs.getString('parent_ID');
    finalID = parentIdFromPref.toString();
    setState(() {

      _membersStream = fetchMembersAsStream(finalID);
    });


  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setParentId();

  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        return _onBackPressed(context);
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Members',
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
              stream: _membersStream,
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
                              leading: Icon(Icons.person),
                              title: Text(
                                notification['full_name'],
                                style: TextStyle(fontSize: 12.0),
                              ),
                              // subtitle: Text(notification['child_email'],
                              //     style: TextStyle(fontSize: 12.0)),
                              trailing: Text(notification['child_email'],
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
      ),
    );
  }


  Future<bool> _onBackPressed(BuildContext context) async {
    return await ExitConfirmationDialog.replaceBack(context, AddMembersPage());
  }
  Stream<List<Map<String, dynamic>>> fetchMembersAsStream(String id) {
    //var getUID2 = StaticId.presentId;
    DatabaseReference _membersRef = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child('users_details')
        .child(id)
        .child('child_relation');

    return _membersRef.onValue.map((event) {
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic>? values = snapshot.value as Map<dynamic, dynamic>?;

      // Clear the result list before each update
      result.clear();

      if (values != null) {
        values.forEach((key, value) {

          result.add({
            'child_email': value['child_email'],
            'full_name': value['full_name'],
          });
        });
        print('Sorted result: $result');
      }

      return result;
    });
  }
}
