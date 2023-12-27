import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

import 'package:intl/intl.dart';

import 'constants.dart';

String getCurrentDateTime() {
  now = DateTime.now();
  formattedDate = DateFormat('dd / MM / yyyy').format(now);
  formattedTime = DateFormat('HH:mm').format(now);

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
num convertToInt(List<int> data, int start, int size) {
  final buffer = List<int>.filled(size, 0);
  int converted = 0;

  for (var i = start, j = 0; i < start + size && j < size; i++, j++) {
    buffer[j] = data[i];
  }

  for (var i = 0; i < buffer.length; i++) {
    converted += buffer[i] << (8 * (size - i - 1));
  }

  return converted;
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
Future<void> getUserFields(String userId) async {
  QuerySnapshot querySnapshot = await firestore.collection('users').get();
  //get fields
  if (querySnapshot.docs.isNotEmpty) {
    testIDs = querySnapshot.docs.map((doc) => doc.id).toList();
    for(String id in testIDs){
      if(id.endsWith(userId)) {
        DocumentSnapshot userSnapshot = await firestore.collection('users').doc(userId).get();
        if (userSnapshot.exists) {
          Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;
          if (userData != null && userData.isNotEmpty) {
            sheikhName = userData['sheikh name'];
            sheikhPhone = userData['sheikh phone'];
            email = userData['user email'];
          }
        }
      }
    }
  }
  QuerySnapshot userSubcollection = await firestore.collection('users').doc(userId).collection('Cities').get();
  userMosquesIDs = userSubcollection.docs.map((doc) => doc.id).toList();
  for(String id in userMosquesIDs){
    DocumentSnapshot userSnapshot = await firestore.collection('users').doc(userId).collection('Cities').doc(id).get();
    if (userSnapshot.exists) {
      Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;
      if (userData != null && userData.isNotEmpty) {
        area = id;
        mosque = userData['mosque'];
      }
    }

  }
}
