import 'dart:typed_data';

import 'package:azan/t_key.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';

import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

Future<String> getCurrentDateTime() async {
  try {
    DateTime currentTime = await NTP.now();
    formattedDate = DateFormat('EEE, dd / MM').format(currentTime);
    formattedTime = DateFormat('HH:mm:ss').format(currentTime);
    setYear = currentTime.year%100;
    // yearHex = setYear.toRadixString(16).padLeft(2, '0').toUpperCase();
    setMonth = currentTime.month;
    setDay = currentTime.day;
    setHour = currentTime.hour;
    setMinute = currentTime.minute;
    setSecond = currentTime.second;
    // composeBlePacket(0x01, [currentTime.year%100,currentTime.month,currentTime.day,currentTime.hour,currentTime.minute,currentTime.second], 'date');
    return '$formattedTime / $formattedDate';
  }
  catch (e) {
    print('Error fetching NTP time: $e');
    return '$e';
  }
}
List<int> splitIntToChunks(String value) {
  // Convert the int to a string
  // String stringValue = value;

  // Split the string into chunks of 2 digits
  List<String> chunks = [];
  for (int i = 0; i < value.length; i += 2) {
    chunks.add(value.substring(i, i + 2));
  }

  // Convert each chunk back to int
  List<int> result = chunks.map((chunk) => int.parse(chunk, radix: 16)).toList();

  return result;
}
void composeBlePacket(int command, List<int> data, String dataType){
  // setDate=[];
  // List<int> data = [setYear,setMonth,setDay,setHour,setMinute,setSecond];
  int startFrame = 0xAA;
  int endFrame = 0xAA;
  // final hexValues = data.map((value) => int.parse(value.toRadixString(16), radix: 16)).toList();//convert
  // print('object=> $hexValues');
  // print('object=> $splitValues');
  switch(dataType){
    // case 'date':
    //   setDate.add(startFrame);
    //   setDate.add(command);
    //   setDate.add(data.length);
    //   setDate.addAll(hexValues);
    //   int value = calculateChecksum(setDate,1, setDate.length-1);
    //   setDate.add(value);
    //   setDate.add(endFrame);
    //   break;
    case 'location':
      setLocation = [];
      final hexValues = data.map((value) => value.toRadixString(16)).toList();//convert
      var splitValues = splitIntToChunks('0${hexValues[0]}');
      splitValues.addAll(splitIntToChunks('0${hexValues[1]}'));
      setLocation.add(startFrame);
      setLocation.add(command);
      setLocation.add(splitValues.length);
      setLocation.addAll(splitValues);
      int value = calculateChecksum(setLocation,1, setLocation.length-1);
      setLocation.add(value);
      setLocation.add(endFrame);
      print('setLocation => $setLocation');
      break;
    case 'zone':
      setZone = [];
      setZone.add(startFrame);
      setZone.add(command);
      setZone.add(data.length);
      setZone.addAll(data);
      int value = calculateChecksum(setZone,1, setZone.length-1);
      setZone.add(value);
      setZone.add(endFrame);
      break;
  }

}
int calculateChecksum(List<int> packet, int start, int end) {
  int checksum = 0;
  for (int i = start; i <= end; i++) {
    checksum += packet[i];
  }
  return checksum;
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
      for(String id in mosquesIDs){
        DocumentSnapshot querySnapshot = await FirebaseFirestore.instance.collection('Mosques').doc(id).get();
        if (querySnapshot.exists) {
          Map<String, dynamic>? userData = querySnapshot.data() as Map<String, dynamic>?;
          if (userData != null && userData.isNotEmpty) {
            dataList.add(userData['mosque']);
          }
        }
      }
      print('dataList => $dataList');
    }
    if (users.docs.isNotEmpty) {
      usersIDs = users.docs.map((doc) => doc.id).toList();
    }
  } catch (e) {
    print('Error retrieving documents: $e');
  }
}
void getMosquesList(String value) async{
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Cities').doc(value).collection('Mosques').get();
  if (querySnapshot.docs.isNotEmpty) {
    dataList = querySnapshot.docs.map((doc) => doc.id).toSet();
  }
  else{
    dataList = {};
  }
}
void getLongitude() async {
  try {
    // QuerySnapshot Cities = await FirebaseFirestore.instance.collection('Cities').get();
    // if (Cities.docs.isNotEmpty) {
    //   List locationIds = Cities.docs.map((doc) => doc.id).toList();
    //   print(locationIds);
    //   for(String id in citiesIDs){
    //     if(id.endsWith(area)) {
    print('here');
          DocumentSnapshot userSnapshot = await firestore.collection('Cities').doc(storedArea).get();
    print('here => $userSnapshot');
          if (userSnapshot.exists) {
            Map<String, dynamic>? cityData = userSnapshot.data() as Map<String, dynamic>?;
            print('here inside if condition');
            if (cityData != null && cityData.isNotEmpty) {
              print('here inside second if');
              storedLongitude = cityData['longitude'];
              storedLatitude = cityData['latitude'];
              // combineStringsToList(storedLatitude, storedLongitude);
              composeBlePacket(0x07, [int.parse(storedLatitude), int.parse(storedLongitude)], 'location');
              storedLongitude = '${storedLongitude.substring(0, 2)}.${storedLongitude.substring(2)}';
              storedLatitude = '${storedLatitude.substring(0, 2)}.${storedLatitude.substring(2)}';
            }
          }
        // }
      // }
    // }
  } catch (e) {
    print('Error retrieving documents: $e');
  }
}
String? validatePhoneNumber(String? value) {
  if (value == null || value.isEmpty) {
    return 'رقم الهاتف مطلوب';
  }
  if (value.length != 11) {
    return 'من فضلك أدخل رقم الهاتف الخاص بك المكون من 11 رقم';
  }
  // You can add more complex validation logic here if needed
  return ''; // Return null if the input is valid
}
Future<void> getUserFields(String userId) async {
  QuerySnapshot querySnapshot = await firestore.collection('users').get();
  //get fields
  print(userId);
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
            admin = userData['admin'] == '1';
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
        storedArea = id;
        mosque = userData['mosque'];
      }
    }
  }
  getLongitude();
}
Future<void> saveSettingData(int dataType, String userName) async{
  String docId = '$setDay-$setMonth-$setYear-$formattedTime';
  switch(dataType){
    case 1:
      //get id of time data if there is no id store
      // QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').doc(userName).collection('Date').where('time of mobile',isEqualTo: '$setHour/$setMinute/$setSecond').get();
      // if (querySnapshot.docs.isEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(userName).collection('Date').doc(docId).set(
            {
              'time of unit':'$hour/$minute/$second',
              'date of unit':'$year/$month/$day',
              'time of mobile':'$setHour/$setMinute/$setSecond',
              'date of mobile':'$setYear/$setMonth/$setDay',
              'longitude of mobile':storedLongitude,
              'latitude of mobile':storedLatitude,
              'longitude of unit':unitLongitude,
              'latitude of unit':unitLatitude,
            });
      // }
      setDateTime = false;
      break;
    case 2:
      //set location
      await FirebaseFirestore.instance.collection('users').doc(userName).collection('Location').doc(docId).set(
          {
            'time of mobile':'$setHour/$setMinute/$setSecond',
            'date of mobile':'$setYear/$setMonth/$setDay',
            'longitude of mobile':storedLongitude,
            'latitude of mobile':storedLatitude,
            'longitude of unit':unitLongitude,
            'latitude of unit':unitLatitude,
          'city': storedArea,
          });
      //delete the doc and set another one in users
      final QuerySnapshot subcollectionSnapshot = await FirebaseFirestore.instance.collection('users').doc(userName).collection('Cities').get();
      await FirebaseFirestore.instance.collection('users').doc(userName).collection('Cities').doc(subcollectionSnapshot.docs.first.id).delete().then((value) async => await FirebaseFirestore.instance.collection('users').doc(userName).collection('Cities').doc(storedArea).set(
  {
  'mosque': mosque,
  'date': '$setDay/$setMonth/$setYear',
  'time': formattedTime,
  'zone': zoneAfter,
  'longitude': storedLongitude,
  'latitude': storedLatitude,
  'fajr': '$fajrHour/$fajrMinute',
  'duhr': '$duhrHour/$duhrMinute',
  'asr': '$asrHour/$asrMinute',
  'maghreb': '$maghrebHour/$maghrebMinute',
  'isha': '$ishaHour/$ishaMinute',
  })).catchError((error){print('error deleting doc $error');});
      break;
    case 3:
      //set zone
      await FirebaseFirestore.instance.collection('users').doc(userName).collection('Zone').doc(docId).set(
          {
            'time of unit':'$hour/$minute/$second',
            'date of unit':'$year/$month/$day',
            'zone before': zoneBefore,
            'zone after': zoneAfter,
          });
      break;
    case 4:
      //restart
      await FirebaseFirestore.instance.collection('users').doc(userName).collection('Restart').doc(docId).set(
          {
            'time of unit':'$hour/$minute/$second',
            'date of unit':'$year/$month/$day',
            'time of mobile':'$setHour/$setMinute/$setSecond',
            'date of mobile':'$setYear/$setMonth/$setDay',
            'longitude of mobile':storedLongitude,
            'latitude of mobile':storedLatitude,
            'longitude of unit':unitLongitude,
            'latitude of unit':unitLatitude,
          });
      restartFlag = false;
      break;
    case 5:
      //test
      await FirebaseFirestore.instance.collection('users').doc(userName).collection('Test').doc(docId).set(
          {
            'time of unit':'$hour/$minute/$second',
            'date of unit':'$year/$month/$day',
            'time of mobile':'$setHour/$setMinute/$setSecond',
            'date of mobile':'$setYear/$setMonth/$setDay',
          });
      break;
  }
}
//get data from firebase in skiping scanning
Future<void> skipData(String userId)async{
  QuerySnapshot  querySnapshot = await firestore.collection('users').get();
  if(querySnapshot.docs.isNotEmpty){
    for(String id in usersIDs){
      if(id.endsWith(userId)) {
        DocumentSnapshot userSnapshot = await firestore.collection('users').doc(userId).collection('Cities').doc(storedArea).get();
        if (userSnapshot.exists) {
          Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;
          if (userData != null && userData.isNotEmpty) {
            fajr = userData['fajr'];
            duhr = userData['duhr'];
            asr = userData['asr'];
            maghreb = userData['maghreb'];
            isha = userData['isha'];
            formattedDateUnit = userData['date'];
            formattedTimeUnit = userData['time'];
          }
        }
      }
    }
  }
}
void showToastMessage() {
  // if (showToast) {
    Fluttertoast.showToast(
      msg: 'loading the data!',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.brown.shade700,
      textColor: Colors.white,
    );
  // }
}
/*// Storing credentials
Future<void> storeCredentials(String email, String password) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('email', email);
  prefs.setString('password', password);
}

// Retrieving credentials
Future<Map<String, String>> getStoredCredentials() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString('email');
  String? password = prefs.getString('password');
  return {'email': email ?? '', 'password': password ?? ''};
}*/
//getting the name of the city based on longitude and latitude
Future<String> getCityName() async{
  final querySnapshot = await FirebaseFirestore.instance.collection('Cities').where('longitude', isEqualTo: '$unitLongitude').where('latitude', isEqualTo: '$unitLatitude').get();
  if(querySnapshot.docs.isNotEmpty){
    unitArea = querySnapshot.docs.first.id;
  }
  final fieldSnapshot = await FirebaseFirestore.instance.collection('Zone').doc('Egypt').get();
  if(fieldSnapshot.exists){
    storedZone = fieldSnapshot['zone'];
  }
  composeBlePacket(0x04, [int.parse(storedZone)], 'zone');

  return unitArea;
}