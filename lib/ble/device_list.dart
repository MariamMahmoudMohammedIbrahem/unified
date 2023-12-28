import 'dart:async';

import 'package:azan/ble/ble_device_interactor.dart';
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
  Widget build(BuildContext context) => Consumer5<BleScanner, BleScannerState?,
          BleLogger, BleDeviceConnector, BleDeviceInteractor>(
        builder: (_, bleScanner, bleScannerState, bleLogger, deviceConnector,
                interactor, __) =>
            Connect(
          scannerState: bleScannerState ??
              const BleScannerState(
                discoveredDevices: [],
                scanIsInProgress: false,
              ),
          startScan: bleScanner.startScan,
          stopScan: bleScanner.stopScan,
          deviceConnector: deviceConnector,
          writeWithoutResponse: interactor.writeCharacteristicWithoutResponse,
          writeWithResponse: interactor.writeCharacteristicWithResponse,
          readCharacteristic: interactor.readCharacteristic,
          subscribeToCharacteristic: interactor.subScribeToCharacteristic,
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
      required this.writeWithoutResponse,
      required this.writeWithResponse,
      required this.readCharacteristic,
      required this.subscribeToCharacteristic,
      super.key});
  final BleScannerState scannerState;
  final void Function(List<Uuid>) startScan;
  final VoidCallback stopScan;
  final BleDeviceConnector deviceConnector;
  final Future<void> Function(
          QualifiedCharacteristic characteristic, List<int> value)
      writeWithoutResponse;
  final Future<void> Function(
          QualifiedCharacteristic characteristic, List<int> value)
      writeWithResponse;
  final Future<List<int>> Function(QualifiedCharacteristic characteristic)
      readCharacteristic;

  final Stream<List<int>> Function(QualifiedCharacteristic characteristic)
      subscribeToCharacteristic;
  @override
  State<Connect> createState() => _ConnectState();
}

class _ConnectState extends State<Connect> {
  StreamSubscription<DiscoveredDevice>? _scanSubscription;
  String _deviceId = '';
  // void startScanning() {
  //   setState(() {
  //     widget.deviceConnector.disconnect(_deviceId);
  //   });
  //   _scanSubscription = ble.scanForDevices(
  //     withServices: [],
  //     scanMode: ScanMode.lowLatency,
  //   ).listen((scanResult) {
  //     if (scanResult.name.isNotEmpty) {
  //       deviceName = scanResult.name;
  //       _deviceId = scanResult.id;
  //       widget.deviceConnector.connect(scanResult.id);
  //       stopScanning(); // Stop scanning when a device is found
  //     }
  //   });
  // }

  void _startScanning() {
    widget.startScan([]);
  }

  void stopScanning() {
    widget.stopScan();
  }

