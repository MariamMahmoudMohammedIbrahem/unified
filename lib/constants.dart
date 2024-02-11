import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

Timer? periodicTimer;
Timer? connectionTimer;
Timer? timer;
Timer? hourTimer;

final ble = FlutterReactiveBle();
String deviceName = '';
// late var deviceId;
//time calculation
DateTime now = DateTime.now();
String formattedDate = DateFormat('EEE, dd / MM').format(now);
String formattedTime = DateFormat('HH:mm:ss').format(now);
String formattedDateUnit = '';
String formattedTimeUnit = '';
const interval = Duration(seconds: 1);

bool showPassword = true;
bool emailConfirm = false;
bool userConfirm = false;
List<String> usersIDs = [];
List<String> citiesIDs = [];
List<String> mosquesIDs = [];
Set dataList = {};
List<String> testIDs = [];
List<String> userMosquesIDs = [];
bool notFound = false;
String initial = '';
//getAccountDetails constants
String sheikhName = '';
String email = '';
String sheikhPhone = '';
String storedArea = '';
String unitArea = '';
bool areaOther = false;
String mosque = '';
bool mosqueOther = false;
bool admin = false;
FirebaseFirestore firestore = FirebaseFirestore.instance;
late StreamSubscription<DocumentSnapshot> userSubscription;
late StreamSubscription<QuerySnapshot> citiesSubscription;
//scan page
StreamSubscription<List<int>>? dateSubscription;
StreamSubscription<List<int>>? locationSubscription;
StreamSubscription<List<int>>? praySubscription;
StreamSubscription<List<int>>? zoneSubscription;
StreamSubscription<List<int>>? responseSubscription;
bool awaitingResponse = false;

//ble constants
// bool scanning = false;
bool found = false;
bool connected = false;
// bool connectionStatus = false;
bool list1 = false;
bool list2 = false;
bool list3 = false;
bool list4 = false;
late List<int> subscribeOutput;
//date/time data from ble
num year = 0;
num month = 0;
num day = 0;
num hour = 0;
num minute = 0;
num second = 0;
//date/time data from mobile
int setYear = 0;
// String yearHex = '';
int setMonth = 0;
// String monthHex = '';
int setDay = 0;
// String dayHex = '';
int setHour = 0;
// String hourHex = '';
int setMinute = 0;
// String minuteHex = '';
int setSecond = 0;
// String secondHex = '';
// List<int> dateList = [];
//location data from ble
num unitLatitude = 0;
num unitLongitude = 0;
String storedLongitude = '';
String storedLatitude = '';
String storedZone = '';
List<int> locationList = [];
//pray times data from ble
num fajrHour = 00;
String fajrMinute = '';
num duhrHour = 00;
String duhrMinute = '';
num asrHour = 00;
String asrMinute = '';
num maghrebHour = 00;
String maghrebMinute = '';
num ishaHour = 00;
String ishaMinute = ''; //database
String fajr = '';
String duhr = '';
String asr = '';
String maghreb = '';
String isha = '';
String area = '';
List<int> prayList = [];
//zone data from ble
num zoneBefore = 00;
num zoneAfter = 00;
List<int> zoneList = [];
//get
List<int> getDate = [0xAA, 0x02, 0x00, 0x02, 0xAA];
List<int> getLocation = [0xAA, 0x08, 0x00, 0x08, 0xAA];
List<int> getPray = [0xAA, 0x0A, 0x00, 0x0A, 0xAA];
List<int> getZone = [0xAA, 0x05, 0x00, 0x05, 0xAA];
List<int> getTest = [0xAA, 0x10, 0x00, 0x10, 0xAA];
List<String> sounds = ['sound 1','sound 2','sound 3','sound 4'];
String sound = '';
List<int> getSound1 = [0xAA, 0x12, 0x00, 0x12, 0xAA];
List<int> getSound2 = [0xAA, 0x24, 0x00, 0x24, 0xAA];
List<int> getSound3 = [0xAA, 0x48, 0x00, 0x48, 0xAA];
List<int> getSound4 = [0xAA, 0x96, 0x00, 0x96, 0xAA];
//set
List<int> setDate = [];
// List<int> setLocation = [0xAA, 0x07, 0x08, 0x01C90A8E, 0x01D7D4BF, 0xDC, 0xAA];
List<int> setLocation = [];
List<int> setZone = [];
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
//ui
double circleSize = 50.0;
bool restartFlag = false;
bool setDateTime = false;
bool toggle = false; //english
bool mosqueFound = false;
bool areAllLowerCase = true;
bool rememberPassword = false;
// bool showToast = false; // Set your boolean condition here
//account fields flag
bool accFlag = false; // didn't get the data yet
//******************************************Scan And Settings Pages*******************************************//
// final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
final auth = FirebaseAuth.instance;
