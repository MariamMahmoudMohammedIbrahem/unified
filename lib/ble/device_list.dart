import 'dart:async';
import 'dart:ui';

import 'package:azan/ble/scan.dart';
import 'package:azan/register/login.dart';
import 'package:azan/t_key.dart';
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

/*class BleStatusNotifier extends ChangeNotifier {
  BleStatus? _status;

  BleStatus? get status => _status;

  void updateStatus(BleStatus? newStatus) {
    _status = newStatus;
    notifyListeners();
  }
}

// In your widget tree, where you provide the BleStatusNotifier:
final BleStatusNotifier bleStatusNotifier = BleStatusNotifier();*/
final FlutterReactiveBle _ble = ble;
class _ScanningState extends State<Scanning> {
  void _startScanning(){
    if(_ble.status == BleStatus.ready){
      if (!widget.scannerState.scanIsInProgress) {
        print('here');
        widget.startScan([]);
      }
    }
    else{
      _showBleNotReadyAlertDialog(context);
    }
    if(_ble.status == BleStatus.ready){
      Future.delayed(const Duration(seconds: 2), () {
        if (found) {
          widget.stopScan();
          connect();
        }
      });
    }

}

  void _showBleNotReadyAlertDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.brown.shade50,
          title: Text(TKeys.bleStatusTitle.translate(context), style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),),
          content: Text(TKeys.bleStatusHeadline.translate(context), style: TextStyle(fontSize: 17,color: Colors.brown.shade700),),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.brown,
                  backgroundColor: Colors.brown.shade200,
                  disabledForegroundColor: Colors.brown.shade600,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(TKeys.ok.translate(context),style: TextStyle(color: Colors.brown.shade800,fontSize: 18),),
            ),
          ],
        );
      },
    );
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
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getCurrentDateTime();
      setState(() {
        _startScanning();
        getDocumentIDs();
        getUserFields(widget.userName);
      });
    });
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
          backgroundColor: Colors.brown.shade50,
          title: Text(TKeys.skip.translate(context), style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(TKeys.confirmSkipping.translate(context), style: TextStyle(fontSize: 17,color: Colors.brown.shade700),),
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
              child: Text(TKeys.scanning.translate(context),style: TextStyle(color: Colors.brown.shade800,fontSize: 18),),
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
              child: Text(TKeys.skip.translate(context), style: const TextStyle(color: Colors.white, fontSize: 18),),
              onPressed: () {
                Navigator.of(context).pop();
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
              backgroundColor: Colors.brown.shade50,
              title: Text(TKeys.confirmLogOutTitle.translate(context), style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),),
              content: Text(TKeys.confirmLogOutHeadline.translate(context), style: TextStyle(fontSize: 17,color: Colors.brown.shade700),),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LogIn()),
                          (route) => false,);
                  },
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.brown,
                      backgroundColor: Colors.brown.shade200,
                      disabledForegroundColor: Colors.brown.shade600,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: Text(TKeys.yes.translate(context),style: TextStyle(color: Colors.brown.shade800,fontSize: 18),),
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
                    child: Text(widget.scannerState.scanIsInProgress?TKeys.scanning.translate(context):TKeys.scan.translate(context),style: const TextStyle(color: Colors.white, fontSize: 24),),
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
                    child: Text(TKeys.skip.translate(context),style: const TextStyle(color: Colors.white, fontSize: 24),),
                  ),
                  Visibility(visible:!widget.scannerState.scanIsInProgress,child: Text(found?'${TKeys.connect.translate(context)} $deviceName':TKeys.notFound.translate(context),style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red.shade800),),),
                ],
              ),
          ),
            ),],
        ),
      ),
    );
  }
}
