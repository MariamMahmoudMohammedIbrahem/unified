import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../constants.dart';
import '../functions.dart';
import 'ble_device_connector.dart';
import 'ble_logger.dart';
import 'ble_scanner.dart';
import 'package:provider/provider.dart';
import 'package:functional_data/functional_data.dart';

part 'device_list.g.dart';

//ignore_for_file: annotate_overrides


class DeviceListScreen extends StatelessWidget {
  const DeviceListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      Consumer4<BleScanner, BleScannerState?, BleLogger, BleDeviceConnector>(
        builder:
            (_, bleScanner, bleScannerState, bleLogger, deviceConnector, __) =>
                Connect(
          scannerState: bleScannerState ??
              const BleScannerState(
                discoveredDevices: [],
                scanIsInProgress: false,
              ),
          startScan: bleScanner.startScan,
          stopScan: bleScanner.stopScan,
          deviceConnector: deviceConnector,
        ),
      );
}

@immutable
@FunctionalData()
class DeviceInteractionViewModel extends $DeviceInteractionViewModel {
  const DeviceInteractionViewModel({
    required this.deviceId,
    required this.deviceConnector,
    required this.discoverServices,
  });

  final String deviceId;
  final BleDeviceConnector deviceConnector;
  @CustomEquality(Ignore())
  final Future<List<DiscoveredService>> Function() discoverServices;

  void connect() {
    deviceConnector.connect(deviceId);
  }

  void disconnect() {
    deviceConnector.disconnect(deviceId);
  }
}

class Connect extends StatefulWidget {
  const Connect(
      {required this.scannerState,
      required this.startScan,
      required this.stopScan,
      required this.deviceConnector,
      super.key});
  final BleScannerState scannerState;
  final void Function(List<Uuid>) startScan;
  final VoidCallback stopScan;
  final BleDeviceConnector deviceConnector;
  @override
  State<Connect> createState() => _ConnectState();
}

class _ConnectState extends State<Connect> {
  StreamSubscription<DiscoveredDevice>? _scanSubscription;
  String _deviceId = '';
  void startScanning() {
    setState(() {
      widget.deviceConnector.disconnect(_deviceId);
    });
    _scanSubscription = ble.scanForDevices(
      withServices: [],
      scanMode: ScanMode.lowLatency,
    ).listen((scanResult) {
      setState(() {
        deviceName = scanResult.name;
      });
      print('deviceName$deviceName');
      if (scanResult.name.isNotEmpty) {
        _deviceId = scanResult.id;
        setState(() {
          widget.deviceConnector.connect(scanResult.id);
        });
        stopScanning(); // Stop scanning when a device is found
      }
    });
  }

  void stopScanning() {
    _scanSubscription?.cancel(); // Cancel the subscription to stop scanning
  }

  // void connectToDevice(String deviceId) {
  //   print('in2');
  //   ble
  //       .connectToDevice(
  //     id: deviceId,
  //     connectionTimeout: const Duration(seconds: 10),
  //   )
  //       .listen((connectionState) {
  //     print('in3');
  //     if (connectionState.connectionState == DeviceConnectionState.connected) {
  //       setState(() {
  //         print('in4');
  //         connected = true;
  //         _deviceId = deviceId; // Set the connected device ID
  //       });
  //     }
  //   }, onError: (dynamic error) {
  //         connected = false;
  //     print('Connection error: $error');
  //   });
  // }

  Future<void> writeData(List<int> value) async {
    if (_deviceId.isNotEmpty) {
      try {
        await ble.writeCharacteristicWithoutResponse(
          QualifiedCharacteristic(
            characteristicId: Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb"),
            serviceId: Uuid.parse("0000ffe0-0000-1000-8000-00805f9b34fb"),
            deviceId: _deviceId,
          ),
          value: value,
        );
        print('Data written successfully');
      } catch (error) {
        print('Error writing data: $error');
      }
    } else {
      print('Device not connected');
    }
  }

