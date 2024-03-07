import 'package:country_code_picker/country_code_picker.dart';
import 'package:ddbox/dashboard/dashboard.dart';
import 'package:ddbox/login/loginpage.dart';
import 'package:ddbox/maps/edit_maps_manual.dart';
import 'package:ddbox/models/loading.dart';
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
import '../maps/maps_manual.dart';

class SignupPage extends StatefulWidget {
  final String dataFromMap;
  const SignupPage({super.key, required this.dataFromMap});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  DateTime selectedDate = DateTime.now();
  bool _obscureText = true; // Initially hide the password
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var getAddress = '';

  //signup with email & password
   DatabaseReference _userRef =
      FirebaseDatabase.instance.ref().child("users").child("users_details");
  late DatabaseReference _pushRef;


  //Fields controller
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mobileNoController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  //final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _addressNoController = TextEditingController();
  final TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _addresslabelController = TextEditingController();
  bool _agreedToTerms = false;
  late String selectedCountryCode;
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
  String firstName = '';
  String? adminUidInChild;
  String? uidInChild;
  String emailrt = '';
  String userUID = '';
  String byEmailUserId = "";


  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late String fcmToken;


  Future<bool> checkUserExistsInDatabase(User? user) async {
      final databaseReference = FirebaseDatabase.instance.ref();
      DataSnapshot dataSnapshot;

      try {
        DatabaseEvent databaseEvent = await databaseReference
            .child('users')
            .child('users_details')
            .orderByChild('email') // Assuming 'email' is the key you want to check
            .equalTo(user!.email)    // Check if the email matches the user's email
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


  //Signup with apple
  Future<void> _handleSignInWithApple(BuildContext context) async {
    try {
      final AuthorizationCredentialAppleID appleCredential =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // You can use the appleCredential for user registration or authentication.
      // For example, you can create a user account with the received user information.

      // Display user information from appleCredential.
      final String? userIdentifier = appleCredential.userIdentifier;
      final String? email = appleCredential.email;
      final String? givenName = appleCredential.givenName;
      final String? familyName = appleCredential.familyName;

      // Do something with the user information.

      // You can navigate to a new screen or perform other actions as needed.
    } catch (error) {
      print('Apple Sign-In Error: $error');
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

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pushRef = FirebaseDatabase.instance.ref().child("users").child("users_details");
      getToken();
      _addressNoController.text = '${widget.dataFromMap}';


    //getLocationFromPref();
  }
  Future<void> getLocationFromPref() async {
    final SharedPreferences prefs = await _prefs;
    getAddress = prefs.getString('address')!;
    _addressNoController.text = getAddress.toString();
    print('get address from pref $getAddress');
  }
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
                //First Name
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: _firstNameController,
                    validator: (value){
                      if(value!.isEmpty){
                        return 'Enter First Name';
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
                //Last Name
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: _lastNameController,
                    validator: (value){
                      if(value!.isEmpty){
                        return 'Enter Last Name';
                      }if(value.length > 14){
                        return 'Name Length Is Long';
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
                //Email
                Padding(
                  padding: const EdgeInsets.all(10.0),
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
                        borderSide:
                            const BorderSide(color: Colors.blue, width: 2.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                //DOB
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: _dateOfBirthController,
                    validator: (value){
                      if(value!.isEmpty){
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
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.5 , right: 12.5),
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Text('Nationality'),
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
                            // Container(
                            //   child: CountryCodePicker(
                            //     onChanged: (CountryCode code) {
                            //       setState(() {
                            //         selectedCountryCode = code.name!;
                            //         print('============= from manual $selectedCountryCode ==============');
                            //       });
                            //     },
                            //     //initialSelection: 'AE', // Initial country selection
                            //     //favorite: ['+92', 'PK'], // Favorite countries
                            //     showCountryOnly: true,
                            //     showFlag: false,
                            //     showOnlyCountryWhenClosed: true,
                            //     alignLeft: false,
                            //     showDropDownButton: true,
                            //     searchDecoration: InputDecoration(
                            //         border: OutlineInputBorder(
                            //           borderSide:
                            //           const BorderSide(color: Colors.blue, width: 2.0),
                            //           borderRadius: BorderRadius.circular(8.0),
                            //         ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Padding(
                //   padding: const EdgeInsets.all(10.0),
                //   child: TextFormField(
                //     controller: _nationalityController,
                //
                //     decoration: InputDecoration(
                //       labelText: 'Nationality',
                //       hintText: 'Enter Nationality',
                //       border: OutlineInputBorder(
                //         borderSide:
                //             const BorderSide(color: Colors.blue, width: 2.0),
                //         borderRadius: BorderRadius.circular(8.0),
                //       ),
                //     ),
                //   ),
                // ),
                //National ID
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: _nationalIdController,
                    keyboardType: TextInputType.number,
                    validator: (value){
                      if(value!.isEmpty){
                        return 'Enter National ID';
                      }if (value.length < 14){
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
                //Mobile Number
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    enabled: false,
                    controller: _mobileNoController,
                    validator: (value){
                      if(value!.isEmpty){
                        return 'Mobile Number Required';
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

                //Password
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: _passwordController,
                    validator: (value) {
                      if (value!.isEmpty || value.length < 6) {
                        return 'Password must be at least 6 characters.';
                      }
                      return null;
                    },
                    obscureText: _obscureText,
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
                        borderSide:
                            const BorderSide(color: Colors.blue, width: 2.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                //Address
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    enabled: false,
                    controller: _addressNoController,
                    validator: (value){
                      if(value!.isEmpty){
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
                        MaterialPageRoute(builder: (context) => EditMapPageManual()),
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
                //Check Box
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
                //Create Account
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
                      if (_formKey.currentState!.validate() && _agreedToTerms) {
                        signUpWithEmailAndPassword();
                      } else {
                        LoadingUtil.hideLoading(context);
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
                //Already Have Account?
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
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
                const SizedBox(height: 20),
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
                // //Continue With Google
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
                // //Apple
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
    );
  }

  Future<void> getToken() async {
    fcmToken = (await _firebaseMessaging.getToken())!;
    getMobileFromPref();
    print("FCM Token from signup: $fcmToken");

// Print or use the token as needed
//     print('1su');
//     print('2su');
//     print('3su');
//     print('4su');
//     print('5su');
//     print('6su');
//     print('7su');
//     print('8su');
  }

  Future<void> signUpWithEmailAndPassword() async {
    final SharedPreferences prefs = await _prefs;
    LoadingUtil.showLoading(context);

    User? user = _auth.currentUser;
    UserCredential userCredential =
    await _auth.createUserWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if(userCredential != null){
      try {
        //LoadingUtil.hideLoading(context);
        String userId = userCredential.user!.uid;
        byEmailUserId = userCredential.user!.uid.toString();
        print('user id 1 $userId');
        print('1');
        print('print FCM $fcmToken');
        _userRef.child(userId).set({
          'first_name': _firstNameController.text.toString(),
          'last_name': _lastNameController.text.toString(),
          'email': _emailController.text.toString(),
          'date_of_birth': _dateOfBirthController.text.toString(),
          'nationality': selectedCountry.toString(),
          'password': _passwordController.text.toString(),
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
        print('else 13');
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
      } catch (e) {
        //LoadingUtil.hideLoading(context);
        if (e is FirebaseAuthException) {
          LoadingUtil.hideLoading(context);
          // Check if the error is due to a user already existing
          if (e.code == 'email-already-in-use') {
            // Display a message indicating that the user already exists
            LoadingUtil.hideLoading(context);
            print("User already exists with this email.");
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
            _showSnackbar("User already exists with this email.");
          } else {
            // Handle other sign-up errors
            LoadingUtil.hideLoading(context);
            print("Error: ${e.message}");
          }
        }
      }
    }else{

    }

  }

  Future<void> checkUser(String id) async {
    print('7');
    final SharedPreferences prefs = await _prefs;
    try {
      print('8');
      _userRef.child(id).onValue.listen((event) {
        print('9');

        final data = event.snapshot!.value;
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
            LoadingUtil.hideLoading(context);
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => DashboardPage()));

            //_showSnackbar('Child Login');
          } else {
            LoadingUtil.hideLoading(context);
            print('else 13');
            //StaticId.presentId += "";
            //StaticId.presentId += byEmailUserId;
            prefs.setString('role_from_SP', 'admin');
            prefs.setString('parent_ID', byEmailUserId);
            setEmailPassToPref();
            //var check = checkBoxId();

            // Navigate to the next screen after successful login
            //LoadingUtil.hideLoading(context);
            Navigator.pushReplacement(context,
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

  Future<void> setEmailPassToPref() async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('email', _emailController.text.toString().trim());
    prefs.setString('password', _passwordController.text.toString().trim());
    prefs.setString('userID', byEmailUserId);
    var getEmail = prefs.getString('email');
    var getPassword = prefs.getString('password');
    var getUID = prefs.getString('userID');

    if (kDebugMode) {
      print('PREF EMAIL = $getEmail');
      print('PREF PASSWORD = $getPassword');
      print('PREF UID = $getUID');
    }
  }
  Future<void> getMobileFromPref() async {
    final SharedPreferences prefs = await _prefs;
    var mob = prefs.getString('mobileNumber');
    _mobileNoController.text = mob.toString();
    print('get Mobile no from pref $mob');
  }

}

