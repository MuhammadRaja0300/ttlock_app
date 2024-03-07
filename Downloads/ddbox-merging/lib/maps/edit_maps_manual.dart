import 'package:ddbox/models/loading.dart';
import 'package:ddbox/signup/google_signuppage.dart';
import 'package:ddbox/signup/manual_signuppage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditMapPageManual extends StatefulWidget {
  @override
  _EditMapPageManualState createState() => _EditMapPageManualState();
}

class _EditMapPageManualState extends State<EditMapPageManual> {
  GoogleMapController? mapController;
  LatLng _currentLocation = LatLng(0, 0); // Default location
  Marker? _currentLocationMarker;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Set<Marker> markers = {};
  String address = '';
  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
      apikey:
      'AIzaSyBzsHuZLjSFX3D8OqapBpbDKplBlVVL4bU';
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _getUserLocation();
      apikey:
      'AIzaSyBzsHuZLjSFX3D8OqapBpbDKplBlVVL4bU';
    });
    //_checkLocationPermission();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Location'),
      ),
      body: Column(
        children: [
          Flexible(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              onTap: _handleTap,
              onLongPress: _handleTap,
              markers: markers,
              initialCameraPosition: CameraPosition(
                target: LatLng(0, 0),
                //_currentLocation,
                zoom: 18.0,
              ),
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              // markers: Set.from([
              //   if (_pickedLocation != null)
              //     Marker(
              //       markerId: MarkerId('pickedLocation'),
              //       position: _pickedLocation,
              //     ),
              // ]),
              // {
              //   if (_currentLocationMarker != null) _currentLocationMarker!,
              // },
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: ElevatedButton(
          //     onPressed: () {
          //       _getUserLocation();
          //     },
          //     child: Text('Get My Location'),
          //   ),
          // ),
        ],
      ),
    );
  }
  Future<void> setStringToPref(String mKey, String mValve) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('$mKey', mValve);
  }
  Future<void> setLocationToPref(String address) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('address', address);
    var getLocation = prefs.getString('address');

    if (kDebugMode) {
      print('PREF Address = $getLocation');
    }
  }

  // Function to get the user's current location
  void _getUserLocation() async {
    var status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      LoadingUtil.showLoading(context);
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best);
          _currentLocation = LatLng(position.latitude, position.longitude);
          LoadingUtil.hideLoading(context);

        // Reverse geocoding to get address from coordinates
        List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

        if (placemarks.isNotEmpty) {
          setState(() {
            Placemark placemark = placemarks[0];
            String address = "${placemark.name}, ${placemark.locality}, ${placemark.administrativeArea} ${placemark.postalCode}, ${placemark.country}";
            //setLocationToPref(address);
            //_showSnackbar('Address: $address');


            _currentLocationMarker = Marker(
              markerId: MarkerId('current_location'),
              position: _currentLocation,
              infoWindow: InfoWindow(
                title: "Your Location",
                snippet: address,
              ),
            );
          });

        } else {
          _showSnackbar('No address found');
        }

        // Move the camera to the user's current location on the map
        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _currentLocation ?? LatLng(0, 0),
              zoom: 13.0,
            ),
          ),
        );

      } catch (e) {
        _showSnackbar('Error getting location: $e');
      }
    } else {
      _showSnackbar('Location Permission Denied');
    }
  }

  Future<void> _handleTap(LatLng tappedPoint) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        tappedPoint.latitude, tappedPoint.longitude);

    String address = "No address found";
    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks[0];
      address =
      "${placemark.name}, ${placemark.locality}, ${placemark.administrativeArea} ${placemark.postalCode}, ${placemark.country}";
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding:
                    const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          markers.clear();
                          Navigator.pop(context);
                        });
                      },
                      child: Icon(
                        Icons.close,
                      ),
                    ),
                  ),
                ],
              ),

              ListTile(
                title: Text('Address: $address'),
              ),
              // ListTile(
              //   title: Text('Latitude: ${tappedPoint.latitude}'),
              // ),
              // ListTile(
              //   title: Text('Longitude: ${tappedPoint.longitude}'),
              // ),
              Container(
                child: Center(
                  child: ButtonBar(
                    children: [
                      // ElevatedButton(
                      //   onPressed: () {
                      //     // Implement your share functionality here
                      //     print('Sharing location: $address');
                      //     Share.share(address);
                      //     //Navigator.pop(context); // Close the bottom sheet
                      //   },
                      //   child: Text('Share'),
                      // ),
                      ElevatedButton(
                        onPressed: () {
                          setStringToPref('mEmail', address.toString());
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignupPage(dataFromMap: address)),
                          );
                          print('mEmail saved : $address');



                          markers.clear();
                          //Navigator.pop(context); // Close the bottom sheet
                        },
                        child: Text('Add'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    setState(() {
      markers.clear(); // Remove existing markers
      markers.add(
        Marker(
          markerId: MarkerId(tappedPoint.toString()),
          position: tappedPoint,
          infoWindow: InfoWindow(
            title: 'Tapped Location',
            snippet:
            'Address: $address',
            //\nLatitude: ${tappedPoint.latitude}, Longitude: ${tappedPoint.longitude}
          ),
        ),
      );
    });

    // You can also get the tapped location's coordinates here and use them as needed.
    print('Tapped Location: ${tappedPoint.latitude}, ${tappedPoint.longitude}');
  }
  void _showSnackbar(String msg) {
    final snackbar = SnackBar(
      content: Text('$msg'),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
  // void _checkLocationPermission() async {
  //   var status = await Permission.location.request();
  //   if (status == PermissionStatus.granted) {
  //     _showSnackbar('Permission Granted');
  //   } else if (status == PermissionStatus.denied) {
  //     _showPermissionDeniedSnackbar();
  //   }
  // }
  //
  // void _showPermissionDeniedSnackbar() {
  //   final snackBar = SnackBar(
  //     content: Text('Location permission denied'),
  //     action: SnackBarAction(
  //       label: 'Open Settings',
  //       onPressed: () {
  //         _openAppSettings();
  //       },
  //     ),
  //   );
  //
  //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
  // }
  //
  // Future<void> _openAppSettings() async {
  //   await openAppSettings();
  // }

  void _checkLocationPermission() async {
    var status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      _showSnackbar('Permission Granted');
    }else{
      _showSnackbar('Permission Denied');

    }

  }



}


