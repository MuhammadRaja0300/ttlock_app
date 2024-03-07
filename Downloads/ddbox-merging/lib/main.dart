import 'dart:math';

import 'package:connectivity/connectivity.dart';
import 'package:ddbox/models/notification_service.dart';
import 'package:ddbox/otp/otp_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ddbox/splash/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:workmanager/workmanager.dart';

// Initialize the FlutterLocalNotificationsPlugin
final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Background Message: ${message.notification!.title}");
  _showLocalNotification(message.notification!);
}
const AndroidInitializationSettings initializationSettingsAndroid =
AndroidInitializationSettings('@mipmap/ic_launcher');

const AndroidNotificationDetails androidPlatformChannelSpecifics =
AndroidNotificationDetails(
  'high_importance_channel', // Channel ID
  'Default Channel', // Channel name
  importance: Importance.max,
  priority: Priority.defaultPriority,
  showWhen: false,
);


void saveNotificationToDatabase(RemoteNotification notification) {
  var getUID2 = FirebaseAuth.instance.currentUser;
  DatabaseReference notificationsRef = _databaseReference
      .child('users')
      .child('users_details')
      .child('notifications')
      .child(getUID2!.uid);

  // Generate a unique key for each notification
  String notificationKey = notificationsRef.push().key ?? '';

  // Create a map containing notification details
  Map<String, dynamic> notificationData = {
    'title': notification.title ?? '',
    'body': notification.body ?? '',
    'timestamp': ServerValue.timestamp,
  };

  // Update the database with the notification details
  notificationsRef.child(notificationKey).set(notificationData);

  if (kDebugMode) {
    print('Notification saved to database');
  }
}

void _showLocalNotification(RemoteNotification notification) async {
  saveNotificationToDatabase(notification);
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'high_importance_channel', // Replace with your default channel ID
    'Default Channel', // Change this value
    importance: Importance.max,
    priority: Priority.defaultPriority,
    showWhen: false,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics,iOS: DarwinNotificationDetails());

  await _flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    notification.title, // Notification title
    notification.body, // Notification body
    platformChannelSpecifics,
  );
}

// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) {
//     // Run your background task here
//     OtpPage otpPage = OtpPage();
//     otpPage.g
//     genreteOTPInBackground();
//     return Future.value(true);
//   });
// }

Future<void> main() async {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    // Use Brightness.light for light status bar items
    statusBarBrightness:
        Brightness.light, // Use Brightness.light for light status bar text
  ));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
  // Workmanager().initialize(
  //   callbackDispatcher,
  //   isInDebugMode: true,
  // );
}

//
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingInBackground(RemoteMessage message) async {
//   await Firebase.initializeApp();
// }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _firebaseMessaging.subscribeToTopic('your_topic_name');
    // _notificationService.firebaseInit();
    //_notificationService.isTokenRefresh();$ npm install -g firebase-tools
    _notificationService.getDeviceToken().then((value) {
      if (kDebugMode) {
        print('Device Token');
        print(value);
      }
    });

    //setupFirebaseListener();
    //Notification

    // Configure Firebase Messaging
    _configureFirebaseMessaging();

    _initializeLocalNotifications();
  }
  Future<void> _checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      _showNoInternetDialog();
    }
  }
  Future<void> _showNoInternetDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No Internet'),
          content: Text('Please check your internet connection.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _configureFirebaseMessaging() {
    // Handle incoming messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground Message: ${message.notification!.title}");
      _showLocalNotification(message.notification!);
    });

    // Handle messages when the app is in the background or terminated

    // Handle notification click action
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification Clicked: ${message.notification!.title}");
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  void _initializeLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings();

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid,iOS: initializationSettingsDarwin);

    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: const TextTheme(
          bodyText2: TextStyle(
            fontFamily: 'Manrope',
          ),
        ),
      ),
      home: const SplashPage(),
    );
  }

  void _showBackgroundNotification() async {
    // Customize this method based on your notification logic when the app is in the background
    // For example, you might want to show a notification when the app is paused
    RemoteNotification notification = RemoteNotification(
      title: 'Background Notification',
      body: 'This is a background notification.',
    );
    _showLocalNotification(notification);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // App is resumed from the background
      // Implement any logic you need when the app is in the foreground
    } else if (state == AppLifecycleState.inactive) {
      // App is in an inactive state
    } else if (state == AppLifecycleState.paused) {
      // App is paused (either in the background or terminated)
      _showBackgroundNotification();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }


  void requestNotificationPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true);
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('user granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('user granted provessional permission');
    }
  }

  Future<String> getDeviceToken() async {
    String? token = await _firebaseMessaging.getToken();
    return token!;
  }

  void isTokenRefresh() {
    _firebaseMessaging.onTokenRefresh.listen((event) {
      event.toString();
    });
  }


}
