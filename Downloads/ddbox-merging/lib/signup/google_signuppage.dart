import 'package:country_code_picker/country_code_picker.dart';
import 'package:ddbox/dashboard/dashboard.dart';
import 'package:ddbox/login/loginpage.dart';
import 'package:ddbox/maps/google_map.dart';
import 'package:ddbox/models/loading.dart';
import 'package:ddbox/models/static_id_class.dart';
import 'package:ddbox/verify_number/manual_verifynumberpage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_database/firebase_database.dart';

class GoogleSignupPage extends StatefulWidget {
  final String dataFromMap;

  const GoogleSignupPage({super.key, required this.dataFromMap});

  @override
  State<GoogleSignupPage> createState() => _GoogleSignupPageState();
}

class _GoogleSignupPageState extends State<GoogleSignupPage> {
  DateTime selectedDate = DateTime.now();
  bool _obscureText = true; // Initially hide the password
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  //signup with email & password
  final DatabaseReference _userRef =
      FirebaseDatabase.instance.ref().child("users").child("users_details");

  //Fields controller
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileNoController = TextEditingController();
  final TextEditingController _addressNoController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();

  //final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _addresslabelController = TextEditingController();
  bool _agreedToTerms = false;
  var getAddress = '';
  late String selectedCountryCode;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late String fcmToken;
  String? selectedCountry;
  List<String> countries = [
    'Afghanistan',
    'Albania',
    'Algeria',
    'Andorra',
    'Angola',
    'Antigua and Barbuda',
    'Argentina',
    'Armenia',
    'Australia',
    'Austria',
    'Azerbaijan',
    'Bahamas',
    'Bahrain',
    'Bangladesh',
    'Barbados',
    'Belarus',
    'Belgium',
    'Belize',
    'Benin',
    'Bhutan',
    'Bolivia',
    'Bosnia and Herzegovina',
    'Botswana',
    'Brazil',
    'Brunei',
    'Bulgaria',
    'Burkina Faso',
    'Burundi',
    'Cabo Verde',
    'Cambodia',
    'Cameroon',
    'Canada',
    'Central African Republic',
    'Chad',
    'Chile',
    'China',
    'Colombia',
    'Comoros',
    'Congo',
    'Costa Rica',
    'Croatia',
    'Cuba',
    'Cyprus',
    'Czechia',
    'Denmark',
    'Djibouti',
    'Dominica',
    'Dominican Republic',
    'Ecuador',
    'Egypt',
    'El Salvador',
    'Equatorial Guinea',
    'Eritrea',
    'Estonia',
    'Eswatini',
    'Ethiopia',
    'Fiji',
    'Finland',
    'France',
    'Gabon',
    'Gambia',
    'Georgia',
    'Germany',
    'Ghana',
    'Greece',
    'Grenada',
    'Guatemala',
    'Guinea',
    'Guinea-Bissau',
    'Guyana',
    'Haiti',
    'Honduras',
    'Hungary',
    'Iceland',
    'India',
    'Indonesia',
    'Iran',
    'Iraq',
    'Ireland',
    'Israel',
    'Italy',
    'Jamaica',
    'Japan',
    'Jordan',
    'Kazakhstan',
    'Kenya',
    'Kiribati',
    'Korea',
    'Kuwait',
    'Kyrgyzstan',
    'Laos',
    'Latvia',
    'Lebanon',
    'Lesotho',
    'Liberia',
    'Libya',
    'Liechtenstein',
    'Lithuania',
    'Luxembourg',
    'Madagascar',
    'Malawi',
    'Malaysia',
    'Maldives',
    'Mali',
    'Malta',
    'Marshall Islands',
    'Mauritania',
    'Mauritius',
    'Mexico',
    'Micronesia',
    'Moldova',
    'Monaco',
    'Mongolia',
    'Montenegro',
    'Morocco',
    'Mozambique',
    'Myanmar',
    'Namibia',
    'Nauru',
    'Nepal',
    'Netherlands',
    'New Zealand',
    'Nicaragua',
    'Niger',
    'Nigeria',
    'North Macedonia',
    'Norway',
    'Oman',
    'Pakistan',
    'Palau',
    'Palestine',
    'Panama',
    'Papua New Guinea',
    'Paraguay',
    'Peru',
    'Philippines',
    'Poland',
    'Portugal',
    'Qatar',
    'Romania',
    'Russia',
    'Rwanda',
    'Saint Kitts and Nevis',
    'Saint Lucia',
    'Saint Vincent and the Grenadines',
    'Samoa',
    'San Marino',
    'Sao Tome and Principe',
    'Saudi Arabia',
    'Senegal',
    'Serbia',
    'Seychelles',
    'Sierra Leone',
    'Singapore',
    'Slovakia',
    'Slovenia',
    'Solomon Islands',
    'Somalia',
    'South Africa',
    'South Sudan',
    'Spain',
    'Sri Lanka',
    'Sudan',
    'Suriname',
    'Sweden',
    'Switzerland',
    'Syria',
    'Taiwan',
    'Tajikistan',
    'Tanzania',
    'Thailand',
    'Timor-Leste',
    'Togo',
    'Tonga',
    'Trinidad and Tobago',
    'Tunisia',
    'Turkey',
    'Turkmenistan',
    'Tuvalu',
    'Uganda',
    'Ukraine',
    'United Arab Emirates',
    'United Kingdom',
    'United States',
    'Uruguay',
    'Uzbekistan',
    'Vanuatu',
    'Vatican City',
    'Venezuela',
    'Vietnam',
    'Yemen',
    'Zambia',
    'Zimbabwe',
  ];
  String byEmailUserId = "";