  StreamSubscription<List<int>>? dateSubscription;
  StreamSubscription<List<int>>? locationSubscription;
  StreamSubscription<List<int>>? praySubscription;
  StreamSubscription<List<int>>? zoneSubscription;
  bool awaitingResponse = false;
  void resetDateSubscription(int dataType) {
    switch(dataType){
      case 1:
        dateSubscription?.cancel(); // Cancel the existing subscription
        dateSubscription = null; // Reset dateSubscription to null
        break;
      case 2:
        locationSubscription?.cancel();
        locationSubscription = null;
        break;
      case 3:
        praySubscription?.cancel();
        praySubscription = null;
        break;
      case 4:
        zoneSubscription?.cancel();
        zoneSubscription = null;
        break;
    }
  }
  void subscribeCharacteristic(int dataType) {
    Stream<List<int>> stream;
    switch (dataType) {
      case 1:
        dateSubscription?.resume();
        locationSubscription?.pause();
        praySubscription?.pause();
        zoneSubscription?.pause();
        if (dateSubscription == null) {
        print('in subscribe');
          stream = _createSubscription();
          dateSubscription = stream.listen((event) {
            setState(() {
              print('1$event');
              if(event.length == 11){
                dateList = List.from(event);
                year = convertToInt(event, 3, 1);
                month = convertToInt(event, 4, 1);
                day = convertToInt(event, 5, 1);
                hour = convertToInt(event, 6, 1);
                minute = convertToInt(event, 7, 1);
                second = convertToInt(event, 8, 1);
              }
            });
          });
        }
        break;
      case 2:
        dateSubscription?.pause();
        locationSubscription?.resume();
        praySubscription?.pause();
        zoneSubscription?.pause();
        if (locationSubscription == null) {
          stream = _createSubscription();
          locationSubscription = stream.listen((event) {
            setState(() {
              print('2$event');
              if(event.length == 13){
                locationList = List.from(event);
                latitude = convertToInt(event, 3, 4);
                longitude = convertToInt(event, 7, 4);
              }
            });
          });
        }
        break;
      case 3:
        dateSubscription?.pause();
        locationSubscription?.pause();
        praySubscription?.resume();
        zoneSubscription?.pause();
        if (praySubscription == null) {
          stream = _createSubscription();
          praySubscription = stream.listen((event) {
            setState(() {
              print('3$event');
              if(event.length == 15){
                prayList = List.from(event);
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
              print('4$event');
              if(event.length == 6){
                zoneList = List.from(event);
                zone = convertToInt(event, 3, 1);
              }
            });
          });
        }
        break;
    }
  }

  Stream<List<int>> _createSubscription() {
    return ble
        .subscribeToCharacteristic(
      QualifiedCharacteristic(
        characteristicId: Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb"),
        serviceId: Uuid.parse("0000ffe0-0000-1000-8000-00805f9b34fb"),
        deviceId: _deviceId,
      ),
    )
        .distinct()
        .asyncMap((event) async {
      // You can process event or modify data before updating the list
      return List<int>.from(event);
    });
  }
  // void getDataAndSubscribe(int dataType, List<int> dataToWrite) {
  //   StreamSubscription<List<int>>? currentSubscription;
  //
  //   switch (dataType) {
  //     case 1:
  //       currentSubscription = dateSubscription;
  //       break;
  //     case 2:
  //       currentSubscription = locationSubscription;
  //       break;
  //     case 3:
  //       currentSubscription = praySubscription;
  //       break;
  //     case 4:
  //       currentSubscription = zoneSubscription;
  //       break;
  //   }
  //
  //   // Unpause the current subscription and pause others
  //   dateSubscription?.pause();
  //   locationSubscription?.pause();
  //   praySubscription?.pause();
  //   zoneSubscription?.pause();
  //
  //   if (currentSubscription == null) {
  //     Stream<List<int>> stream = _createSubscription();
  //     currentSubscription = stream.listen((event) {
  //       setState(() {
  //         switch (dataType) {
  //           case 1:
  //             dateList = List.from(event);
  //             break;
  //           case 2:
  //             locationList = List.from(event);
  //             break;
  //           case 3:
  //             prayList = List.from(event);
  //             break;
  //           case 4:
  //             zoneList = List.from(event);
  //             break;
  //         }
  //       });
  //     });
  //
  //     switch (dataType) {
  //       case 1:
  //         dateSubscription = currentSubscription;
  //         break;
  //       case 2:
  //         locationSubscription = currentSubscription;
  //         break;
  //       case 3:
  //         praySubscription = currentSubscription;
  //         break;
  //       case 4:
  //         zoneSubscription = currentSubscription;
  //         break;
  //     }
  //   }
  //
  //   // Write data to the BLE device
  //   writeData(dataToWrite);
  // }


  void getAllDataAndSubscribe() async {
    List<Map<int, List<int>>> dataSets = [
      {1: getDate},
      {2: getLocation},
      {3: getPray},
      {4: getZone},
    ];

    for (var data in dataSets) {
      int dataType = data.keys.first;
      List<int> dataToWrite = data.values.first;
      print('dataType$dataType');
      print('dataToWrite$dataToWrite');
      print(awaitingResponse);
      if (!awaitingResponse) {
        awaitingResponse = true;
        resetDateSubscription(dataType);
        subscribeCharacteristic(dataType);
        await writeData(dataToWrite);
        await Future.delayed(const Duration(seconds: 2));
        awaitingResponse = false;
      } else {
        print('Awaiting response, cannot send another packet yet.');
        break; // Exit the loop if awaiting a response
      }
    }
  }

  void initState() {
    startScanning();
    // setState(() {
    //   getCurrentDateTime();
    // });
    //timer
    Timer.periodic(const Duration(seconds: 2), (Timer t) {
      //if !connected startScanning
      if(!connected){
        startScanning();
      }
      //else get the data from the ble device
      else{
        subscribeCharacteristic(1);
        writeData(getDate);
      }
      t.cancel();
    });
    //timer for calculating the time periodically
    // Timer.periodic(const Duration(minutes: 1), (Timer t) {
    //   setState(() {
    //     getCurrentDateTime();
    //   });
    // });
    super.initState();
  }

  void dispose() {
    _scanSubscription
        ?.cancel(); // Cancel the subscription when the widget is disposed
    super.dispose();
    // timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: width*.4,
                height: height*.1,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(width: 2,color: Colors.grey,),
                ),
                padding: EdgeInsets.symmetric(horizontal: width*.05, vertical: width*.03),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.date_range_outlined),
                        const SizedBox(width: 5,),
                        Text(formattedDate),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.hourglass_bottom_outlined),
                        const SizedBox(width: 5,),
                        Text(formattedTime),
                      ],
                    )
                  ],
                ),
              ),
              Container(
                width: width*.4,
                height: height*.1,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(width: 2,color: Colors.grey,),
                ),
                padding: EdgeInsets.symmetric(horizontal: width*.05, vertical: width*.03),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.date_range_outlined),
                        const SizedBox(width: 5,),
                        Text('$day / $month / $year'),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.hourglass_bottom_outlined),
                        const SizedBox(width: 5,),
                        Text('$hour:$minute'),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          ElevatedButton(
              onPressed:(){
                startScanning();
                Future.delayed(const Duration(seconds: 5), () {
                  stopScanning();
                });
              },
              child: const Text('scan')),
          ElevatedButton(onPressed: getAllDataAndSubscribe, child: const Text('get all data'),),
          Row(
            children: [
              Text('Device Name: $deviceName'),
              Icon(connected ? Icons.done_all : Icons.remove_done),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text(
                'Time/Date',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  subscribeCharacteristic(1);
                  writeData(getDate);
                  print('press');
                },
                child: const Text('Get Date'),
              ),
            ],
          ),
          Text('$dateList'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text(
                'Location',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  subscribeCharacteristic(2);
                  writeData(getLocation);
                },
                child: const Text('Get Location'),
              ),
            ],
          ),
          Text('$locationList'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text(
                'Prays Times',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  subscribeCharacteristic(3);
                  writeData(getPray);
                },
                child: const Text('Get Prays Times'),
              ),
            ],
          ),
          Text('$prayList'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text(
                'Time Zone',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  subscribeCharacteristic(4);
                  writeData(getZone);
                },
                child: const Text('Get Time Zones'),
              ),
            ],
          ),
          Text('$zoneList'),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  writeData(getSound1);
                },
                child: const Text('sound 1'),
              ),
              ElevatedButton(
                onPressed: () {
                  writeData(getSound2);
                },
                child: const Text('sound 2'),
              ),
            ],
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  writeData(getSound3);
                },
                child: const Text('sound 3'),
              ),
              ElevatedButton(
                onPressed: () {
                  writeData(getSound4);
                },
                child: const Text('sound 4'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