  Future<void> writeData(List<int> value) async {
    if (_deviceId.isNotEmpty) {
      try {
        await ble.writeCharacteristicWithoutResponse(
          QualifiedCharacteristic(
            characteristicId:
                Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb"),
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
    switch (dataType) {
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
              if (event.length == 11) {
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
              if (event.length == 13) {
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
              if (event.length == 15) {
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
              if (event.length == 6) {
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
            characteristicId:
                Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb"),
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
  void connect() {
    for (var device in widget.scannerState.discoveredDevices) {
      print('object => ${device.name}');
      if (device.name == 'UNAZANEOIPV4') {
        deviceName = device.name;
        _deviceId = device.id;
        print('Connecting to ${device.name}, id: ${device.id}');
        widget.deviceConnector.connect(device.id);
      }
    }
  }
  void delay() async {
    await Future.delayed(const Duration(seconds: 5));
  }

  void initState() {
    // _startScanning();//start scanning
    // Future.delayed(const Duration(seconds: 5));//delay for scanning
    // widget.stopScan(); // stop the scan
    // connect(); //connect to the azan ble
    // after connection subscribe then write
    // getAllDataAndSubscribe();
    // timer for calculating the time periodically
    Timer.periodic(interval, (Timer t) {
      setState(() {
        if(!widget.scannerState.scanIsInProgress){
          _startScanning();
          Timer(const Duration(seconds: 5), () {
            widget.stopScan();
          });
        }
        else if (!connected){
          connect();
        }
        else{
          t.cancel();
        }
      });
    });
    // setState(() {
    //   getCurrentDateTime();
    // });
    //timer
    // Timer.periodic(const Duration(seconds: 2), (Timer t) {
    //   //if !connected startScanning
    //   if (!connected) {
    //     startScanning();
    //   }
    //   //else get the data from the ble device
    //   else {
    //     getAllDataAndSubscribe();
    //   }
    //   t.cancel();
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
      body: ListView(children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: width * .4,
                  height: height * .1,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      width: 2,
                      color: Colors.grey,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: width * .05, vertical: width * .03),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.date_range_outlined),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(formattedDate),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.hourglass_bottom_outlined),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(formattedTime),
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  width: width * .4,
                  height: height * .1,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      width: 2,
                      color: Colors.grey,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: width * .05, vertical: width * .03),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.date_range_outlined),
                          const SizedBox(
                            width: 5,
                          ),
                          Text('$day / $month / $year'),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.hourglass_bottom_outlined),
                          const SizedBox(
                            width: 5,
                          ),
                          Text('$hour:$minute'),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      _startScanning();
                      await Future.delayed(const Duration(seconds: 5));
                      widget.stopScan();
                      connect();
                    },
                    child: const Text('scan')),
                ElevatedButton(
                  onPressed: getAllDataAndSubscribe,
                  child: const Text('get all data'),
                ),
              ],
            ),
            Row(
              children: [
                Text('Device Name: $deviceName'),
                Icon(connected ? Icons.done_all : Icons.remove_done),
              ],
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: width * 0.07, vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    width: 2,
                    color: Colors.grey,
                  ),
                ),
                child: ListTile(
                  title: const Text('Location'),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: () {
                    setState(() {
                      locationContainer = !locationContainer;
                    });
                  },
                ),
              ),
            ),
            Visibility(
              visible: locationContainer,
              child: Column(
                children: [
                  Text('$locationList'),
                ],
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: width * 0.07, vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    width: 2,
                    color: Colors.grey,
                  ),
                ),
                child: ListTile(
                  title: const Text('Prays Times'),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: () {
                    setState(() {
                      prayContainer = !prayContainer;
                    });
                  },
                ),
              ),
            ),
            Visibility(
              visible: prayContainer,
              child: Text('$prayList'),
            ),
            Text('$zoneList'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
            const Text('Setting Data'),
            ElevatedButton(
              onPressed: () {
                writeData(setDate);
              },
              child: const Text(
                'Date',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Write without response
                  await widget.writeWithoutResponse(
                    QualifiedCharacteristic(
                      characteristicId:
                          Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb"),
                      serviceId:
                          Uuid.parse("0000ffe0-0000-1000-8000-00805f9b34fb"),
                      deviceId: _deviceId,
                    ),
                    restart,
                  );

                  // Subscribe to characteristic
                  await widget.subscribeToCharacteristic(
                    QualifiedCharacteristic(
                      characteristicId:
                          Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb"),
                      serviceId:
                          Uuid.parse("0000ffe0-0000-1000-8000-00805f9b34fb"),
                      deviceId: _deviceId,
                    ),
                  );

                  // Read characteristic
                  // await widget.readCharacteristic(
                  //   QualifiedCharacteristic(
                  //     characteristicId:
                  //         Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb"),
                  //     serviceId:
                  //         Uuid.parse("0000ffe0-0000-1000-8000-00805f9b34fb"),
                  //     deviceId: _deviceId,
                  //   ),
                  // );
                } catch (error) {
                  print('Error: $error');
                }
              },
              child: const Text(
                'Restart',
              ),
            ),
          ],
        ),
      ]),
    );
  }
}
