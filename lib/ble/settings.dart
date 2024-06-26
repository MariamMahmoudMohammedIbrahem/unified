import 'dart:async';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:azan/ble/scan.dart';
import 'package:azan/t_key.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  final Future<List<Service>> Function() discoverServices;

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

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.brown.shade800,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context,true);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 35,),
        ),
        title: Text(TKeys.settings.translate(context),style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 20,),),
        centerTitle: true,
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
                            TKeys.longitudeLatitude.translate(context),
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

                            showToastMessage();
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        child: Container(
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
                                TKeys.unitData.translate(context),
                                style: TextStyle(
                                    color: Colors.brown.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22),
                              ),
                              Text(
                                '${TKeys.longitude.translate(context)}: $unitLongitude',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.brown.shade700),
                              ),
                              Text(
                                '${TKeys.latitude.translate(context)}: $unitLatitude',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.brown.shade700),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
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
                                TKeys.storedData.translate(context),
                                style: TextStyle(
                                    color: Colors.brown.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22),
                              ),
                              Text(
                                '${TKeys.longitude.translate(context)}: $storedLongitude',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.brown.shade700),
                              ),
                              Text(
                                '${TKeys.latitude.translate(context)}: $storedLatitude',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.brown.shade700),
                              ),
                            ],
                          ),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          TKeys.zone.translate(context),
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
                        horizontal: width * 0.07, vertical: 10),
                    child: Row(
                      children: [
                        Text(
                          TKeys.currentZone.translate(context),
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
                        if(awaitingResponse){
                          Fluttertoast.showToast(
                            msg: 'can\'t disconnect while getting data',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.brown.shade700,
                            textColor: Colors.white,
                          );
                        }
                        else{
                          settingDate();
                        }
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
                      label:  Text(
                        TKeys.settingPrayerTimes.translate(context),
                        style: const TextStyle(color: Colors.white, fontSize: 24),
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
                            storedArea = value;
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
                                  storedArea == '' ? TKeys.selectArea.translate(context) : storedArea,
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
                      onPressed: () {
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
                      label: Text(
                        TKeys.settingUnitLocation.translate(context),
                        style: const TextStyle(color: Colors.white, fontSize: 24),
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
                      label: Text(
                        TKeys.settingUnitZone.translate(context),
                        style: const TextStyle(color: Colors.white, fontSize: 24),
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
                        Icons.auto_mode_outlined,
                        color: Colors.white,
                      ),
                      label: Text(
                        TKeys.testMode.translate(context),
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
                          TKeys.soundOptions.translate(context),
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
                        onSelected: (String value) {
                          setState(() {
                            sound = value;
                          });
                          settingSound(sound);
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
                                  sound == '' ? TKeys.selectSound.translate(context) : sound,
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

  void getAllDataAndSubscribe() async {
    List<Map<int, List<int>>> dataSets = [
      {1: getDate},
      {2: getPray},
      {3: getLocation},
      {4: getZone},
    ];

    for (var data in dataSets) {
      if (kDebugMode) {
        print('inside hello');
      }
      int dataType = data.keys.first;
      List<int> dataToWrite = data.values.first;
      if (kDebugMode) {
        print('dataType $dataType');
        print('dataToWrite $dataToWrite');
        print('awaiting response $awaitingResponse');
      }
      if (!awaitingResponse) {
        awaitingResponse = true;
        resetDateSubscription(dataType);
        subscribeCharacteristic(dataType, widget.viewModel.deviceId);
        await widget.writeWithoutResponse(widget.characteristic, dataToWrite);
      } else {
        if (kDebugMode) {
          print('Awaiting response, cannot send another packet yet.');
        }
        break; // Exit the loop if awaiting a response
      }
    }
    if (!list1) {
      resetDateSubscription(1);
      subscribeCharacteristic(1, widget.viewModel.deviceId);
      await widget.writeWithoutResponse(widget.characteristic, getDate);
    } else if (!list2) {
      //edit
      resetDateSubscription(2);
      subscribeCharacteristic(2, widget.viewModel.deviceId);
      await widget.writeWithoutResponse(widget.characteristic, getPray);
    } else if (!list3) {
      resetDateSubscription(3);
      subscribeCharacteristic(3, widget.viewModel.deviceId);
      await widget.writeWithoutResponse(widget.characteristic, getLocation);
    } else {
      resetDateSubscription(4);
      subscribeCharacteristic(4, widget.viewModel.deviceId);
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
        if (kDebugMode) {
          print('Received expected data, setting date and time');
        }
        responseSubscription?.cancel();
        setDateTime = true;
        periodicTimer?.cancel();
        hourTimer?.cancel();
        disconnectRestart();
      }
    });
  }

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
            Text(TKeys.restarting.translate(context), style: TextStyle(fontSize: 17,color: Colors.brown.shade700),),
          ],
        ),
      ),
    );
    try{
      List<int> dataSets = [1,2,3,4];
      for (int data in dataSets) {
        resetDateSubscription(data);
      }
      widget.writeWithoutResponse(widget.characteristic, restart).then((value) {
        widget.subscribeToCharacteristic(widget.characteristic);
      }).then((value) async {
        await Future.delayed(const Duration(seconds: 2));
      });
      // timer = Timer.periodic(const Duration(seconds: 2), (Timer t) {
      if (widget.viewModel.connectionStatus == DeviceConnectionState.disconnected) {
        setState(() {
          found = false;
          deviceName = '';
          restartFlag = true;
          hourTimer?.cancel();
          periodicTimer?.cancel();
        });
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
        ///show dialog alert that tell to try again
        Navigator.pop(context);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.brown.shade50,
            title: Text(TKeys.disconnectTitle.translate(context)),
            content: Text(TKeys.disconnectHeadline.translate(context)),
            actions: [
              ElevatedButton(
                onPressed: (){
                  if(widget.viewModel.connectionStatus == DeviceConnectionState.disconnected){
                    setState(() {
                      hourTimer?.cancel();
                      periodicTimer?.cancel();
                    });
                    widget.viewModel.disconnect();
                  }
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> ScanningListScreen(userName: widget.userName)), (route) => false);
                },
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.brown,
                    backgroundColor: Colors.brown.shade600,
                    disabledForegroundColor: Colors.brown.shade600,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: Text(TKeys.ok.translate(context),style: const TextStyle(color: Colors.white,fontSize: 18),),
              ),
            ],
          ),
        );
      }
      // });
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
          content: Text(TKeys.restartError.translate(context)),
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
              child: Text(TKeys.ok.translate(context),style: const TextStyle(color: Colors.white,fontSize: 18),),
            ),
          ],
        ),
      );
    }

  }

  void settingLocation() {
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
            Text(TKeys.updating.translate(context), style: TextStyle(fontSize: 17,color: Colors.brown.shade700),),
          ],
        ),
      ),
    );

    try {
      // widget.subscribeToCharacteristic(widget.characteristic);
      widget.writeWithoutResponse(widget.characteristic, setLocation).then((value) {
        responseSubscription = widget
            .subscribeToCharacteristic(widget.characteristic)
            .listen((receivedData) {
          if (receivedData.length == success.length &&
              receivedData.every(
                      (element) => element == success[receivedData.indexOf(element)])) {
            if (kDebugMode) {
              print('Received expected data, setting date and time');
            }
            responseSubscription?.cancel();
            if (kDebugMode) {
              print('ready to get data');
            }
            //add get all data
            awaitingResponse = false;
            saveSettingData(2, widget.userName);
            // showToast = true;
            showToastMessage();
            getAllDataAndSubscribe();
            Navigator.pop(context);
          }
          else{
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.brown.shade50,
                title: Text(TKeys.error.translate(context)),
                content: Text(TKeys.locationError.translate(context)),
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
                    child: Text(TKeys.ok.translate(context),style: const TextStyle(color: Colors.white,fontSize: 18),),
                  ),
                ],
              ),
            );
          }
        });
      });
    }
    catch(e){
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.brown.shade50,
          title: Text(TKeys.error.translate(context)),
          content: Text(TKeys.locationError.translate(context)),
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
              child: Text(TKeys.ok.translate(context),style: const TextStyle(color: Colors.white,fontSize: 18),),
            ),
          ],
        ),
      );
    }
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
        if (kDebugMode) {
          print('Received expected data, setting date and time');
        }
        responseSubscription?.cancel();
        if (kDebugMode) {
          print('ready to get data');
        }
        saveSettingData(3, widget.userName);
        showToastMessage();
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
    switch(dataType){
      case 'sound 1':
        await widget.writeWithoutResponse(widget.characteristic, getSound1);
        break;
      case 'sound 2':
        await widget.writeWithoutResponse(widget.characteristic, getSound2);
        break;
      case 'sound 3':
        await widget.writeWithoutResponse(widget.characteristic, getSound3);
        break;
      case 'sound 4':
        await widget.writeWithoutResponse(widget.characteristic, getSound4);
        break;
    }
    widget.subscribeToCharacteristic(widget.characteristic);

  }
}