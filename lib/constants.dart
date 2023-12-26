import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

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
late List<int> subscribeOutput;
int year = 0;
int month = 0;
int day = 0;
int hour = 0;
int minute = 0;
int second = 0;
List<int> dateList = [];
List<int> locationList = [];
List<int> prayList = [];
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
String dateTime = '';