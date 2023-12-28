import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:intl/intl.dart';

final ble = FlutterReactiveBle();
String deviceName = '';
// late var deviceId;
//time calculation
DateTime now = DateTime.now();
String formattedDate = DateFormat('yyyy-MM-dd').format(now);
String formattedTime = DateFormat('HH:mm:ss').format(now);
const interval = Duration(seconds: 1);

bool showPassword = true;
bool emailConfirm = false;
bool userConfirm = false;
List<String> usersIDs = [];
List<String> citiesIDs = [];
List<String> mosquesIDs = [];
List<String> testIDs = [];
List<String> userMosquesIDs = [];
bool notFound = false;
String initial = '';
//getAccountDetails constants
String sheikhName = '';
String email = '';
String sheikhPhone = '';
String area = '';
String mosque = '';
FirebaseFirestore firestore = FirebaseFirestore.instance;
late StreamSubscription<DocumentSnapshot> userSubscription;
late StreamSubscription<QuerySnapshot> citiesSubscription;

//ble constants
bool connected = false;
bool connectionStatus = false;
late List<int> subscribeOutput;
//date/time data from ble
num year = 0;
num month = 0;
num day = 0;
num hour = 0;
num minute = 0;
num second = 0;
List<int> dateList = [];
//location data from ble
late num latitude;
late num longitude;
List<int> locationList = [];
//pray times data from ble
late num fajrHour;
late num fajrMinute;
late num duhrHour;
late num duhrMinute;
late num asrHour;
late num asrMinute;
late num maghrebHour;
late num maghrebMinute;
late num ishaHour;
late num ishaMinute;
List<int> prayList = [];
//zone data from ble
late num zone;
List<int> zoneList = [];
//get
List<int> getDate = [0xAA, 0x02, 0x00, 0x02, 0xAA];
List<int> getLocation = [0xAA, 0x08, 0x00, 0x08, 0xAA];
List<int> getPray = [0xAA, 0x0A, 0x00, 0x0A, 0xAA];
List<int> getZone = [0xAA, 0x05, 0x00, 0x05, 0xAA];
List<int> getTest = [0xAA, 0x10, 0x00, 0x10, 0xAA];
List<int> getSound1 = [0xAA, 0x12, 0x00, 0x12, 0xAA];
List<int> getSound2 = [0xAA, 0x24, 0x00, 0x24, 0xAA];
List<int> getSound3 = [0xAA, 0x48, 0x00, 0x48, 0xAA];
List<int> getSound4 = [0xAA, 0x96, 0x00, 0x96, 0xAA];
//set
List<int> setDate = [0xAA, 0x01, 0x06, 0x0C, 0x0D, 0x10, 0x15, 0x00,0x5C, 0xAA];
List<int> setLocation = [0xAA, 0x07, 0x08, 0x01C90A8E, 0x01D7D4BF, 0xDC, 0xAA];
List<int> setZone = [0xAA, 0x04, 0x01, 0x03, 0x08, 0xAA];
List<int> restart = [0xAA, 0x0F, 0x00, 0x0F, 0xAA];
List<int> success = [0xAA, 0x11, 0x00, 0x11, 0xAA];
List<int> sizeError = [0xAA, 0x33, 0x00, 0x33, 0xAA];
List<int> crcError = [0xAA, 0x22, 0x00, 0x22, 0xAA];
//check sum calculation
num checkSum = 0;
num sum = 0;
//Data Visibility
bool locationContainer = false;
bool prayContainer = false;