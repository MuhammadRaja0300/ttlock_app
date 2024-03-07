import 'dart:convert';
import 'package:ddbox/models/loading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ddbox/signup/google_signuppage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapDashboard extends StatefulWidget {
  final String address;

  const MapDashboard({super.key, required this.address});

  @override
  _MapPageGoogleState createState() => _MapPageGoogleState();
}

class _MapPageGoogleState extends State<MapDashboard> {
  GoogleMapController? mapController;
  LatLng _currentLocation = const LatLng(0, 0); // Default l
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Set<Marker> markers = {};
  late LatLng location;
  String result = '';
  String latFromAddress = '';
  String longFromAddress = '';

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
      _getLocationFromAddress();
      apikey:
      'AIzaSyBzsHuZLjSFX3D8OqapBpbDKplBlVVL4bU';
    });

  }

  Future<void> _getLocationFromAddress() async {
    if (widget.address.isNotEmpty) {
      //LoadingUtil.showLoading(context);
      try {
        List<Location> locations = await locationFromAddress(widget.address);
        print('*********************************  ${widget.address}  ***********************************');
          //LoadingUtil.hideLoading(context);
          _currentLocation = LatLng(locations.first.latitude, locations.first.longitude);
          _addMarkerFromAddress(widget.address);
          // markers.add(
          //   Marker(
          //     markerId: MarkerId('location'),
          //     position: _currentLocation,
          //     infoWindow: InfoWindow(title: 'Location'),
          //   ),
          // );
          mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(_currentLocation, 18.0),
          );

      } catch (e) {
        // Handle any errors that occurred during geocoding
        print('Error: $e');
      }
    } else {
      print('Address is null or empty');
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _getLocationFromAddress();
    });

  }

  @override
  Widget build(BuildContext context) {
    print('*********************************  ${widget.address}  ***********************************');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Location'),
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
                //UAE LAT 23.4241 , LONG 53.8478
                //_currentLocation,
                zoom: 18.0,
              ),
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> setLocationToPref(String saveAddress) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('address', saveAddress);
    var getLocation = prefs.getString('address');

    if (kDebugMode) {
      print('PREF Address = $getLocation');
    }
  }

  Future<void> setStringToPref(String mKey, String mValve) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('$mKey', mValve);
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
                          shareTXT(address);
                          markers.clear();
                          Navigator.pop(context); // Close the bottom sheet
                        },
                        child: Text('Share'),
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
            title: 'Address',
            snippet:
                '$address',
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

  Future<void> clearSpecificValue(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }


  void _checkLocationPermission() async {
    var status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      _showSnackbar('Permission Granted');
    }else{

      _showSnackbar('Permission Denied');

    }
  }

  Future<void> _addMarkerFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        LatLng location = LatLng(locations.first.latitude, locations.first.longitude);
        _addMarker(location, address);
        mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 15.0));
      } else {
        // Handle address not found
        print('Address not found');
      }
    } catch (e) {
      // Handle any errors that occurred during geocoding
      print('Error: $e');
    }
  }
  void _addMarker(LatLng position, String address) {
    markers.add(
      Marker(
        markerId: MarkerId(position.toString()),
        position: position,
        infoWindow: InfoWindow(
          title: 'Address',
          snippet: '$address',
        ),
        onTap: (){
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
                      title: Text('Address: ${widget.address}'),
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
                                shareTXT(widget.address);
                                markers.clear();
                                Navigator.pop(context); // Close the bottom sheet
                              },
                              child: Text('Share'),
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
        }
      ),
    );
    setState(() {});
  }

  void shareTXT(String txt) {
    Share.share(txt);
  }
  // Future<void> convertAddressToLatLng() async {
  //   try {
  //     List<Location> locations = await locationFromAddress(widget.address);
  //     if (locations.isNotEmpty) {
  //       setState(() {
  //         result = 'Latitude: ${locations.first.latitude}, Longitude: ${locations.first.longitude}';
  //         latFromAddress = locations.first.latitude.toString();
  //         longFromAddress = locations.first.longitude.toString();
  //         print('Lat ${locations.first.latitude}');
  //       });
  //     } else {
  //       setState(() {
  //         result = 'Address not found';
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       result = 'Error: $e';
  //     });
  //   }
  // }

}


