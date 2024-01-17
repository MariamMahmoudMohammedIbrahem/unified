import 'dart:async';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:azan/ble/scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:functional_data/functional_data.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../functions.dart';
import 'ble_device_connector.dart';
import 'ble_device_interactor.dart';
import 'device_list.dart';

class SettingTab extends StatelessWidget {
  const SettingTab({
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
        Setting(
          viewModel: SettingViewModel(
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
          name: device.name,
          userName: userName,
          // device: device,
        ),
  );
}

@FunctionalData()
class SettingViewModel extends $DeviceInteractionViewModel {
  const SettingViewModel({
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

class Setting extends StatefulWidget {

  const Setting({
    required this.viewModel,
    required this.characteristic,
    required this.writeWithResponse,
    required this.writeWithoutResponse,
    required this.readCharacteristic,
    required this.subscribeToCharacteristic,
    required this.name,
    required this.userName,
    // required this.device,
    super.key,
  });
  final SettingViewModel viewModel;

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
  final String name;
  final String userName;
  // final DiscoveredDevice device;

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
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
                // unitLatitude = int.parse('${event[3].toString().padLeft(2, '0')}${event[4].toString().padLeft(2, '0')}${event[5].toString().padLeft(2, '0')}${event[6].toString().padLeft(2, '0')}');
                unitLatitude = convertToInt(event, 3, 4);
                // unitLongitude = int.parse('${event[7].toString().padLeft(2, '0')}${event[8].toString().padLeft(2, '0')}${event[9].toString().padLeft(2, '0')}${event[10].toString().padLeft(2, '0')}');
                unitLongitude = convertToInt(event, 7, 4);
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
    print('inside the function');
    await widget.writeWithoutResponse(widget.characteristic, restart);
    widget.subscribeToCharacteristic(widget.characteristic);
    await Future.delayed(const Duration(seconds: 1));
    if (widget.viewModel.connectionStatus ==
        DeviceConnectionState.disconnected) {
      setState(() {
        found = false;
        deviceName = '';
      });
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ScanningListScreen(
                userName: widget.userName,
              ))).then(
            (value) => restartFlag = true,
      );
    }
  }

  //problem here
  Future<void> settingLocation() async {
    print('inside the zft');
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
        //add get all data
        saveSettingData(2, widget.userName);
        getAllDataAndSubscribe();
      }
    });
  }

  Future<void> settingZone() async {
    widget.subscribeToCharacteristic(widget.characteristic);
    await widget.writeWithoutResponse(widget.characteristic, setZone);
    responseSubscription = widget
        .subscribeToCharacteristic(widget.characteristic)
        .listen((receivedData) {
      if (receivedData.length == success.length &&
          receivedData.every(
                  (element) => element == success[receivedData.indexOf(element)])) {
        print('Received expected data, setting date and time');
        responseSubscription?.cancel();
        print('ready to get data');
        saveSettingData(3, widget.userName);
        getAllDataAndSubscribe();
      }
    });
  }
  Future<void> testingMode() async{
    widget
        .subscribeToCharacteristic(widget.characteristic);
    await widget.writeWithoutResponse(
        widget.characteristic, getTest);
    saveSettingData(5, widget.userName);
  }
  Future<void> settingSound(String dataType) async{
    // List<int> soundPacket = [];
    switch(dataType){
      case 'sound 1':
        // soundPacket = getSound1;
        await widget.writeWithoutResponse(widget.characteristic, getSound1);
        break;
      case 'sound 2':
        // soundPacket = getSound2;
        await widget.writeWithoutResponse(widget.characteristic, getSound2);
        break;
      case 'sound 3':
        // soundPacket = getSound3;
        await widget.writeWithoutResponse(widget.characteristic, getSound3);
        break;
      case 'sound 4':
        // soundPacket = getSound4;
        await widget.writeWithoutResponse(widget.characteristic, getSound4);
        break;
    }
    widget.subscribeToCharacteristic(widget.characteristic);

  }
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context,true);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.brown.shade800,
            size: 35,),
        ),
      ),
      body: Stack(
        children: [
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
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: width * 0.05, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: width*.6,
                          child: AutoSizeText(
                            'Unit Longitude And Latitude: ',
                            style: TextStyle(
                              color: Colors.brown.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 27,
                            ),
                            maxLines: 2,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: width * .4,
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
                            Text(
                              'Unit Data',
                              style: TextStyle(
                                  color: Colors.brown.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22),
                            ),
                            Text(
                              'longitude: $unitLongitude',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.brown.shade700),
                            ),
                            Text(
                              'latitude: $unitLatitude',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.brown.shade700),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: width * .4,
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
                            Text(
                              'Stored Data',
                              style: TextStyle(
                                  color: Colors.brown.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22),
                            ),
                            Text(
                              'longitude: $storedLongitude',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.brown.shade700),
                            ),
                            Text(
                              'latitude: $storedLatitude',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.brown.shade700),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                        horizontal: width * 0.05, vertical: 10),
                    child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          'Zone: ',
                          style: TextStyle(
                            color: Colors.brown.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 27,
                          ),
                        )),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: width * 0.07, vertical: 10),
                    child: Row(
                      children: [
                        Text(
                          'Current Zone: ',
                          style: TextStyle(
                            color: Colors.brown.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        Text('$zoneAfter', style: TextStyle(
                          color: Colors.brown.shade700,
                          fontSize: 18,
                        ),),
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
                  Padding(
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
                        await testingMode();
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
                        horizontal: width * 0.05, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sound Options: ',
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
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: SizedBox(
                      width: width * .8,
                      height: 55,
                      child: PopupMenuButton<String>(
                        onSelected: (String value) async {
                          setState(() async {
                            sound = value;
                            //send the sound packet
                            settingSound(sound);
                          });
                        },
                        color: Colors.brown.shade700,
                        itemBuilder: (BuildContext context) {
                          final List<PopupMenuEntry<String>> items = [];
                          for (String item in sounds) {
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
                            if (item != sounds.last) {
                              items.add(const PopupMenuDivider());
                            }
                          }
                          // items.add(const PopupMenuDivider());
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
                                  sound == '' ? 'Select A Sound' : sound,
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
                ],
              ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}