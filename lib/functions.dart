import 'package:azan/classes/auto_login.dart';
import 'package:azan/register/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'account/edit_details.dart';
import 'ble/device_list.dart';
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
  accFlag = true;
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
  QuerySnapshot userSubCollection = await firestore.collection('users').doc(userId).collection('Cities').get();
  userMosquesIDs = userSubCollection.docs.map((doc) => doc.id).toList();
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
//get data from firebase in skiping scanning
Future<void> skipData(String userId)async{
  QuerySnapshot  querySnapshot = await firestore.collection('users').doc(userId).collection('Cities').get(); // get city name
  if(querySnapshot.docs.isNotEmpty){
    // for(String id in usersIDs){
    //   if(id.endsWith(userId)) {
    area = querySnapshot.docs.first.id;
        DocumentSnapshot userSnapshot = await firestore.collection('users').doc(userId).collection('Cities').doc(querySnapshot.docs.first.id).get();
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
      // }
    // }
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

//******************************************Scan And Settings Pages*******************************************//

//reset the subscriptions
void resetDateSubscription(int dataType) {
  switch (dataType) {
    case 1:
      dateSubscription?.cancel(); // Cancel the existing subscription
      dateSubscription = null; // Reset dateSubscription to null
      break;
    case 2: //edit
      praySubscription?.cancel();
      praySubscription = null;
      break;
    case 3:
      locationSubscription?.cancel();
      locationSubscription = null;
      break;
    case 4:
      zoneSubscription?.cancel();
      zoneSubscription = null;
      break;
  }
}

//initialize the subscription before getting the data from the unit
Stream<List<int>> createSubscription(String deviceId) {
  return ble
      .subscribeToCharacteristic(
    QualifiedCharacteristic(
      characteristicId:
      Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb"),
      serviceId: Uuid.parse("0000ffe0-0000-1000-8000-00805f9b34fb"),
      deviceId: deviceId,
    ),
  )
      .distinct()
      .asyncMap((event) async {
    // You can process event or modify data before updating the list
    return List<int>.from(event);
  });
}

//pause and complete the subscriptions, filter and reformat the received data
void subscribeCharacteristic(int dataType, String deviceId) {
  Stream<List<int>> stream;
  switch (dataType) {
    case 1:
      dateSubscription?.resume();
      locationSubscription?.pause();
      praySubscription?.pause();
      zoneSubscription?.pause();
      if (dateSubscription == null) {
        stream = createSubscription(deviceId);
        dateSubscription = stream.listen((event) {
            print('1$event');
            if (event.length == 11) {
              year = num.parse(convertToInt(event, 3, 1).toString().padLeft(3, '20'));
              month = convertToInt(event, 4, 1);
              day = convertToInt(event, 5, 1);
              hour = convertToInt(event, 6, 1);
              minute = num.parse(convertToInt(event, 7, 1).toString().padLeft(2, '0'));
              second = num.parse(convertToInt(event, 8, 1).toString().padLeft(2, '0'));
              list1 = true;
              awaitingResponse = false;
            }
        });
      }
      break;
    case 2:
      dateSubscription?.pause();
      locationSubscription?.pause();
      praySubscription?.resume();
      zoneSubscription?.pause();
      if (praySubscription == null) {
        stream = createSubscription(deviceId);
        praySubscription = stream.listen((event) {
            print('2$event');
            if (event.length == 15) {
              fajrHour = convertToInt(event, 3, 1);
              fajrMinute = convertToInt(event, 4, 1).toString().padLeft(2, '0');
              duhrHour = convertToInt(event, 5, 1);
              duhrMinute = convertToInt(event, 6, 1).toString().padLeft(2, '0');
              asrHour = convertToInt(event, 7, 1);
              asrMinute = convertToInt(event, 8, 1).toString().padLeft(2, '0');
              maghrebHour = convertToInt(event, 9, 1);
              maghrebMinute = convertToInt(event, 10, 1).toString().padLeft(2, '0');
              ishaHour = convertToInt(event, 11, 1);
              ishaMinute = convertToInt(event, 12, 1).toString().padLeft(2, '0');
              list2 = true;
              awaitingResponse = false;
            }
        });
      }
      break;
    case 3:
      dateSubscription?.pause();
      locationSubscription?.resume();
      praySubscription?.pause();
      zoneSubscription?.pause();
      if (locationSubscription == null) {
        stream = createSubscription(deviceId);
        locationSubscription = stream.listen((event) {
            print('3$event');
            if (event.length == 13) {
              unitLatitude = convertToInt(event, 3, 4);
              unitLongitude = convertToInt(event, 7, 4);
              getCityName();
              unitLatitude = unitLatitude/1000000;
              unitLongitude = unitLongitude/1000000;
              list3 = true;
              awaitingResponse = false;
            }
        });
      }
      break;
    case 4:
      dateSubscription?.pause();
      locationSubscription?.pause();
      praySubscription?.pause();
      zoneSubscription?.resume();
      if (zoneSubscription == null) {
        stream = createSubscription(deviceId);
        zoneSubscription = stream.listen((event) {
            print('4$event hi');
            if (event.length == 6) {
              zoneAfter = convertToInt(event, 3, 1);
              list4 = true;
              awaitingResponse = false;
            }
        });
      }
      break;
  }
}

// each time the user gets/reloads the data from the unit save the received data
Future<void> saveInFirebase(userName) async {
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userName)
        .collection('Cities')
        .doc(storedArea)
        .update({
      'fajr': '$fajrHour:$fajrMinute',
      'duhr': '$duhrHour:$duhrMinute',
      'asr': '$asrHour:$asrMinute',
      'maghreb': '$maghrebHour:$maghrebMinute',
      'isha': '$ishaHour:$ishaMinute',
      'date': '$day / $month / $year',
      'time': '$hour:$minute',
      'current time':formattedTime,
      'current date':'$setDay / $setMonth / $setYear',
      'longitude': unitLongitude,
      'latitude': unitLatitude,
      'zone': zoneAfter,
    });
  } catch (e) {
    print(e);
  }
}

