import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  TextEditingController locationController = TextEditingController();
  var latOfUser;
  var longOfUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Map'),
      ),
      body: Stack(
        children: [
          Container(
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                setState(() {
                  mapController = controller;
                });
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(37.7749, -122.4194),
                zoom: 15.0,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
          Positioned(
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
            child: ElevatedButton(
              onPressed: () {
                getCurrentLocation();
              },
              child: Text('Get Current Location'),
            ),
          ),
          Positioned(
            bottom: 80.0,
            left: 16.0,
            right: 16.0,
            child: TextField(
              controller: locationController,
              decoration: InputDecoration(
                hintText: 'Current Location',
                enabled: true,
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void getCurrentLocation() async {
    var status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        LatLng userLocation = LatLng(position.latitude, position.longitude);

        mapController!.animateCamera(CameraUpdate.newLatLng(userLocation));

        // Update the text field with the current location
        locationController.text =
        'Latitude: ${userLocation.latitude}, Longitude: ${userLocation.longitude}';
        latOfUser = position.latitude;
        longOfUser = position.longitude;
        _showSnackbar('Lat : ${position.latitude} , Long : ${position.longitude}');
      } catch (e) {
        print('Error getting current location: $e');
      }
    } else {
      print('Location permission denied');
    }
  }
  void _showSnackbar(String msg) {
    final snackbar = SnackBar(
      content: Text('$msg'),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}