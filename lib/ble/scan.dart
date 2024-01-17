import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:azan/ble/settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:functional_data/functional_data.dart';
import 'package:provider/provider.dart';

import '../account/account_details.dart';
import '../constants.dart';
import '../feedback/feedback1.dart';
import '../functions.dart';
import '../register/login.dart';
import '../register/resetPassword.dart';
import 'ble_device_connector.dart';
import 'ble_device_interactor.dart';
import 'device_list.dart';
part 'scan.g.dart';

class DeviceInteractionTab extends StatelessWidget {
  const DeviceInteractionTab({
    required this.device,
    required this.characteristic,
    required this.userName,
    Key? key,
  }) : super(key: key);
  final DiscoveredDevice device;
  final QualifiedCharacteristic characteristic;
  final String userName;

  @override
  Widget build(BuildContext context) => Consumer4<BleDeviceConnector,
          ConnectionStateUpdate, BleDeviceInteractor, BleDeviceInteractor>(
        builder: (_, deviceConnector, connectionStateUpdate, serviceDiscoverer,
                interactor, __) =>
            Connecting(
          viewModel: DeviceInteractionViewModel(
              deviceId: device.id,
              connectableStatus: device.connectable,
              connectionStatus: connectionStateUpdate.connectionState,
              deviceConnector: deviceConnector,
              discoverServices: () =>
                  serviceDiscoverer.discoverServices(device.id)),
          characteristic: characteristic,
          writeWithResponse: interactor.writeCharacteristicWithResponse,
          writeWithoutResponse: interactor.writeCharacteristicWithoutResponse,
          readCharacteristic: interactor.readCharacteristic,
          subscribeToCharacteristic: interactor.subScribeToCharacteristic,
          device: device,
          name: device.name,
          userName: userName,
        ),
      );
}

// @immutable
@FunctionalData()
class DeviceInteractionViewModel extends $DeviceInteractionViewModel {
  const DeviceInteractionViewModel({
    required this.deviceId,
    required this.connectableStatus,
    required this.connectionStatus,
    required this.deviceConnector,
    required this.discoverServices,
  });

  @override
  final String deviceId;
  @override
  final Connectable connectableStatus;
  @override
  final DeviceConnectionState connectionStatus;
  @override
  final BleDeviceConnector deviceConnector;
  @override
  @CustomEquality(Ignore())
  final Future<List<DiscoveredService>> Function() discoverServices;

  bool get deviceConnected =>
      connectionStatus == DeviceConnectionState.connected;

  void connect() {
    deviceConnector.connect(deviceId);
  }

  void disconnect() {
    deviceConnector.disconnect(deviceId);
  }
}

class Connecting extends StatefulWidget {
  const Connecting({
    required this.viewModel,
    required this.characteristic,
    required this.writeWithResponse,
    required this.writeWithoutResponse,
    required this.readCharacteristic,
    required this.subscribeToCharacteristic,
    required this.name,
    required this.userName,
    required this.device,
    super.key,
  });
  final DeviceInteractionViewModel viewModel;

  final QualifiedCharacteristic characteristic;
  final Future<void> Function(
          QualifiedCharacteristic characteristic, List<int> value)
      writeWithResponse;
  final Future<void> Function(
          QualifiedCharacteristic characteristic, List<int> value)
      writeWithoutResponse;
  final Future<List<int>> Function(QualifiedCharacteristic characteristic)
      readCharacteristic;
  final Stream<List<int>> Function(QualifiedCharacteristic characteristic)
      subscribeToCharacteristic;
  final DiscoveredDevice device;
  final String name;
  final String userName;

  @override
  State<Connecting> createState() => _ConnectingState();
}

class _ConnectingState extends State<Connecting> {
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

  Stream<List<int>> _createSubscription() {
    return ble
        .subscribeToCharacteristic(
          QualifiedCharacteristic(
            characteristicId:
                Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb"),
            serviceId: Uuid.parse("0000ffe0-0000-1000-8000-00805f9b34fb"),
            deviceId: widget.viewModel.deviceId,
          ),
        )
        .distinct()
        .asyncMap((event) async {
      // You can process event or modify data before updating the list
      return List<int>.from(event);
    });
  }