// incase there is setting to date/location/zone/restart/test save the data needed for this action
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
            'current date': '$setDay/$setMonth/$setYear',
            'current time': formattedTime,
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

//******************************************edit_details Page*******************************************//

//update user's personal data in users collection
Future<void> updateUserData(String name) async {
  //update users fields (case: name is updated) in users collection
  try{
    var data = await firestore.collection('users').doc(name).get();
    if(data.exists){
      //update the data edited i users collection
      print('inside editing user field');
      try{
        firestore.collection('users').doc(name).update({
          'sheikh name': updatedSheikhName,
          'sheikh phone': updatedSheikhNumber,
          'user email': updatedUserEmail,
          'current date': formattedDate,
          'current time': formattedTime,
          'note': 'edited data',
        });
      }
      //error while updating the data
      on FirebaseException catch (e){
        print('error1 $e');
      }
    }
  }
  //error while getting the data
  on FirebaseException catch (e){
    print('error2 $e');
  }
}

//update mosques data in Mosques collection
Future<void> updateMosques(String name, int dataType) async {
  //get the id in which the data before editing is saved
  final printingData = await FirebaseFirestore.instance.collection('Mosques')
      .where('mosque', isEqualTo: mosque).where('city', isEqualTo: area)
      .get();
  //reset sheikh name in previous mosque
  if (printingData.docs.isNotEmpty) {
    try {
      DocumentReference docRef = FirebaseFirestore.instance.collection(
          'Mosques').doc(printingData.docs.first.id);
      await docRef.update({
        'sheikh name': '',
        'connect time': '$formattedTime - $formattedDate',
      });
    } catch (e) {
      print('got a problem $e');
    }
  }
  //check if updated mosque exists in area
  final inDatabase = await FirebaseFirestore.instance.collection('Mosques').where('mosque', isEqualTo: updatedMosque).where('city', isEqualTo: updatedArea).get();
  //if the mosque is found update sheikh name
  if (inDatabase.docs.isNotEmpty) {
    DocumentReference docRef = FirebaseFirestore.instance.collection('Mosques').doc(inDatabase.docs.first.id);
    switch (dataType) {
    //mosque updated, city not updated
      case 0:
        try {
          await docRef.update({
            'mosque': updatedMosque,
            'sheikh name': updatedSheikhName,
            'connect time': '$formattedTime - $formattedDate',
          });
        } catch (e) {
          print('got a problem $e');
        }
        break;
    //mosque not updated, city updated
      case 1:
        try {
          await docRef.update({
            'city': updatedArea,
            'sheikh name': updatedSheikhName,
            'connect time': '$formattedTime - $formattedDate',
          });
        } catch (e) {
          print('got a problem $e');
        }
        break;
    //mosque updated, city updated
      case 2:
        try {
          await docRef.update({
            'city': area,
            'connect time': '$formattedTime - $formattedDate',
            'mosque': updatedMosque,
            'sheikh name': updatedSheikhName,
          });
        } catch (e) {
          print('got a problem $e');
        }
        break;
    }
  }
  //else if the new mosque isn't found create new document with the city and mosque and sheikh name
  else {
    FirebaseFirestore.instance.collection('Mosques').add({
      'city': area,
      'connect time': '$formattedTime - $formattedDate',
      'mosque': updatedMosque,
      'sheikh name': updatedSheikhName,
    });
  }
}

