import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

import 'package:intl/intl.dart';

import 'constants.dart';

String getCurrentDateTime() {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd').format(now);
  String formattedTime = DateFormat('HH:mm:ss').format(now);

  print('Current Date: $formattedDate');
  print('Current Time: $formattedTime');
  return '$formattedTime / $formattedDate';
}


void getLocationData() async {
  Location location = Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      // Handle if location service is not enabled
      return;
    }
  }

  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      // Handle if location permission is not granted
      return;
    }
  }

  _locationData = await location.getLocation();
  // Now _locationData contains latitude and longitude
  double? latitude = _locationData.latitude;
  double? longitude = _locationData.longitude;
  print('Latitude: $latitude, Longitude: $longitude');
}
void getDocumentIDs() async {
  try {
    QuerySnapshot users = await FirebaseFirestore.instance.collection('users').get();
    QuerySnapshot Cities = await FirebaseFirestore.instance.collection('Cities').get();
    QuerySnapshot Mosques = await FirebaseFirestore.instance.collection('Mosques').get();
    if (Cities.docs.isNotEmpty) {
      citiesIDs = Cities.docs.map((doc) => doc.id).toList();
    }
    if (Mosques.docs.isNotEmpty) {
      mosquesIDs = Mosques.docs.map((doc) => doc.id).toList();
    }
    if (users.docs.isNotEmpty) {
      usersIDs = users.docs.map((doc) => doc.id).toList();
    }
  } catch (e) {
    print('Error retrieving documents: $e');
  }
}
String? validatePhoneNumber(String? value) {
  if (value == null || value.isEmpty) {
    return 'Phone number is required';
  }
  if (value.length != 11) {
    return 'Please enter a 11s-digit phone number';
  }
  // You can add more complex validation logic here if needed
  return null; // Return null if the input is valid
}