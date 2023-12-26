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
final ble = FlutterReactiveBle();
String deviceName = '';

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
    _scanSubscription = ble.scanForDevices(
      withServices: [],
      scanMode: ScanMode.lowLatency,
    ).listen((scanResult) {
      setState(() {
        deviceName = scanResult.name;
      });
      if (scanResult.name.isNotEmpty) {
        connectToDevice(scanResult.id);
        stopScanning(); // Stop scanning when a device is found
      }
    });
  }

  void stopScanning() {
    _scanSubscription?.cancel(); // Cancel the subscription to stop scanning
  }

  void connectToDevice(String deviceId) {
    ble
        .connectToDevice(
      id: deviceId,
      connectionTimeout: Duration(seconds: 10),
    )
        .listen((connectionState) {
      if (connectionState.connectionState == DeviceConnectionState.connected) {
        setState(() {
          connected = true;
          _deviceId = deviceId; // Set the connected device ID
        });
      }
    }, onError: (dynamic error) {
      print('Connection error: $error');
    });
  }

  void writeData(List<int> value) {
    if (_deviceId.isNotEmpty) {
      ble
          .writeCharacteristicWithoutResponse(
        QualifiedCharacteristic(
            characteristicId:
                Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb"),
            serviceId: Uuid.parse("0000ffe0-0000-1000-8000-00805f9b34fb"),
            deviceId: _deviceId),
        value: value,
      )
          .then((_) {
        print('Data written successfully');
      }, onError: (dynamic error) {
        print('Error writing data: $error');
      });
    } else {
      print('Device not connected');
    }
  }

  StreamSubscription<List<int>>? dateSubscription;
  StreamSubscription<List<int>>? locationSubscription;
  StreamSubscription<List<int>>? praySubscription;
  StreamSubscription<List<int>>? zoneSubscription;

  void subscribeCharacteristic(int dataType) {
    Stream<List<int>> stream;

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
              dateList = List.from(event);
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
              locationList = List.from(event);
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
              prayList = List.from(event);
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
              zoneList = List.from(event);
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

  void initState() {
    startScanning();
    setState(() {
      dateTime = getCurrentDateTime();
    });
    Future.delayed(const Duration(seconds: 5), () {
      stopScanning();
    });
    Timer.periodic(const Duration(minutes: 1), (Timer t) {
      setState(() {
        dateTime = getCurrentDateTime();
      });
    });
    super.initState();
  }

  void dispose() {
    _scanSubscription
        ?.cancel(); // Cancel the subscription when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(dateTime),
          ElevatedButton(
              onPressed: () {
                startScanning();
              },
              child: const Text('scan')),
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
