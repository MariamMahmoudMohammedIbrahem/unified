import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:azan/ble/ble_status_monitor.dart';
import 'package:azan/ble/settings.dart';
import 'package:azan/t_key.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
        locationSubscription?.cancel();
        praySubscription?.cancel();
        zoneSubscription?.cancel();
        if (dateSubscription == null) {
          stream = _createSubscription();
          dateSubscription = stream.listen((event) {
            setState(() {
              print('1$event');
              if (event.length == 11) {
                // dateList = List.from(event);
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
          });
        }
        break;
      case 2:
        dateSubscription?.cancel();
        locationSubscription?.cancel();
        praySubscription?.resume();
        zoneSubscription?.cancel();
        if (praySubscription == null) {
          stream = _createSubscription();
          praySubscription = stream.listen((event) {
            setState(() {
              print('2$event');
              if (event.length == 15) {
                // prayList = List.from(event);
                fajrHour = convertToInt(event, 3, 1);
                // fajrMinute = convertToInt(event, 4, 1);
                fajrMinute = convertToInt(event, 4, 1).toString().padLeft(2, '0');
                duhrHour = convertToInt(event, 5, 1);
                // duhrMinute = convertToInt(event, 6, 1);
                duhrMinute = convertToInt(event, 6, 1).toString().padLeft(2, '0');
                asrHour = convertToInt(event, 7, 1);
                // asrMinute = convertToInt(event, 8, 1);
                asrMinute = convertToInt(event, 8, 1).toString().padLeft(2, '0');
                maghrebHour = convertToInt(event, 9, 1);
                // maghrebMinute = convertToInt(event, 10, 1);
                maghrebMinute = convertToInt(event, 10, 1).toString().padLeft(2, '0');
                ishaHour = convertToInt(event, 11, 1);
                // ishaMinute = convertToInt(event, 12, 1);
                ishaMinute = convertToInt(event, 12, 1).toString().padLeft(2, '0');
                list2 = true;
                awaitingResponse = false;
              }
            });
          });
        }
        break;
      case 3:
        dateSubscription?.cancel();
        locationSubscription?.resume();
        praySubscription?.cancel();
        zoneSubscription?.cancel();
        if (locationSubscription == null) {
          stream = _createSubscription();
          locationSubscription = stream.listen((event) {
            setState(() {
              print('3$event');
              if (event.length == 13) {
                unitLatitude = convertToInt(event, 3, 4)/1000000;
                // unitLongitude = int.parse('${event[7].toString().padLeft(2, '0')}${event[8].toString().padLeft(2, '0')}${event[9].toString().padLeft(2, '0')}${event[10].toString().padLeft(2, '0')}');
                unitLongitude = convertToInt(event, 7, 4)/1000000;
                list3 = true;
                awaitingResponse = false;
              }
            });
          });
        }
        break;
      case 4:
        dateSubscription?.cancel();
        locationSubscription?.cancel();
        praySubscription?.cancel();
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
                showToast = false;
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
    showToast = true;
    showToastMessage();
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
    hourTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      updateDateTime(); // Trigger the update asynchronously
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
        periodicTimer?.cancel();
        hourTimer?.cancel();
        disconnectRestart();
      }
    });
  }

  late StreamSubscription<$ConnectionStateUpdate> connectionStateSubscription;

  Future<void> disconnectRestart() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.brown.shade50,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.brown.shade700,),
            const SizedBox(height: 16.0),
            Text('Restarting...', style: TextStyle(fontSize: 17,color: Colors.brown.shade700),),
          ],
        ),
      ),
    );
    try{
      List<int> dataSets = [1,2,3,4];
      for (int data in dataSets) {
        resetDateSubscription(data);
      }
      await widget.writeWithoutResponse(widget.characteristic, restart);
      widget.subscribeToCharacteristic(widget.characteristic);
      // await Future.delayed(const Duration(seconds: 1));
      // widget.device.connectable.
      timer = Timer.periodic(const Duration(seconds: 2), (Timer t) {
        if (widget.viewModel.connectionStatus == DeviceConnectionState.disconnected) {
          setState(() {
            found = false;
            deviceName = '';
            restartFlag = true;
          });
          // Cancel the timer if the condition is met
          timer?.cancel();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScanningListScreen(
                userName: widget.userName,
              ),
            ),
          );
        }
        else{
        }
      });
      // if (widget.viewModel.connectionStatus ==
      //     DeviceConnectionState.disconnected) {
      //   setState(() {
      //     found = false;
      //     deviceName = '';
      //     restartFlag = true;
      //   });
      //   Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //           builder: (context) => ScanningListScreen(
      //             userName: widget.userName,
      //           )));
      // }
    }
    catch(e){
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.brown.shade50,
          title: Text(TKeys.error.translate(context)),
          content: Text('Failed to update. Please Try Again :('),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.brown,
                  backgroundColor: Colors.brown.shade600,
                  disabledForegroundColor: Colors.brown.shade600,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('OK',style: TextStyle(color: Colors.white,fontSize: 18),),
            ),
          ],
        ),
      );
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
      list1 = false;
      list2 = false;
      list3 = false;
      list4 = false;
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
        bool shouldPop = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.brown.shade50,
              title: Text(TKeys.confirmExitTitle.translate(context), style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),),
              content: Text(TKeys.confirmExitHeadline.translate(context), style: TextStyle(fontSize: 17,color: Colors.brown.shade700),),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.brown,
                      backgroundColor: Colors.brown.shade200,
                      disabledForegroundColor: Colors.brown.shade600,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: Text(TKeys.yes.translate(context),style: TextStyle(color: Colors.brown.shade800,fontSize: 18),),
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
                  child: Text(TKeys.no.translate(context),style: const TextStyle(color: Colors.white,fontSize: 18),),
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
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          backgroundColor: Colors.brown.shade800,
          leadingWidth: 70,
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.brown.shade50, // You can change the background color as needed
                shape: BoxShape.circle,
              ),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: Colors.brown.shade800,
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
                    TKeys.dashboard.translate(context),
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
                    TKeys.accountDetails.translate(context),
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
                    TKeys.changePassword.translate(context),
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
                    TKeys.complain.translate(context),
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
                                  name: widget.userName,
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
                          TKeys.settings.translate(context),
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
                    TKeys.logout.translate(context),
                    style: TextStyle(
                        color: Colors.brown.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 25),
                  ),
                  onTap: () {
                    //logout
                    _scaffoldKey.currentState?.closeDrawer();
                    setState(() {
                      found = false;
                      deviceName = '';
                    });
                    periodicTimer?.cancel();
                    hourTimer?.cancel();
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
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.brown.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                          children: [
                            TextSpan(text: formattedDate),
                            const TextSpan(text: '\n'),
                            TextSpan(text: formattedTime, style: const TextStyle(fontSize: 85)),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: width * 0.05, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            TKeys.dateTime.translate(context),
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
                              Future.delayed(const Duration(seconds: 1));
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            TKeys.city.translate(context),
                            style: TextStyle(
                              color: Colors.brown.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 27,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: width * .07, vertical: 10),
                      child: Text(area,
                        style: TextStyle(
                            color: Colors.brown.shade800, fontSize: 25, fontWeight: FontWeight.bold),),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            TKeys.prayTimes.translate(context),
                            style: TextStyle(
                              color: Colors.brown.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 27,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: width * .07, vertical: 10),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Image.asset('images/fajr.png'),
                            title: Text(
                              TKeys.fajr.translate(context),
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
                              TKeys.duhr.translate(context),
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
                              TKeys.asr.translate(context),
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
                              TKeys.maghreb.translate(context),
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
                              TKeys.isha.translate(context),
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  TKeys.settingOptions.translate(context),
                                  style: TextStyle(
                                    color: Colors.brown.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 27,
                                  ),
                                ),
                              ],
                            ),
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
                              label: Text(
                                TKeys.settingPrayerTimes.translate(context),
                                style: const TextStyle(color: Colors.white, fontSize: 24),
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
                              label: Text(
                                TKeys.restart.translate(context),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                ),
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
    skipData(widget.userName);
    hourTimer = Timer.periodic(const Duration(minutes: 1), (Timer t) {
      setState(() {
        print('skip page timer');
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
                TKeys.dashboard.translate(context),
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
                TKeys.accountDetails.translate(context),
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
                TKeys.changePassword.translate(context),
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
                TKeys.complain.translate(context),
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
                TKeys.logout.translate(context),
                style: TextStyle(
                    color: Colors.brown.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
              ),
              onTap: () {
                //logout
                setState(() {
                  found = false;
                  deviceName = '';
                });
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
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.brown.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                        children: [
                          TextSpan(text: formattedDate),
                          const TextSpan(text: '\n'),
                          TextSpan(text: formattedTime, style: const TextStyle(fontSize: 85)),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: width * 0.05, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          TKeys.dateTime.translate(context),
                          style: TextStyle(
                            color: Colors.brown.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 27,
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
                              ishaHour == 00 && ishaMinute == 00? formattedDateUnit: '$day / $month / $year',
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
                              ishaHour == 00 && ishaMinute == 00?formattedTimeUnit:'$hour:$minute',
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          TKeys.city.translate(context),
                          style: TextStyle(
                            color: Colors.brown.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 27,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: width * .07, vertical: 10),
                    child: Text(area,
                      style: TextStyle(
                          color: Colors.brown.shade800, fontSize: 25, fontWeight: FontWeight.bold),),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          TKeys.prayTimes.translate(context),
                          style: TextStyle(
                            color: Colors.brown.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 27,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: width * .07, vertical: 10),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Image.asset('images/fajr.png'),
                          title: Text(
                            TKeys.fajr.translate(context),
                            style: TextStyle(
                                color: Colors.brown.shade800, fontSize: 25),
                          ),
                          trailing: Text(
                            ishaHour == 00 && ishaMinute == 00?fajr:'$fajrHour:$fajrMinute',
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
                            TKeys.duhr.translate(context),
                            style: TextStyle(
                                color: Colors.brown.shade800, fontSize: 25),
                          ),
                          trailing: Text(
                            ishaHour == 00 && ishaMinute == 00?duhr:'$duhrHour:$duhrMinute',
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
                            TKeys.asr.translate(context),
                            style: TextStyle(
                                color: Colors.brown.shade800, fontSize: 25),
                          ),
                          trailing: Text(
                            ishaHour == 00 && ishaMinute == 00?asr:'$asrHour:$asrMinute',
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
                            TKeys.maghreb.translate(context),
                            style: TextStyle(
                                color: Colors.brown.shade800, fontSize: 25),
                          ),
                          trailing: Text(
                            ishaHour == 00 && ishaMinute == 00?maghreb:'$maghrebHour:$maghrebMinute',
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
                            TKeys.isha.translate(context),
                            style: TextStyle(
                                color: Colors.brown.shade800, fontSize: 25),
                          ),
                          trailing: Text(
                            ishaHour == 00 && ishaMinute == 00?isha:'$ishaHour:$ishaMinute',
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