  Future<bool> checkUserExistsInDatabase(User? user) async {
    final databaseReference = FirebaseDatabase.instance.ref();
    DataSnapshot dataSnapshot;

    try {
      DatabaseEvent databaseEvent = await databaseReference
          .child('users')
          .child('users_details')
          .orderByChild(
              'email') // Assuming 'email' is the key you want to check
          .equalTo(user!.email) // Check if the email matches the user's email
          .once();

      dataSnapshot = databaseEvent.snapshot;

      if (dataSnapshot.value != null) {
        // User with the same email exists in the database
        print('User already exists in the database');
        return true;
      } else {
        // User doesn't exist in the database
        print('User does not exist in the database');
        return false;
      }
    } catch (error) {
      print('Error checking user existence in the database: $error');
      return false;
    }
  }

  //Country Code
  String initialCountry =
      'US'; // Replace with your desired initial country code.
  PhoneNumber number = PhoneNumber(
      isoCode: 'US'); // Replace with your desired initial country code.
  String phoneNumberWithCountryCode =
      ''; // Store the phone number with the country code.

  //Phone verification with Firebase
  String verificationId = "";

  Future<void> _verifyPhoneNumber(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verify on some devices
        UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        // Handle the signed-in user
        print("Auto verification completed: ${userCredential.user?.uid}");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      },
      verificationFailed: (FirebaseAuthException e) {
        print("Verification failed: $e");
      },
      codeSent: (String verificationId, int? resendToken) {
        print("Code sent to the provided phone number");
        this.verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print("Code auto retrieval timeout");
      },
    );
  }

  void _signInWithPhoneNumber(String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: smsCode);
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      // Handle the signed-in user
      print("User signed in: ${userCredential.user?.uid}");
    } catch (e) {
      print("Error signing in: $e");
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText; // Toggle password visibility
    });
  }

  void _showSnackbar(String msg) {
    final snackbar = SnackBar(
      content: Text('$msg'),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2099),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateOfBirthController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> signUpWithPhone(
      PhoneNumber phoneNumber, BuildContext context) async {
    try {
      final FirebaseAuth _auth = FirebaseAuth.instance;

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          UserCredential userCredential =
              await _auth.signInWithCredential(credential);
          // Handle the signed-in user
          print("Auto verification completed: ${userCredential.user?.uid}");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DashboardPage()),
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          // Handle verification failure
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Verification failed: ${e.code}")));
        },
        codeSent: (String verificationId, int? resendToken) {
          // Handle code sent
          // Store verificationId for later use
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle code auto retrieval timeout
        },
      );
    } catch (e) {
      // Handle any other exceptions
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getToken();
    _addressNoController.text = '${widget.dataFromMap}';
    getMobileFromPref();
    getemailFromPref();
    //getLocationFromPref();
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  void signOut() async {
    try {
      await _auth.signOut();
      _googleSignIn.signOut();
      clearPreferences();
      _showSnackbar("SignOut Successfully");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      // pref.removeData('email');
      // pref.removeData('password');
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  static Future<void> clearPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<Future> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Cancel'),
          content: const Text('Are you sure you want to go back from Signup?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User canceled the action
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed the action
                signOut();
              },
              child: const Text('SignOut'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Display a confirmation dialog when the user tries to go back
        bool shouldLogout =
            (await _showLogoutConfirmationDialog(context)) as bool;
        return shouldLogout;
      },
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    height: 40,
                  ),
                  const Text(
                    "New Account",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10.5,
                  ),
                  const Text(
                    "Create new Account",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: _firstNameController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Last Name';
                        }
                        if (value.length > 14) {
                          return 'Name Length Is Long';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        hintText: 'Enter First Name',
                        border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 2.0),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: _lastNameController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Last Name';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        hintText: 'Enter Last Name',
                        border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 2.0),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      enabled: true,
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
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 2.0),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: _dateOfBirthController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter DOB';
                        }
                        return null;
                      },
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      decoration: InputDecoration(
                        labelText: 'DOB',
                        hintText: 'Enter DOB',
                        //contentPadding: EdgeInsets.all(15.0),
                        border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 2.0),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),

                  //Nationality
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10 , right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Nationality'),
                            DropdownButton<String>(
                              value: selectedCountry,
                              hint: Text('Select Nationality'),
                              icon: Icon(Icons.arrow_drop_down),
                              iconSize: 24,
                              elevation: 16,
                              style: TextStyle(color: Colors.black),
                              onChanged: (String? newValue) { // Change the type to nullable
                                setState(() {
                                  selectedCountry = newValue;
                                  print('Selected Country  $selectedCountry');
                                });
                              },
                              items: countries.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),

                            ),
                            // CountryCodePicker(
                            //   onChanged: (CountryCode code) {
                            //     setState(() {
                            //       selectedCountryCode = code.name!;
                            //       print(
                            //           '============= from google $selectedCountryCode ==============');
                            //     });
                            //   },
                            //   showFlag: false,
                            //   showCountryOnly: true,
                            //   showOnlyCountryWhenClosed: true,
                            //   alignLeft: false,
                            //   showDropDownButton: true,
                            //   searchDecoration: InputDecoration(
                            //     border: OutlineInputBorder(
                            //       borderSide: const BorderSide(
                            //           color: Colors.blue, width: 2.0),
                            //       borderRadius: BorderRadius.circular(8.0),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: _nationalIdController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter National ID';
                        }
                        if (value.length < 14) {
                          return 'Invalid National ID';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'National ID',
                        hintText: 'Enter National ID',
                        border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 2.0),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      enabled: false,
                      controller: _mobileNoController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Mobile No required';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Mobile No',
                        hintText: 'Enter Mobile No',
                        border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 2.0),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      enabled: false,
                      controller: _addressNoController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Address Required';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Address',
                        hintText: 'Address',
                        border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 2.0),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MapPageGoogle()),
                        );
                      },
                      child: const Text('Edit Location'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: _addresslabelController,
                      decoration: InputDecoration(
                        labelText: 'Address label',
                        hintText: 'Address label (optional)',
                        border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 2.0),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: _agreedToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreedToTerms = value!;
                          });
                        },
                      ),
                      const Expanded(
                          child: Text(
                        'By continuing you accept our Privacy Policy and Term of Use',
                        style: TextStyle(
                          fontSize: 11.0,
                        ),
                      )),
                    ],
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
                        if (_formKey.currentState!.validate() &&
                            _agreedToTerms) {
                          LoadingUtil.showLoading(context);
                          signUpWithEmailAndPassword();
                        } else {
                          //LoadingOverlay.hide(context);
                          _showSnackbar("Data required");
                        }
                      },
                      child: const Text('Create Account'),
                    ),
                  ),
                  // ClipRRect(
                  //   borderRadius: BorderRadius.circular(40.0),
                  //   // Adjust the radius as needed
                  //   child: ElevatedButton(
                  //     onPressed: () {
                  //       setState(() {
                  //         phoneNumberWithCountryCode = number.toString();
                  //         //_verifyPhoneNumber("+923008175646");
                  //         signUpWithPhone("+923008175646" as PhoneNumber, context);
                  //       });
                  //       print(
                  //           'Mobile Number with Country Code: $phoneNumberWithCountryCode');
                  //     },
                  //     child: const Text('Create Account'),
                  //   ),
                  // ),
                  SizedBox(
                    height: 20.0,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      "Already have an account? Sign In",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Color(0xFF17C3CE),
                      ),
                    ),
                  ),
                  // const SizedBox(height: 20),
                  // const Padding(
                  //   padding: EdgeInsets.only(left: 16.0, right: 16.0),
                  //   child: Row(
                  //     children: <Widget>[
                  //       Expanded(
                  //         child: Divider(),
                  //       ),
                  //       Padding(
                  //         padding: EdgeInsets.symmetric(horizontal: 8.0),
                  //         child: Text('OR'),
                  //       ),
                  //       Expanded(
                  //         child: Divider(),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // const SizedBox(height: 20),
                  // Container(
                  //   margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  //   // Space from the sides
                  //   width: double.infinity,
                  //   // Full width
                  //   height: 60.0,
                  //   decoration: BoxDecoration(
                  //     color: Colors.blue, // Background color
                  //     borderRadius: BorderRadius.circular(30.0), // Rounded sides
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Colors.black.withOpacity(0.2),
                  //         // Shadow color and opacity
                  //         spreadRadius: 2,
                  //         // How far the shadow spreads
                  //         blurRadius: 4,
                  //         // The size of the shadow blur
                  //         offset: const Offset(0, 4), // Offset of the shadow
                  //       ),
                  //     ],
                  //   ),
                  //   child: FilledButton.icon(
                  //     style: ButtonStyle(
                  //       backgroundColor: MaterialStateProperty.all(Colors.white),
                  //     ),
                  //     onPressed: () async {
                  //       User? user = await _handleSignInWithGoogle();
                  //       // if (user != null) {
                  //       //   // User is signed in with Google.
                  //       //   print('User signed in: ${user.displayName}');
                  //       //   Navigator.push(
                  //       //     context,
                  //       //     MaterialPageRoute(
                  //       //         builder: (context) => const DashboardPage()),
                  //       //   );
                  //       // } else {
                  //       //   // Sign-in failed.
                  //       //   print('Google Sign-In failed.');
                  //       // }
                  //     },
                  //     icon: SvgPicture.asset(
                  //       'images/googlelogo.svg', // Icon color
                  //       width: 24, // Icon width
                  //       height: 24, // Icon height
                  //     ),
                  //     label: Text('Continue with Google',
                  //         style: TextStyle(color: Colors.grey)),
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: 15.0,
                  // ),
                  // Container(
                  //   margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  //   // Space from the sides
                  //   width: double.infinity,
                  //   // Full width
                  //   height: 60.0,
                  //   decoration: BoxDecoration(
                  //     color: Colors.blue, // Background color
                  //     borderRadius: BorderRadius.circular(30.0), // Rounded sides
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Colors.black.withOpacity(0.2),
                  //         // Shadow color and opacity
                  //         spreadRadius: 2,
                  //         // How far the shadow spreads
                  //         blurRadius: 4,
                  //         // The size of the shadow blur
                  //         offset: const Offset(0, 4), // Offset of the shadow
                  //       ),
                  //     ],
                  //   ),
                  //   child: FilledButton.icon(
                  //     style: ButtonStyle(
                  //       backgroundColor: MaterialStateProperty.all(Colors.black),
                  //     ),
                  //     onPressed: () {
                  //       //_handleSignInWithApple(context);
                  //       // Navigator.push(
                  //       //   context,
                  //       //   MaterialPageRoute(
                  //       //       builder: (context) => const DashboardPage()),
                  //       // );
                  //     },
                  //     icon: SvgPicture.asset(
                  //       'images/applelogo.svg', // Icon color
                  //       width: 24, // Icon width
                  //       height: 24, // Icon height
                  //     ),
                  //     label: Text('Continue with Apple',
                  //         style: TextStyle(color: Colors.white)),
                  //   ),
                  // ),

                  // Container(
                  //   margin: const EdgeInsets.symmetric(horizontal: 16.0), // Space from the sides
                  //   width: double.infinity, // Full width
                  //   height: 60.0,
                  //   decoration: BoxDecoration(
                  //     color: Colors.blue, // Background color
                  //     borderRadius: BorderRadius.circular(30.0), // Rounded sides
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Colors.black.withOpacity(0.2), // Shadow color and opacity
                  //         spreadRadius: 2, // How far the shadow spreads
                  //         blurRadius: 4, // The size of the shadow blur
                  //         offset: const Offset(0, 4), // Offset of the shadow
                  //       ),
                  //     ],
                  //   ),
                  //   child: FilledButton.icon(
                  //     style: const ButtonStyle(
                  //       backgroundColor: MaterialStatePropertyAll(Colors.black),
                  //     ),
                  //     onPressed: () {
                  //       //_handleSignInWithApple(context);
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //             builder: (context) => const DashboardPage()),
                  //       );
                  //     },
                  //     icon: const Icon(Icons.apple , color: Colors.white,),
                  //     label: const Text('' , style: TextStyle(
                  //       color: Colors.white,
                  //     ),),
                  //   ),
                  // ),
                  SizedBox(
                    height: 15.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> getToken() async {
    fcmToken = (await _firebaseMessaging.getToken())!;
    print("FCM Token from signup: $fcmToken");

// Print or use the token as needed
  }

  void signUpWithEmailAndPassword() async {
    final SharedPreferences prefs = await _prefs;
    User? user = _auth.currentUser;
    try {
      String userId = user!.uid;
      byEmailUserId = user!.uid;
      if (fcmToken != null) {
        _userRef.child(userId).set({
          'first_name': _firstNameController.text.toString(),
          'last_name': _lastNameController.text.toString(),
          'email': _emailController.text.toString(),
          'date_of_birth': _dateOfBirthController.text.toString(),
          'nationality': selectedCountry.toString(),
          'fcm_token': fcmToken.toString(),
          'box_id': 1122,
          'mobile_no': _mobileNoController.text.toString(),
          'address': _addressNoController.text.toString(),
          'national_id': _nationalIdController.text.toString(),
          'uid': userId.toString(),
          'label': _addresslabelController.text.toString(),
          'device_commands': {
            'push_button': false,
          },
          'app_commands': {
            'lock': true,
            'unlock': false,
            'language': 'English',
            'otp': false,
          },
          'status': {
            'door_status': false,
            'humidity': 42.2,
            'lock_status': true,
            'pincode': 'None',
            'temperature': 11.5,
          },
        });
        LoadingUtil.hideLoading(context);
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
        // checkUser(userId);
        // User signed up successfully
        print("User signed up: $userId");
      } else {
        LoadingUtil.hideLoading(context);
        print('FCM token is empty');
      }

      // Add user data to the Realtime Database
    } catch (e) {
      LoadingUtil.hideLoading(context);
      if (e is FirebaseAuthException) {
        // Check if the error is due to a user already existing
        if (e.code == 'email-already-in-use') {
          // Display a message indicating that the user already exists
          print("User already exists with this email.");
          _showSnackbar("User already exists with this email.");
        } else {
          // Handle other sign-up errors
          print("Error: ${e.message}");
        }
      }
    }
  }

  Future<void> setEmailPassToPref() async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('email', _emailController.text.toString().trim());
    prefs.setString('userID', byEmailUserId);
    var getEmail = prefs.getString('email');
    var getUID = prefs.getString('userID');

    if (kDebugMode) {
      print('PREF EMAIL = $getEmail');
      print('PREF UID = $getUID');
    }
  }

  Future<void> setUidInPref(String uid) async {
    final SharedPreferences prefs = await _prefs;
    var user_id = prefs.setString('user_uid', uid.toString());
    print('User_id = $user_id');
    _showSnackbar('uid added in PREF');
  }

  Future<void> getMobileFromPref() async {
    final SharedPreferences prefs = await _prefs;
    var mob = prefs.getString('mobileNumber');
    _mobileNoController.text = mob.toString();
    print('get Mobile no from pref $mob');
  }
  Future<void> getemailFromPref() async {
    final SharedPreferences prefs = await _prefs;
    var eml = prefs.getString('g_email');
    // _emailController.text = eml.toString();
    _emailController.text = StaticId.presentEmail;
    print('get g_email from pref $eml');
    print('get g_email from staticId ${StaticId.presentEmail}');
  }

  Future<void> getLocationFromPref() async {
    final SharedPreferences prefs = await _prefs;
    getAddress = prefs.getString('mAddress')!;
    _addressNoController.text = getAddress.toString();
    print('get address from pref $getAddress');
  }

  Future<void> clearSpecificValue(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }
}

