
import 'package:ddbox/dashboard/dashboard.dart';
import 'package:ddbox/models/email_model.dart';
import 'package:ddbox/models/loading.dart';
import 'package:ddbox/forgot_password/forgotpasswordpage.dart';
import 'package:ddbox/verify_number/google_verifynumberpage.dart';
import 'package:ddbox/models/static_id_class.dart';
import 'package:ddbox/verify_number/manual_verifynumberpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/notification_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late DatabaseReference dref;

  //final GoogleSignIn _googleSignIn = GoogleSignIn();
  final LocalAuthentication auth = LocalAuthentication();
  bool rememberChecked = false;
  bool _obscureText = true; // Initially hide the password
  final Color customColor = const Color(0xFF17C3CE);
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );
  String authFCMToken = '';
  String userUID = '';
  String byEmailUserId = "";

  //login with email
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String firstName = '';
  String? adminUidInChild;
  String? uidInChild;
  String emailrt = '';
  String? userEmail;
  EmailModel? emailModel;

  // void _initializeFCM() {
  //   _firebaseMessaging.getToken().then((String? token) {
  //     if (token != null) {
  //       authFCMToken = token;
  //       _updateFCMToken(authFCMToken);
  //     }
  //   });
  //
  //   _firebaseMessaging.onTokenRefresh.listen((String? token) {
  //     if (token != null) {
  //       authFCMToken = token;
  //       _updateFCMToken(authFCMToken);
  //     }
  //   });
  // }

  // void _updateFCMToken(String token) async {
  //   User? user = _auth.currentUser;
  //
  //   // Get the user ID
  //   String userId = FirebaseAuth.instance.currentUser!.uid;
  //   userUID = userId.toString();
  //
  //   // Reference to the users node in the database
  //   DatabaseReference userRef = _databaseReference
  //       .child('users')
  //       .child('users_details')
  //       .child(userId);
  //
  //   // Update the FCM token
  //   userRef.update({'fcm_token': token});
  //   }

  Future<void> _loginWithEmailAndPassword() async {
    LoadingUtil.showLoading(context);
    try {
      // 'te@gmail.com' ;  '112233';
      var email = _emailController.text.trim();
      var password = _passwordController.text.trim();
      //print("$email $password");
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
        //_updateFCMToken(authFCMToken);
        LoadingUtil.hideLoading(context);
        byEmailUserId = userCredential.user!.uid.toString();
        checkUserExistsInDatabase(byEmailUserId);

    } catch (error) {
      LoadingUtil.hideLoading(context);

      if (error is FirebaseAuthException) {
        if (error.code == 'user-not-found') {
          // Show an error message indicating that the user with the provided email does not exist.
          if (kDebugMode) {
            print('User with this email does not exist.');
          }
          _showSnackbar('User with this email does not exist.');
        } else if (error.code == 'wrong-password') {
          // Show an error message indicating that the password is incorrect.
          if (kDebugMode) {
            print('Incorrect password. Please check your password.');
          }
          _showSnackbar('Incorrect password. Please check your password.');
        } else {
          if (kDebugMode) {
            print('User with this email does not exist.');
          }
          _showSnackbar('User with this email does not exist.');
          // Handle other authentication failures with appropriate error messages.
          // print('Authentication failed: ${error.message}');
          // _showSnackbar('Authentication failed: ${error.message}');
        }
      } else {
        // Handle other unexpected errors.
        if (kDebugMode) {
          print('Unexpected error: $error');
        }
        _showSnackbar('Unexpected error: $error');
      }
    }
    // if (_formKey.currentState!.validate()) {
    //
    // } else {
    //   LoadingOverlay.hide(context);
    // }
  }

  Future<void> checkUser(String id) async {
    print('7');
    final SharedPreferences prefs = await _prefs;
    try {
      print('8');
      dref = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child('users_details')
          .child(id);
      dref.onValue.listen((event) {
        print('9');

        final data = event.snapshot.value;
        print('data: $data');
        if (data != null && data is Map<dynamic, dynamic>) {
          Map<String, dynamic> userData = {
            'admin_ID': data['admin_ID'] ?? '',
            'child_ID': data['child_ID'] ?? '',
            'child_email': data['child_email'] ?? '',
            'full_name': data['full_name'] ?? '',
          };
          //StaticId.presentId += "";
          print('10');
          String parentId = userData['admin_ID'] ?? '';
          emailrt = userData['child_email'] ?? '';
          firstName = userData['full_name'] ?? '';

          if (emailrt.isNotEmpty) {
            print('11');
            print(
                'present admin id of child from static class == ${StaticId.presentId}');
            prefs.setString('role_from_SP', 'child');
            prefs.setString('child_email', emailrt);
            prefs.setString('child_name', firstName);
            prefs.setString('parent_ID', parentId);
            setEmailPassToPref();
            //LoadingUtil.hideLoading(context);
            //var check = checkBoxId();
            //LoadingUtil.hideLoading(context);
            // Navigate to the next screen after successful login
            print('12');
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => DashboardPage()));

            //_showSnackbar('Child Login');
          } else {
            print('else 13');
            //StaticId.presentId += "";
            //StaticId.presentId += byEmailUserId;
            prefs.setString('role_from_SP', 'admin');
            prefs.setString('parent_ID', byEmailUserId);
            setEmailPassToPref();
            //var check = checkBoxId();
            // Navigate to the next screen after successful login
            //LoadingUtil.hideLoading(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => DashboardPage()));
            //_showSnackbar('Admin Login');
          }
        } else {
          print('last else');
          LoadingUtil.hideLoading(context);
          //StaticId .setId(FirebaseAuth.instance.currentUser!.uid);
        }
      });
    } catch (e) {
      LoadingUtil.hideLoading(context);
      print(e);
    }
  }

  Future<void> checkUserGoogle(String id) async {
    final SharedPreferences prefs = await _prefs;
    try {
      DatabaseReference dref;
      dref = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child('users_details')
          .child(id);
      dref.onValue.listen((event) {
        final data = event.snapshot.value;
        if (data != null && data is Map<dynamic, dynamic>) {
          Map<String, dynamic> userData = {
            'admin_ID': data['admin_ID'] ?? '',
            'child_ID': data['child_ID'] ?? '',
            'child_email': data['child_email'] ?? '',
            'full_name': data['full_name'] ?? '',
          };
          String parentId = userData['admin_ID'] ?? '';
          String emailrt = userData['child_email'] ?? '';
          String firstName = userData['full_name'] ?? '';

          if (emailrt.isNotEmpty) {
            prefs.setString('role_from_SP', 'child');
            prefs.setString('child_email', emailrt);
            prefs.setString('child_name', firstName);
            prefs.setString('parent_ID', parentId);
            setEmailPassToPref();

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DashboardPage()),
            );
            _showSnackbar('Child Login');
          } else {
            prefs.setString('role_from_SP', 'admin');
            prefs.setString('parent_ID', id);
            setEmailPassToPref();

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DashboardPage()),
            );
            _showSnackbar('Admin Login');
          }
        } else {
          // Handle the case when user data is not found
          // You may want to show an error message or take appropriate action
        }
      });
    } catch (e) {
      print(e);
    }
  }

  //Login with google

  // Future<User?> _handleSignInWithGoogle() async {
  //   try {
  //     final GoogleSignInAccount? googleSignInAccount =
  //         await googleSignIn.signIn();
  //     final GoogleSignInAuthentication googleSignInAuthentication =
  //         await googleSignInAccount!.authentication;
  //
  //     final AuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleSignInAuthentication.accessToken,
  //       idToken: googleSignInAuthentication.idToken,
  //     );
  //
  //     final UserCredential authResult =
  //         await _auth.signInWithCredential(credential);
  //     final User? user = authResult.user;
  //     checkUserExistsInDatabase(user);
  //
  //   } catch (error) {
  //     if (kDebugMode) {
  //       clearPreferences();
  //       print('Google Sign-In Error: $error');
  //     }
  //     return null;
  //   }
  // }

  static Future<void> clearPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

