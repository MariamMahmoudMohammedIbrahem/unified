import 'dart:async';
import 'dart:ui';

import 'package:azan/ble/scan.dart';
import 'package:azan/register/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../constants.dart';
import '../functions.dart';
import 'ble_device_connector.dart';
import 'ble_logger.dart';
import 'ble_scanner.dart';
import 'package:provider/provider.dart';
import 'package:functional_data/functional_data.dart';
import 'package:awesome_ripple_animation/awesome_ripple_animation.dart';

part 'device_list.g.dart';

//ignore_for_file: annotate_overrides

class ScanningListScreen extends StatelessWidget {
  const ScanningListScreen({Key? key, required this.userName}) : super(key: key);
  final String userName;
  @override
  Widget build(BuildContext context) =>
      Consumer4<BleScanner, BleScannerState?, BleLogger, BleDeviceConnector>(
        builder:
            (_, bleScanner, bleScannerState, bleLogger, deviceConnector, __) =>
                Scanning(
          scannerState: bleScannerState ??
              const BleScannerState(
                discoveredDevices: [],
                scanIsInProgress: false,
              ),
          startScan: bleScanner.startScan,
          stopScan: bleScanner.stopScan,
          deviceConnector: deviceConnector, userName: userName,
        ),
      );
}

@immutable
@FunctionalData()
class ScanningList extends $ScanningList {
  const ScanningList({
    required this.deviceId,
    required this.deviceConnector,
    required this.discoverServices,
  });

  final String deviceId;
  final BleDeviceConnector deviceConnector;
  @CustomEquality(Ignore())
  final Future<List<DiscoveredService>> Function() discoverServices;
}

class Scanning extends StatefulWidget {
  const Scanning(
      {required this.scannerState,
      required this.startScan,
      required this.stopScan,
      required this.deviceConnector,
      required this.userName,
      super.key});
  final BleScannerState scannerState;
  final void Function(List<Uuid>) startScan;
  final VoidCallback stopScan;
  final BleDeviceConnector deviceConnector;
  final String userName;
  @override
  State<Scanning> createState() => _ScanningState();
}