  void subscribeCharacteristic(int dataType) {
    Stream<List<int>> stream;
    // dateSubscription?.pause();
    // locationSubscription?.pause();
    // praySubscription?.pause();
    // zoneSubscription?.pause();
    switch (dataType) {
      case 1:
        dateSubscription?.resume();
        locationSubscription?.pause();
        praySubscription?.pause();
        zoneSubscription?.pause();
        if (dateSubscription == null) {
          stream = _createSubscription();
          dateSubscription = stream.listen((event) {
            setState(() {
              print('1$event');
              if (event.length == 11) {
                // dateList = List.from(event);
                year = convertToInt(event, 3, 1);
                month = convertToInt(event, 4, 1);
                day = convertToInt(event, 5, 1);
                hour = convertToInt(event, 6, 1);
                minute = convertToInt(event, 7, 1);
                second = convertToInt(event, 8, 1);
                list1 = true;
                awaitingResponse = false;
              }
            });
          });
        }
        break;
      case 2:
        dateSubscription?.pause();
        locationSubscription?.pause();
        praySubscription?.resume();
        zoneSubscription?.pause();
        if (praySubscription == null) {
          stream = _createSubscription();
          praySubscription = stream.listen((event) {
            setState(() {
              print('2$event');
              if (event.length == 15) {
                // prayList = List.from(event);
                fajrHour = convertToInt(event, 3, 1);
                fajrMinute = convertToInt(event, 4, 1);
                duhrHour = convertToInt(event, 5, 1);
                duhrMinute = convertToInt(event, 6, 1);
                asrHour = convertToInt(event, 7, 1);
                asrMinute = convertToInt(event, 8, 1);
                maghrebHour = convertToInt(event, 9, 1);
                maghrebMinute = convertToInt(event, 10, 1);
                ishaHour = convertToInt(event, 11, 1);
                ishaMinute = convertToInt(event, 12, 1);
                list2 = true;
                awaitingResponse = false;
              }
            });
          });
        }
        break;
      case 3:
        dateSubscription?.pause();
        locationSubscription?.resume();
        praySubscription?.pause();
        zoneSubscription?.pause();
        if (locationSubscription == null) {
          stream = _createSubscription();
          locationSubscription = stream.listen((event) {
            setState(() {
              print('3$event');
              if (event.length == 13) {
                // locationList = List.from(event);
                unitLatitude = int.parse('${event[3].toString().padLeft(2, '0')}${event[4].toString().padLeft(2, '0')}${event[5].toString().padLeft(2, '0')}${event[6].toString().padLeft(2, '0')}');
                unitLongitude = int.parse('${event[7].toString().padLeft(2, '0')}${event[8].toString().padLeft(2, '0')}${event[9].toString().padLeft(2, '0')}${event[10].toString().padLeft(2, '0')}');
                list3 = true;
                awaitingResponse = false;
              }
            });
          });
        }
        break;
      case 4:
        dateSubscription?.pause();
        locationSubscription?.pause();
        praySubscription?.pause();
        zoneSubscription?.resume();
        if (zoneSubscription == null) {
          stream = _createSubscription();
          zoneSubscription = stream.listen((event) {
            setState(() {
              print('4$event hi');
              if (event.length == 6) {
                // zoneList = List.from(event);
                zoneAfter = convertToInt(event, 3, 1);
                list4 = true;
                awaitingResponse = false;
              }
            });
          });
        }
        break;
    }
  }
  Future<void> saveInFirebase() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userName)
          .collection('Cities')
          .doc(area)
          .update({
        'fajr': '$fajrHour:$fajrMinute',
        'duhr': '$duhrHour:$duhrMinute',
        'asr': '$asrHour:$asrMinute',
        'maghreb': '$maghrebHour:$maghrebMinute',
        'isha': '$ishaHour:$ishaMinute',
        'date': '$day / $month / $year',
        'time': '$hour:$minute',
        'longitude': unitLongitude,
        'latitude': unitLatitude,
        'zone': zoneAfter,
      });
    } catch (e) {
      print(e);
    }
  }
  void getAllDataAndSubscribe() async {
    List<Map<int, List<int>>> dataSets = [
      {1: getDate},
      {2: getPray},
      {3: getLocation},
      {4: getZone},
    ];

    for (var data in dataSets) {
      int dataType = data.keys.first;
      List<int> dataToWrite = data.values.first;
      print('dataType $dataType');
      print('dataToWrite $dataToWrite');
      print('awaiting response $awaitingResponse');
      if (!awaitingResponse) {
        awaitingResponse = true;
        resetDateSubscription(dataType);
        subscribeCharacteristic(dataType);
        await widget.writeWithoutResponse(widget.characteristic, dataToWrite);
      } else {
        print('Awaiting response, cannot send another packet yet.');
        break; // Exit the loop if awaiting a response
      }
    }
    if (!list1) {
      resetDateSubscription(1);
      subscribeCharacteristic(1);
      await widget.writeWithoutResponse(widget.characteristic, getDate);
    } else if (!list2) {
      //edit
      resetDateSubscription(2);
      subscribeCharacteristic(2);
      await widget.writeWithoutResponse(widget.characteristic, getPray);
    } else if (!list3) {
      resetDateSubscription(3);
      subscribeCharacteristic(3);
      await widget.writeWithoutResponse(widget.characteristic, getLocation);
    } else {
      resetDateSubscription(4);
      subscribeCharacteristic(4);
      await widget.writeWithoutResponse(widget.characteristic, getZone);
    }
  }

  Future<void> updateDateTime() async {
    await getCurrentDateTime();
    setState(() {
      if (widget.viewModel.connectionStatus ==
          DeviceConnectionState.disconnected) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanningListScreen(
              userName: widget.userName,
            ),
          ),
        );
      }
    });
  }

  void startPeriodicTimer() {
    hourTimer = Timer.periodic(const Duration(minutes: 1), (Timer t) {
      updateDateTime(); // Trigger the update asynchronously
      // composeBlePacket(0x01, [setYear,setMonth,setDay,setHour,setMinute,setSecond]);
    });
  }

  Future<void> settingDate() async {
    // composeBlePacket(0x01, [setYear,setMonth,setDay,setHour,setMinute,setSecond],'date');
    List<int> data = [setYear,setMonth,setDay,setHour,setMinute,setSecond];
    setDate = [];
    int startFrame = 0xAA;
    int endFrame = 0xAA;
    final hexValues = data.map((value) => int.parse(value.toRadixString(16), radix: 16)).toList();//convert
    setDate.add(startFrame);
    setDate.add(0x01);
    setDate.add(data.length);
    setDate.addAll(hexValues);
    int value = 0;
    for (int i = 1; i <= setDate.length-1; i++) {
      value += setDate[i];
    }
    setDate.add(value);
    setDate.add(endFrame);
    widget.subscribeToCharacteristic(widget.characteristic);
    await widget.writeWithoutResponse(widget.characteristic, setDate);
    // Listen for incoming data asynchronously
    responseSubscription = widget
        .subscribeToCharacteristic(widget.characteristic)
        .listen((receivedData) async {
      if (receivedData.length == success.length &&
          receivedData.every(
              (element) => element == success[receivedData.indexOf(element)])) {
        print('Received expected data, setting date and time');
        responseSubscription?.cancel();
        setDateTime = true;
        disconnectRestart();
      }
    });
  }

  Future<void> disconnectRestart() async {
    print('1');
    await widget.writeWithoutResponse(widget.characteristic, restart);
    print('11');
    widget.subscribeToCharacteristic(widget.characteristic);
    print('111');
    if (widget.viewModel.connectionStatus ==
        DeviceConnectionState.disconnected) {
      setState(() {
        print('1111');
        found = false;
        deviceName = '';
        restartFlag = true;
      });
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ScanningListScreen(
                    userName: widget.userName,
                  )));
    }
  }
  Future<void> settingLocation() async {
    widget.subscribeToCharacteristic(widget.characteristic);
    await widget.writeWithoutResponse(widget.characteristic, setLocation);
    responseSubscription = widget
        .subscribeToCharacteristic(widget.characteristic)
        .listen((receivedData) {
      if (receivedData.length == success.length &&
          receivedData.every(
                  (element) => element == success[receivedData.indexOf(element)])) {
        print('Received expected data, setting date and time');
        responseSubscription?.cancel();
        print('ready to get data');
        saveSettingData(2, widget.userName);
      }
    });
  }

  @override
  void initState() {
    setState(() {
      awaitingResponse = false;
      getCurrentDateTime();
    });
    //connect and get data
    periodicTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (!widget.viewModel.deviceConnected) {
        widget.viewModel.connect();
      } else if (!list1 || !list2 || !list3 || !list4) {
        getAllDataAndSubscribe();
      }
      else if(restartFlag){
        print('1 restart flag');
      saveSettingData(4, widget.userName);
      }
      else if(setDateTime) {
        print('1 $setDateTime');
        saveSettingData(1, widget.userName);
      }
      else {
        saveInFirebase();
        t.cancel();
      }
    });
    //update time each minute
    startPeriodicTimer();
    super.initState();
  }

  @override
  void dispose() {
    periodicTimer?.cancel();
    hourTimer?.cancel();
    deviceName = '';
    super.dispose();
    // dateSubscription?.cancel();
    // locationSubscription?.cancel();
    // praySubscription?.cancel();
    // zoneSubscription?.cancel();
    // awaitingResponse = false;
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _auth = FirebaseAuth.instance;
  signOut() async {
    await _auth.signOut();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const LogIn()));
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    initial = widget.userName.trim().isNotEmpty
        ? widget.userName.trim()[0].toUpperCase()
        : ''; // Get the first letter
    return WillPopScope(
      onWillPop: () async {
        // Custom logic when the back button is pressed
        // Return true to allow popping the page, or false to prevent it
        // You can also perform actions before popping the page
        bool shouldPop = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Exit', style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),),
              content: Text('Do you really want to exit?', style: TextStyle(fontSize: 17,color: Colors.brown.shade700),),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.brown,
                      backgroundColor: Colors.brown.shade200,
                      disabledForegroundColor: Colors.brown.shade600,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: Text('Yes',style: TextStyle(color: Colors.brown.shade800,fontSize: 18),),
                  onPressed: () {
                    setState(() {
                      deviceName = '';
                      found = false;
                    });
                    widget.viewModel.disconnect();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScanningListScreen(
                          userName: widget.userName,
                        ),
                      ),
                      // (route) => false,
                    );
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.brown,
                      backgroundColor: Colors.brown.shade600,
                      disabledForegroundColor: Colors.brown.shade600,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('No',style: TextStyle(color: Colors.white,fontSize: 18),),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ],
            );
          },
        );

        return shouldPop ?? false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leadingWidth: 70,
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.brown
                    .shade700, // You can change the background color as needed
                shape: BoxShape.circle,
              ),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        drawer: Drawer(
          child: Container(
            color: Colors.brown.shade50,
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                SizedBox(
                  height: 150,
                  child: DrawerHeader(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('images/pattern.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.userName.trim(),
                        style: TextStyle(
                          color: Colors.brown.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                        ),
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.home,
                    color: Colors.brown.shade700,
                    size: 30,
                  ),
                  title: Text(
                    'Dashboard',
                    style: TextStyle(
                        color: Colors.brown.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 25),
                  ),
                  onTap: () {
                    _scaffoldKey.currentState?.closeDrawer();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Divider(
                    height: 1,
                    indent: 0,
                    endIndent: 10,
                    thickness: 2,
                    color: Colors.brown.shade100,
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.account_circle_outlined,
                    color: Colors.brown.shade700,
                    size: 30,
                  ),
                  title: Text(
                    'Account Details',
                    style: TextStyle(
                        color: Colors.brown.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 25),
                  ),
                  onTap: () {
                    _scaffoldKey.currentState?.closeDrawer();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AccountDetails(
                                  name: widget.userName.trim(),
                                )));
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Divider(
                    height: 1,
                    indent: 0,
                    endIndent: 10,
                    thickness: 2,
                    color: Colors.brown.shade100,
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.key_sharp,
                    color: Colors.brown.shade700,
                    size: 30,
                  ),
                  title: Text(
                    'Change Password',
                    style: TextStyle(
                        color: Colors.brown.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 25),
                  ),
                  onTap: () {
                    _scaffoldKey.currentState?.closeDrawer();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ResetPassword()));
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Divider(
                    height: 1,
                    indent: 0,
                    endIndent: 10,
                    thickness: 2,
                    color: Colors.brown.shade100,
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.feedback_outlined,
                    color: Colors.brown.shade700,
                    size: 30,
                  ),
                  title: Text(
                    'Complain',
                    style: TextStyle(
                        color: Colors.brown.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 25),
                  ),
                  onTap: () {
                    _scaffoldKey.currentState?.closeDrawer();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FeedbackRegister(
                                  name: widget.userName.trim(),
                                )));
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Divider(
                    height: 1,
                    indent: 0,
                    endIndent: 10,
                    thickness: 2,
                    color: Colors.brown.shade100,
                  ),
                ),
                Visibility(
                  visible: admin,
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.settings,
                          color: Colors.brown.shade700,
                          size: 30,
                        ),
                        title: Text(
                          'Settings',
                          style: TextStyle(
                              color: Colors.brown.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 25),
                        ),
                        onTap: () {
                          _scaffoldKey.currentState?.closeDrawer();
                          Navigator.push<void>(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SettingTab(
                                    device: widget.device,
                                    characteristic:
                                    QualifiedCharacteristic(
                                      characteristicId: Uuid.parse(
                                          "0000ffe1-0000-1000-8000-00805f9b34fb"),
                                      serviceId: Uuid.parse(
                                          "0000ffe0-0000-1000-8000-00805f9b34fb"),
                                      deviceId: widget.viewModel.deviceId,
                                    ),
                                    userName: widget.userName,
                                  ),
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Divider(
                          height: 1,
                          indent: 0,
                          endIndent: 10,
                          thickness: 2,
                          color: Colors.brown.shade100,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.logout_outlined,
                    color: Colors.brown.shade700,
                    size: 30,
                  ),
                  title: Text(
                    'Logout',
                    style: TextStyle(
                        color: Colors.brown.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 25),
                  ),
                  onTap: () {
                    //logout
                    _scaffoldKey.currentState?.closeDrawer();
                    signOut();
                  },
                ),
              ],
            ),
          ),
        ),
        body: Stack(
          children: [
            // Blurred background image
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/pattern.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: ListView(
                  children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                            formattedTime,
                            style: TextStyle(
                                color: Colors.brown.shade800,
                                fontSize: 100,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            formattedDate,
                            style: TextStyle(
                              color: Colors.brown.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: width * 0.05, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Unit Date And Time: ',
                            style: TextStyle(
                              color: Colors.brown.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 27,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                list1 = false;
                                list2 = false;
                                list3 = false;
                                list4 = false;
                              });
                              Future.delayed(Duration(seconds: 1));
                              periodicTimer = Timer.periodic(
                                  const Duration(seconds: 1), (Timer t) {
                                if (!list1 || !list2 || !list3 || !list4) {
                                  getAllDataAndSubscribe();
                                } else {
                                  t.cancel();
                                }
                              });
                            },
                            icon: Icon(
                              Icons.restore,
                              color: Colors.brown.shade800,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: width * .6,
                      // height: height * .1,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          width: 2,
                          color: Colors.brown,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: width * .05, vertical: width * .03),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.date_range_outlined,
                                color: Colors.brown.shade700,
                                size: 30,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                '$day / $month / $year',
                                style: TextStyle(
                                    color: Colors.brown.shade800,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.hourglass_bottom_outlined,
                                color: Colors.brown.shade700,
                                size: 30,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                '$hour:$minute',
                                style: TextStyle(
                                    color: Colors.brown.shade800,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: SizedBox(
                        width: width * .7,
                        child: const Divider(
                          height: 1,
                          indent: 0,
                          endIndent: 10,
                          thickness: 2,
                          color: Colors.brown,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.05,
                      ),
                      child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            'Pray Times: ',
                            style: TextStyle(
                              color: Colors.brown.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 27,
                            ),
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: width * .07, vertical: 10),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Image.asset('images/fajr.png'),
                            title: Text(
                              'Fajr',
                              style: TextStyle(
                                  color: Colors.brown.shade800, fontSize: 25),
                            ),
                            trailing: Text(
                              '$fajrHour:$fajrMinute',
                              style: TextStyle(
                                  color: Colors.brown.shade800,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ListTile(
                            leading: Image.asset('images/zuhr.png'),
                            title: Text(
                              'Zuhr',
                              style: TextStyle(
                                  color: Colors.brown.shade800, fontSize: 25),
                            ),
                            trailing: Text(
                              '$duhrHour:$duhrMinute',
                              style: TextStyle(
                                  color: Colors.brown.shade800,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ListTile(
                            leading: Image.asset('images/asr.png'),
                            title: Text(
                              'Asr',
                              style: TextStyle(
                                  color: Colors.brown.shade800, fontSize: 25),
                            ),
                            trailing: Text(
                              '$asrHour:$asrMinute',
                              style: TextStyle(
                                  color: Colors.brown.shade800,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ListTile(
                            leading: Image.asset('images/maghrib.png'),
                            title: Text(
                              'Maghrib',
                              style: TextStyle(
                                  color: Colors.brown.shade800, fontSize: 25),
                            ),
                            trailing: Text(
                              '$maghrebHour:$maghrebMinute',
                              style: TextStyle(
                                  color: Colors.brown.shade800,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ListTile(
                            leading: Image.asset('images/isha.png'),
                            title: Text(
                              'isha',
                              style: TextStyle(
                                  color: Colors.brown.shade800, fontSize: 25),
                            ),
                            trailing: Text(
                              '$ishaHour:$ishaMinute',
                              style: TextStyle(
                                color: Colors.brown.shade800,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ElevatedButton(
                    //   onPressed: (){
                    //     composeBlePacket(0x01, [setYear,setMonth,setDay,setHour,setMinute,setSecond]);
                    //     },
                    //   child: Text('date compose'),
                    // ),
                    Visibility(
                      visible: !admin,
                      child: Column(
                        children: [
                          SizedBox(
                          width: width * .7,
                          child: const Divider(
                            height: 1,
                            indent: 0,
                            endIndent: 10,
                            thickness: 2,
                            color: Colors.brown,
                          ),
                        ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: width * 0.05, vertical: 10),
                            child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  'Settings Options: ',
                                  style: TextStyle(
                                    color: Colors.brown.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 27,
                                  ),
                                )),
                          ),
                          SizedBox(
                            width: width * .8,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                settingDate();
                              },
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.brown.shade100,
                                  backgroundColor: Colors.brown.shade600,
                                  disabledForegroundColor: Colors.brown.shade900,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              icon: const Icon(
                                Icons.settings_backup_restore,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Setting Prayer Times',
                                style: TextStyle(color: Colors.white, fontSize: 24),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: width * .8,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await disconnectRestart();
                              },
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.brown.shade100,
                                  backgroundColor: Colors.brown.shade600,
                                  disabledForegroundColor: Colors.brown.shade900,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              icon: const Icon(
                                Icons.restart_alt,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Restarting The Unit',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ElevatedButton(
                    //     onPressed: () {
                    //       // setLocation = composeBLEPacket(0x07, [30142208, 31741347]);
                    //     },
                    //     child: Text('location compose')),
                    /*Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: SizedBox(
                        width: width * .8,
                        height: 55,
                        child: PopupMenuButton<String>(
                          onSelected: (String value) async {
                            setState(() async {
                              // Handle the selected value
                              area = value;
                              getLongitude();
                            });
                          },
                          color: Colors.brown.shade700,
                          itemBuilder: (BuildContext context) {
                            final List<PopupMenuEntry<String>> items = [];
                            for (String item in citiesIDs) {
                              items.add(
                                PopupMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              );
                              if (item != citiesIDs.last) {
                                items.add(const PopupMenuDivider());
                              }
                            }
                            items.add(const PopupMenuDivider());
                            return items;
                          },
                          offset: const Offset(0, 50),
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                            decoration: BoxDecoration(
                                color: Colors.brown.shade600.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20.0)),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    area == '' ? 'Select An Area' : area,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: width * .8,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          settingLocation();
                        },
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.brown.shade100,
                            backgroundColor: Colors.brown.shade600,
                            disabledForegroundColor: Colors.brown.shade900,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        icon: const Icon(
                          Icons.settings_backup_restore,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Setting Unit Location',
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: width * .8,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          zoneBefore = zoneAfter;
                          settingZone();
                        },
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.brown.shade100,
                            backgroundColor: Colors.brown.shade600,
                            disabledForegroundColor: Colors.brown.shade900,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        icon: const Icon(
                          Icons.settings_backup_restore,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Setting Unit Zone',
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: width * .8,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          widget
                              .subscribeToCharacteristic(widget.characteristic);
                          await widget.writeWithoutResponse(
                              widget.characteristic, getTest);
                          getAllDataAndSubscribe();
                        },
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.brown.shade100,
                            backgroundColor: Colors.brown.shade600,
                            disabledForegroundColor: Colors.brown.shade900,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        icon: const Icon(
                          Icons.settings_backup_restore,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Enter Test Mode',
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ),
                    ),*/

                    /*Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: SizedBox(
                        width: width * .8,
                        height: 55,
                        child: PopupMenuButton<String>(
                          onSelected: (String value) {
                            setState(() {
                              area = value;
                              getLongitude();
                            });
                          },
                          color: Colors.brown.shade700,
                          itemBuilder: (BuildContext context) {
                            final List<PopupMenuEntry<String>> items = [];
                            for (String item in citiesIDs) {
                              items.add(
                                PopupMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              );
                              if (item != citiesIDs.last) {
                                items.add(const PopupMenuDivider());
                              }
                            }
                            items.add(const PopupMenuDivider());
                            return items;
                          },
                          offset: const Offset(0, 50),
                          child: Container(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 15.0),
                            decoration: BoxDecoration(
                                color: Colors.brown.shade600.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20.0)),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    area == '' ? 'Select An Area' : area,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: width * .8,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          settingLocation();
                        },
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.brown.shade100,
                            backgroundColor: Colors.brown.shade600,
                            disabledForegroundColor: Colors.brown.shade900,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        icon: const Icon(
                          Icons.settings_backup_restore,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Setting Unit Location',
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: admin,
                      child: SizedBox(
                        width: width*.8,
                        child: ElevatedButton(
                          onPressed: (){
                            Navigator.push<void>(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    SettingTab(
                                      device: widget.device,
                                      characteristic:
                                      QualifiedCharacteristic(
                                        characteristicId: Uuid.parse(
                                            "0000ffe1-0000-1000-8000-00805f9b34fb"),
                                        serviceId: Uuid.parse(
                                            "0000ffe0-0000-1000-8000-00805f9b34fb"),
                                        deviceId: widget.viewModel.deviceId,
                                      ),
                                      userName: widget.userName,
                                    ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.brown.shade100,
                              backgroundColor: Colors.brown.shade600,
                              disabledForegroundColor: Colors.brown.shade900,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                          child: const Text('ADMIN PAGE', style: TextStyle(color: Colors.white, fontSize: 24),),
                        ),
                      ),
                    ),*/
                  ],
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class NotConnected extends StatefulWidget {
  const NotConnected({required this.userName, super.key});
  final String userName;

  @override
  State<NotConnected> createState() => _NotConnectedState();
}

class _NotConnectedState extends State<NotConnected> {
  @override
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _auth = FirebaseAuth.instance;
  @override
  void initState() {
    hourTimer = Timer.periodic(const Duration(minutes: 1), (Timer t) {
      setState(() {
        getCurrentDateTime();
      });
    });
    super.initState();
  }

  signOut() async {
    await _auth.signOut();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const LogIn()));
  }

  void dispose() {
    super.dispose();
    hourTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    initial = widget.userName.trim().isNotEmpty
        ? widget.userName.trim()[0].toUpperCase()
        : ''; // Get the first letter
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.brown
                  .shade700, // You can change the background color as needed
              shape: BoxShape.circle,
            ),
            child: Center(
              child: TextButton(
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 150,
              child: DrawerHeader(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/pattern.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.userName.trim(),
                    style: TextStyle(
                      color: Colors.brown.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.home,
                color: Colors.brown.shade700,
                size: 30,
              ),
              title: Text(
                'Dashboard',
                style: TextStyle(
                    color: Colors.brown.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
              ),
              onTap: () {},
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Divider(
                height: 1,
                indent: 0,
                endIndent: 10,
                thickness: 2,
                color: Colors.brown.shade50,
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.settings,
                color: Colors.brown.shade700,
                size: 30,
              ),
              title: Text(
                'Account Details',
                style: TextStyle(
                    color: Colors.brown.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AccountDetails(
                              name: widget.userName.trim(),
                            )));
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Divider(
                height: 1,
                indent: 0,
                endIndent: 10,
                thickness: 2,
                color: Colors.brown.shade50,
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.key_sharp,
                color: Colors.brown.shade700,
                size: 30,
              ),
              title: Text(
                'Change Password',
                style: TextStyle(
                    color: Colors.brown.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ResetPassword()));
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Divider(
                height: 1,
                indent: 0,
                endIndent: 10,
                thickness: 2,
                color: Colors.brown.shade50,
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.feedback_outlined,
                color: Colors.brown.shade700,
                size: 30,
              ),
              title: Text(
                'Complain',
                style: TextStyle(
                    color: Colors.brown.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FeedbackRegister(
                              name: widget.userName.trim(),
                            )));
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Divider(
                height: 1,
                indent: 0,
                endIndent: 10,
                thickness: 2,
                color: Colors.brown.shade50,
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.logout_outlined,
                color: Colors.brown.shade700,
                size: 30,
              ),
              title: Text(
                'Logout',
                style: TextStyle(
                    color: Colors.brown.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
              ),
              onTap: () {
                //logout
                signOut();
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Blurred background image
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/pattern.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: ListView(children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          formattedTime,
                          style: TextStyle(
                              color: Colors.brown.shade800,
                              fontSize: 100,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          formattedDate,
                          style: TextStyle(
                            color: Colors.brown.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: width * 0.05, vertical: 10),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Unit Date And Time: ',
                          style: TextStyle(
                            color: Colors.brown.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 27,
                          ),
                        )),
                  ),
                  Container(
                    width: width * .6,
                    // height: height * .1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        width: 2,
                        color: Colors.brown,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: width * .05, vertical: width * .03),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.date_range_outlined,
                              color: Colors.brown.shade700,
                              size: 30,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              '$day / $month / $year',
                              style: TextStyle(
                                  color: Colors.brown.shade800,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.hourglass_bottom_outlined,
                              color: Colors.brown.shade700,
                              size: 30,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              '$hour:$minute',
                              style: TextStyle(
                                  color: Colors.brown.shade800,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: SizedBox(
                      width: width * .7,
                      child: const Divider(
                        height: 1,
                        indent: 0,
                        endIndent: 10,
                        thickness: 2,
                        color: Colors.brown,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.05,
                    ),
                    child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          'Pray Times: ',
                          style: TextStyle(
                            color: Colors.brown.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 27,
                          ),
                        )),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: width * .07, vertical: 10),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Image.asset('images/fajr.png'),
                          title: Text(
                            'Fajr',
                            style: TextStyle(
                                color: Colors.brown.shade800, fontSize: 25),
                          ),
                          trailing: Text(
                            '$fajrHour:$fajrMinute',
                            style: TextStyle(
                                color: Colors.brown.shade800,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ListTile(
                          leading: Image.asset('images/zuhr.png'),
                          title: Text(
                            'Zuhr',
                            style: TextStyle(
                                color: Colors.brown.shade800, fontSize: 25),
                          ),
                          trailing: Text(
                            '$duhrHour:$duhrMinute',
                            style: TextStyle(
                                color: Colors.brown.shade800,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ListTile(
                          leading: Image.asset('images/asr.png'),
                          title: Text(
                            'Asr',
                            style: TextStyle(
                                color: Colors.brown.shade800, fontSize: 25),
                          ),
                          trailing: Text(
                            '$asrHour:$asrMinute',
                            style: TextStyle(
                                color: Colors.brown.shade800,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ListTile(
                          leading: Image.asset('images/maghrib.png'),
                          title: Text(
                            'Maghrib',
                            style: TextStyle(
                                color: Colors.brown.shade800, fontSize: 25),
                          ),
                          trailing: Text(
                            '$maghrebHour:$maghrebMinute',
                            style: TextStyle(
                                color: Colors.brown.shade800,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ListTile(
                          leading: Image.asset('images/isha.png'),
                          title: Text(
                            'isha',
                            style: TextStyle(
                                color: Colors.brown.shade800, fontSize: 25),
                          ),
                          trailing: Text(
                            '$ishaHour:$ishaMinute',
                            style: TextStyle(
                              color: Colors.brown.shade800,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }
}