// Toggle visible
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText; // Toggle password visibility
    });
  }

  Future<void> _fingerAuthentication() async {
    try {
      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Authenticate to access your account',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
        ),
        // Show system dialogs for errors
      );

      if (didAuthenticate) {
        // Authentication successful, you can navigate to the main screen here.
        final SharedPreferences prefs = await _prefs;
        var g = prefs.getString('email');
        var p = prefs.getString('password');

        if (g != null && p != null) {
          //_updateFCMToken(authFCMToken);
          if (kDebugMode) {
            print('Authentication successful');
          }
          //_showSnackbar('Authentication successful');
          //_showSnackbar("Pref is NOT NULL");
          //LoadingUtil.hideLoading(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DashboardPage()),
          );
        } else {
          _showSnackbar("Login with email & password first!");
        }
      } else {
        if (kDebugMode) {
          print('Authentication failed');
        }
        _showSnackbar('Authentication failed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  void _showSnackbar(String msg) {
    final snackbar = SnackBar(
      content: Text(msg),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _notificationService.requestNotificationPermission();
    _notificationService.requestLocationPermission();
    //_initializeFCM();
  }

  @override
  Widget build(BuildContext context) {
    String initialMessage = rememberChecked ? '$userEmail' : '';
    return Scaffold(
        body: Form(
      key: _formKey,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 60,
              ),
              const Text(
                "Log In",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Sign in to your Account!",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value!.isEmpty || !value.contains('@')) {
                      return 'Please enter a valid email address.';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter Email',
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xFF17C3CE), // Border color
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  validator: (value) {
                    if (value!.isEmpty || value.length < 6) {
                      return 'Password must be at least 6 characters.';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter Password',
                    suffixIcon: GestureDetector(
                      onTap: _togglePasswordVisibility,
                      child: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color(0xFF17C3CE), width: 2.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: rememberChecked,
                        onChanged: (value) {
                          setState(() {
                            rememberChecked = value!;
                            // Update the message when the checkbox value changes
                            _emailController.text = rememberChecked ? '$userEmail' : '';
                          });
                        },
                      ),
                      const Text(
                        'Remember Me',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ForgotPassword()),
                            );
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Color(0xFF17C3CE),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
                    _loginWithEmailAndPassword();
                  },
                  child: const Text('Sign In'),
                ),
              ),
              const SizedBox(height: 40),
              const Padding(
                padding: EdgeInsets.only(left: 16.0, right: 16.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Divider(),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('OR'),
                    ),
                    Expanded(
                      child: Divider(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                // Space from the sides
                width: double.infinity,
                // Full width
                height: 60.0,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  // Background color
                  borderRadius: BorderRadius.circular(30.0),
                  // Rounded sides
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
                child: FilledButton.icon(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                  ),
                  onPressed: () {
                    //LoadingUtil.showLoading(context);
                    signInWithGoogle();
                  },
                  icon: SvgPicture.asset(
                    'images/googlelogo.svg', // Icon color
                    width: 24, // Icon width
                    height: 24, // Icon height
                  ),
                  label: const Text('Continue with Google',
                      style: TextStyle(color: Colors.grey)),
                ),
              ),
              const SizedBox(
                height: 15.0,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                // Space from the sides
                width: double.infinity,
                // Full width
                height: 60.0,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  // Background color
                  borderRadius: BorderRadius.circular(30.0),
                  // Rounded sides
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
                child: FilledButton.icon(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black),
                  ),
                  onPressed: () async {
                    final appleCredential = await SignInWithApple.getAppleIDCredential(
                      scopes: [
                        AppleIDAuthorizationScopes.email,
                        AppleIDAuthorizationScopes.fullName,
                      ],
                    );

                    final authCredential = OAuthProvider("apple.com").credential(
                      idToken: appleCredential.identityToken,
                    );
                    return await FirebaseAuth.instance.signInWithCredential(authCredential).then((value) {
                      String? email = value.user?.email;
                      String? id = value.user?.uid;
                      byEmailUserId = value.user!.uid;
                      emailModel = EmailModel(email: email.toString());
                      print('model : ${emailModel}');
                      //'users/users_details/$email'
                      //prefs.setString('email_googlelogin', email.toString());
                      print('Email from Google login g_email $email');
                      print('id from Google $id');

                      // final userRef = _database
                      //     .child('users')
                      //     .child('users_details')
                      //     .child('email')
                      //     .equalTo(email);
                      // final snapshot = await userRef.onValue;

                      if (id!.isNotEmpty) {
                        LoadingUtil.hideLoading(context);
                        // checkUser(userCredential.user!.uid);
                        checkGoogleUserExistsInDatabase(id);
                        // Navigate to dashboard page
                      } else {
                        LoadingUtil.hideLoading(context);
                        print('New user, proceed to signup and OTP');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      }
                      debugPrint("+++++++++++++++++++${value.user!.email}");
                    });
                  },
                  icon: SvgPicture.asset(
                    'images/applelogo.svg', // Icon color
                    width: 24, // Icon width
                    height: 24, // Icon height
                  ),
                  label: const Text('Continue with Apple',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(
                height: 15.0,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                // Space from the sides
                width: double.infinity,
                // Full width
                height: 60.0,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  // Background color
                  borderRadius: BorderRadius.circular(30.0),
                  // Rounded sides
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
                child: FilledButton.icon(
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.white),
                  ),
                  onPressed: _fingerAuthentication,
                  icon: const Icon(
                    Icons.fingerprint,
                    color: Color(0xFF17C3CE),
                  ),
                  label: const Text(
                    'Sign In With Fingerprint',
                    style: TextStyle(
                      color: Color(0xFF17C3CE),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 60,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const VerifyNumberPage()),
                  );
                },
                child: const Text(
                  "Don't have an account? Create New",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Color(0xFF17C3CE),
                  ),
                ),
              ),
              const SizedBox(
                height: 28,
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Future<void> setEmailPassToPref() async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('email', _emailController.text.toString().trim());
    prefs.setString('password', _passwordController.text.toString().trim());
    prefs.setString('userID', userUID);
    var getEmail = prefs.getString('email');
    var getPassword = prefs.getString('password');
    var getUID = prefs.getString('userID');

    if (kDebugMode) {
      print('PREF EMAIL = $getEmail');
      print('PREF PASSWORD = $getPassword');
      print('PREF UID = $getUID');
    }
  }

  Future<void> setGoogleDataToPref(String gemail, String gid) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('g_email', gemail);
    prefs.setString('g_userID', gid);
    var getEmail = prefs.getString('g_email');
    var getUID = prefs.getString('g_userID');
    StaticId.presentEmail = getEmail.toString();
      print('PREF Google_EMAIL g_email = $getEmail');
      print('PREF Google_UID = $getUID');

  }

  Future<void> getEmailPassFromPref() async {
    final SharedPreferences prefs = await _prefs;
    userEmail = prefs.getString('email');
    prefs.getString('password');
  }

  Future<bool> checkUserExistsInDatabase(String id) async {
      final databaseReference = FirebaseDatabase.instance.ref();
      DataSnapshot dataSnapshot;

      try {
        DatabaseEvent databaseEvent = await databaseReference
            .child('users')
            .child('users_details')
            .child(id)
            .once();

        dataSnapshot = databaseEvent.snapshot;

        if (dataSnapshot.value != null) {
          checkUser(id);
        } else {
          setState(() {
            clearPreferences();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VerifyNumberPage()),
            );
          });
        }
      } catch (error) {
        print('Error checking user existence in the database: $error');
        return false;
      }

      return dataSnapshot.value !=
          null; // Returns true if the user exists, false otherwise

  }
  Future<bool> checkGoogleUserExistsInDatabase(String id) async {
    final databaseReference = FirebaseDatabase.instance.ref();
    DataSnapshot dataSnapshot;

    try {
      DatabaseEvent databaseEvent = await databaseReference
          .child('users')
          .child('users_details')
          .child(id)
          .once();

      dataSnapshot = databaseEvent.snapshot;

      if (dataSnapshot.value != null) {
        checkUser(id);
      } else {
        setState(() {
          clearPreferences();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GoogleVerifyNumberPage()),
          );
        });
      }

      // Assuming 'users' is the node where user information is stored in the database
      print('user exists in realtime');
    } catch (error) {
      print('Error checking user existence in the database: $error');
      return false;
    }

    return dataSnapshot.value !=
        null; // Returns true if the user exists, false otherwise

  }

  Future<void> signInWithGoogle() async {
    final SharedPreferences prefs = await _prefs;
    LoadingUtil.showLoading(context);
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser != null) {
      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;
      if (googleAuth != null) {
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final userCredential = await _auth.signInWithCredential(credential);
        print('user credential : ${userCredential.user}');
        print('credential : ${userCredential}');

        // Check if email exists in Realtime Database
        String? email = userCredential.user?.email;
        String? id = userCredential.user?.uid;
        byEmailUserId = userCredential.user!.uid;
         emailModel = EmailModel(email: email.toString());
         print('model : ${emailModel}');
        //'users/users_details/$email'
        prefs.setString('email_googlelogin', email.toString());
        print('Email from Google login g_email $email');
        print('id from Google $id');

        // final userRef = _database
        //     .child('users')
        //     .child('users_details')
        //     .child('email')
        //     .equalTo(email);
        // final snapshot = await userRef.onValue;

        if (id!.isNotEmpty) {
          LoadingUtil.hideLoading(context);
          // checkUser(userCredential.user!.uid);
          checkGoogleUserExistsInDatabase(id);
          // Navigate to dashboard page
        } else {
          LoadingUtil.hideLoading(context);
          print('New user, proceed to signup and OTP');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      } else {
        throw Exception('Google authentication failed');
      }
    } else {
      throw Exception('Google Sign-In failed');
    }
  }


  // Future<void> _checkInternetConnection() async {
  //   var connectivityResult = await (Connectivity().checkConnectivity());
  //
  //   if (connectivityResult == ConnectivityResult.none) {
  //     _showNoInternetDialog();
  //   }
  // }

  // Future<void> _showNoInternetDialog() async {
  //   return showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('No Internet'),
  //         content: Text('Please check your internet connection.'),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: Text('OK'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