//update user data in users -> Cities
Future<void> updateUserColl(String name, int dataType) async{
  late Map<String, dynamic> data;
  //check which datatype is passed to the function
  if(dataType != 0){
    //get the name of the city stored inside the users collection
    QuerySnapshot cityDocId = await firestore.collection('users').doc(name).collection('Cities').get();
    //check if there is city stored in Cities in users
    if(cityDocId.docs.isNotEmpty){
      // get the data
      DocumentSnapshot currentDocSnapshot = await firestore.collection('users').doc(name).collection('Cities').doc(cityDocId.docs.first.id).get();
      await firestore.collection('users').doc(name).collection('Cities').doc(cityDocId.docs.first.id).delete();
      // reformat the data
      data = currentDocSnapshot.data() as Map<String, dynamic>;
    }
  }
  switch(dataType){
    case 0:
      firestore.collection('users').doc(name).collection('Cities').doc(area).update(
          {
            'mosque': updatedMosque,
            'current date': formattedDate,
            'current time': formattedTime,
          });
      break;
    case 1:
      firestore.collection('users').doc(name).collection('Cities').doc(updatedArea).set(data);
      firestore.collection('users').doc(name).collection('Cities').doc(updatedArea).update(
          {
            'longitude': '',
            'latitude': '',
            'current date': formattedDate,
            'current time': formattedTime,
          });
      break;
    case 2:
      firestore.collection('users').doc(name).collection('Cities').doc(updatedArea).set(data);
      firestore.collection('users').doc(name).collection('Cities').doc(updatedArea).update(
          {
            'longitude': '',
            'latitude': '',
            'mosque': updatedMosque,
            'current date': formattedDate,
            'current time': formattedTime,
          });
      break;
  }
}

//update city and mosque in Cities collection
Future<void> updateCitiesAndMosques()async {
  //reset the sheikh name in the previous area and city
  firestore.collection('Cities').doc(area).collection('Mosques').doc(mosque).update(
      {
        'sheikh name': '',
      });
  //check if mosque exists inside the area
  DocumentSnapshot documentSnapshot = await firestore.collection('Cities').doc(updatedArea).collection('Mosques').doc(updatedMosque).get();
  //if mosque exist inside the city and both exists in Cities collection update
  if(documentSnapshot.exists){
    firestore.collection('Cities').doc(updatedArea).collection('Mosques').doc(updatedMosque).update(
        {
          'sheikh name': updatedSheikhName,
        });
  }
  //else set
  else{
    firestore.collection('Cities').doc(updatedArea).collection('Mosques').doc(updatedMosque).set(
        {
          'sheikh name': updatedSheikhName,
        });
  }
}

void updatePass(){}

//******************************************AUTO LOGIN Page*******************************************//