class _ScanningState extends State<Scanning> {
  void _startScanning(){
  if (!widget.scannerState.scanIsInProgress) {
    widget.startScan([]);
  }
  Future.delayed(const Duration(seconds: 2), () {
    if (found) {
      connect();
    }
  });
}
  void connect() {
    for (var device in widget.scannerState.discoveredDevices) {
      widget.deviceConnector.connect(device.id);
      Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) =>
              DeviceInteractionTab(
                device: device,
                characteristic:
                QualifiedCharacteristic(
                  characteristicId: Uuid.parse(
                      "0000ffe1-0000-1000-8000-00805f9b34fb"),
                  serviceId: Uuid.parse(
                      "0000ffe0-0000-1000-8000-00805f9b34fb"),
                  deviceId: device.id,
                ),
                userName: widget.userName,
              ),
        ),
      );
    }
  }

  void initState() {
    setState(() {
      _startScanning();
      getDocumentIDs();
      getUserFields(widget.userName);
    });
    super.initState();
  }

  void dispose() {
    super.dispose();
  }
  //alert dialog function
  Future<void> _showAlertDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must not tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Skip Scanning process', style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure want to continue without connecting to your device?', style: TextStyle(fontSize: 17,color: Colors.brown.shade700),),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.brown,
                  backgroundColor: Colors.brown.shade200,
                  disabledForegroundColor: Colors.brown.shade600,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text('Continue Scanning',style: TextStyle(color: Colors.brown.shade800,fontSize: 18),),
              onPressed: () {
                Navigator.of(context).pop();
                _startScanning();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.brown,
                  backgroundColor: Colors.brown.shade600,
                  disabledForegroundColor: Colors.brown.shade600,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Skip', style: TextStyle(color: Colors.white, fontSize: 18),),
              onPressed: () {
                Navigator.push<void>(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        NotConnected(userName: widget.userName,),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final Size screenSize = MediaQuery.of(context).size;
    return WillPopScope(

      onWillPop: () async {
        // Custom logic when the back button is pressed
        // Return true to allow popping the page, or false to prevent it
        // You can also perform actions before popping the page
        bool shouldPop = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm Logging Out'),
              content: Text('Do you really want to Log Out?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LogIn()),
                          (route) => false,);
                  },
                  child: Text('Yes'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('No'),
                ),
              ],
            );
          },
        );

        return shouldPop ?? false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 4),
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
              child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width*.07),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RippleAnimation(
                    size: screenSize * .5,
                    minRadius: 100,
                    repeat: true,
                    color: Colors.brown.shade400,
                    ripplesCount: 6,
                    child: Icon(Icons.bluetooth_rounded, size: width*.4,color: Colors.brown.shade700,),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _startScanning();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.brown,
                      backgroundColor: Colors.brown.shade600,
                      disabledForegroundColor: Colors.brown.shade600,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),),
                    child: Text(widget.scannerState.scanIsInProgress?'Scanning':'Scan',style: const TextStyle(color: Colors.white, fontSize: 24),),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      //navigate to scan page without scanning
                      _showAlertDialog();
                    },
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.brown,
                        backgroundColor: Colors.brown.shade600,
                        disabledForegroundColor: Colors.brown.shade600,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),),
                    child: const Text('Skip',style: TextStyle(color: Colors.white, fontSize: 24),),
                  ),
                  Visibility(visible:!widget.scannerState.scanIsInProgress,child: Text(found?'Connecting to $deviceName':'Can\'t Find the Device',style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red.shade800),),),
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     try {
                  //       QuerySnapshot Cities = await FirebaseFirestore.instance.collection('Cities').get();
                  //       if (Cities.docs.isNotEmpty) {
                  //         List locationIds = Cities.docs.map((doc) => doc.id).toList();
                  //         print(locationIds);
                  //       }
                  //     } catch (e) {
                  //       print('Error retrieving documents: $e');
                  //     }
                  //   },
                  //   child: const Text('compose packet'),),
                ],
              ),
          ),
            ),],
        ),
      ),
    );
    // return Scaffold(
    //   body: ListView(children: [
    //     Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       children: [
    //         Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //           children: [
    //             Container(
    //               width: width * .4,
    //               height: height * .1,
    //               decoration: BoxDecoration(
    //                 borderRadius: BorderRadius.circular(20.0),
    //                 border: Border.all(
    //                   width: 2,
    //                   color: Colors.grey,
    //                 ),
    //               ),
    //               padding: EdgeInsets.symmetric(
    //                   horizontal: width * .05, vertical: width * .03),
    //               child: Column(
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 children: [
    //                   Row(
    //                     children: [
    //                       const Icon(Icons.date_range_outlined),
    //                       const SizedBox(
    //                         width: 5,
    //                       ),
    //                       Text(formattedDate),
    //                     ],
    //                   ),
    //                   Row(
    //                     children: [
    //                       const Icon(Icons.hourglass_bottom_outlined),
    //                       const SizedBox(
    //                         width: 5,
    //                       ),
    //                       Text(formattedTime),
    //                     ],
    //                   )
    //                 ],
    //               ),
    //             ),
    //             Container(
    //               width: width * .4,
    //               height: height * .1,
    //               decoration: BoxDecoration(
    //                 borderRadius: BorderRadius.circular(20.0),
    //                 border: Border.all(
    //                   width: 2,
    //                   color: Colors.grey,
    //                 ),
    //               ),
    //               padding: EdgeInsets.symmetric(
    //                   horizontal: width * .05, vertical: width * .03),
    //               child: Column(
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 children: [
    //                   Row(
    //                     children: [
    //                       const Icon(Icons.date_range_outlined),
    //                       const SizedBox(
    //                         width: 5,
    //                       ),
    //                       Text('$day / $month / $year'),
    //                     ],
    //                   ),
    //                   Row(
    //                     children: [
    //                       const Icon(Icons.hourglass_bottom_outlined),
    //                       const SizedBox(
    //                         width: 5,
    //                       ),
    //                       Text('$hour:$minute'),
    //                     ],
    //                   )
    //                 ],
    //               ),
    //             ),
    //           ],
    //         ),
    //         Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //           children: [
    //             ElevatedButton(
    //                 onPressed: () async {
    //                   _startScanning();
    //                   await Future.delayed(const Duration(seconds: 5));
    //                   widget.stopScan();
    //                   connect();
    //                 },
    //                 child: const Text('scan')),
    //             ElevatedButton(
    //               onPressed: getAllDataAndSubscribe,
    //               child: const Text('get all data'),
    //             ),
    //           ],
    //         ),
    //         Row(
    //           children: [
    //             Text('Device Name: $deviceName'),
    //             Icon(connected ? Icons.done_all : Icons.remove_done),
    //           ],
    //         ),
    //         Padding(
    //           padding:
    //               EdgeInsets.symmetric(horizontal: width * 0.07, vertical: 10),
    //           child: Container(
    //             decoration: BoxDecoration(
    //               borderRadius: BorderRadius.circular(20.0),
    //               border: Border.all(
    //                 width: 2,
    //                 color: Colors.grey,
    //               ),
    //             ),
    //             child: ListTile(
    //               title: const Text('Location'),
    //               trailing: const Icon(Icons.arrow_drop_down),
    //               onTap: () {
    //                 setState(() {
    //                   locationContainer = !locationContainer;
    //                 });
    //               },
    //             ),
    //           ),
    //         ),
    //         Visibility(
    //           visible: locationContainer,
    //           child: Column(
    //             children: [
    //               Text('$locationList'),
    //             ],
    //           ),
    //         ),
    //         Padding(
    //           padding:
    //               EdgeInsets.symmetric(horizontal: width * 0.07, vertical: 10),
    //           child: Container(
    //             decoration: BoxDecoration(
    //               borderRadius: BorderRadius.circular(20.0),
    //               border: Border.all(
    //                 width: 2,
    //                 color: Colors.grey,
    //               ),
    //             ),
    //             child: ListTile(
    //               title: const Text('Prays Times'),
    //               trailing: const Icon(Icons.arrow_drop_down),
    //               onTap: () {
    //                 setState(() {
    //                   prayContainer = !prayContainer;
    //                 });
    //               },
    //             ),
    //           ),
    //         ),
    //         Visibility(
    //           visible: prayContainer,
    //           child: Text('$prayList'),
    //         ),
    //         Text('$zoneList'),
    //         Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //           children: [
    //             ElevatedButton(
    //               onPressed: () {
    //                 writeData(getSound1);
    //               },
    //               child: const Text('sound 1'),
    //             ),
    //             ElevatedButton(
    //               onPressed: () {
    //                 writeData(getSound2);
    //               },
    //               child: const Text('sound 2'),
    //             ),
    //           ],
    //         ),
    //         Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //           children: [
    //             ElevatedButton(
    //               onPressed: () {
    //                 writeData(getSound3);
    //               },
    //               child: const Text('sound 3'),
    //             ),
    //             ElevatedButton(
    //               onPressed: () {
    //                 writeData(getSound4);
    //               },
    //               child: const Text('sound 4'),
    //             ),
    //           ],
    //         ),
    //         const Text('Setting Data'),
    //         ElevatedButton(
    //           onPressed: () {
    //             writeData(setDate);
    //           },
    //           child: const Text(
    //             'Date',
    //           ),
    //         ),
    //         ElevatedButton(
    //           onPressed: () async {
    //             try {
    //               // Write without response
    //               await widget.writeWithoutResponse(
    //                 QualifiedCharacteristic(
    //                   characteristicId:
    //                       Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb"),
    //                   serviceId:
    //                       Uuid.parse("0000ffe0-0000-1000-8000-00805f9b34fb"),
    //                   deviceId: _deviceId,
    //                 ),
    //                 restart,
    //               );
    //
    //               // Subscribe to characteristic
    //               await widget.subscribeToCharacteristic(
    //                 QualifiedCharacteristic(
    //                   characteristicId:
    //                       Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb"),
    //                   serviceId:
    //                       Uuid.parse("0000ffe0-0000-1000-8000-00805f9b34fb"),
    //                   deviceId: _deviceId,
    //                 ),
    //               );
    //
    //               // Read characteristic
    //               // await widget.readCharacteristic(
    //               //   QualifiedCharacteristic(
    //               //     characteristicId:
    //               //         Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb"),
    //               //     serviceId:
    //               //         Uuid.parse("0000ffe0-0000-1000-8000-00805f9b34fb"),
    //               //     deviceId: _deviceId,
    //               //   ),
    //               // );
    //             } catch (error) {
    //               print('Error: $error');
    //             }
    //           },
    //           child: const Text(
    //             'Restart',
    //           ),
    //         ),
    //       ],
    //     ),
    //   ]),
    // );
  }
}
