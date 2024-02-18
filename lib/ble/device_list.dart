import 'dart:async';
import 'dart:ui';

import 'package:azan/ble/scan.dart';
import 'package:azan/register/login.dart';
import 'package:azan/t_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  const ScanningListScreen({Key? key, required this.userName})
      : super(key: key);
  final String userName;
  @override
  Widget build(BuildContext context) => Consumer5<BleScanner, BleScannerState?,
          BleLogger, BleDeviceConnector, ConnectionStateUpdate>(
        builder: (_, bleScanner, bleScannerState, bleLogger, deviceConnector,
                connectionStateUpdate, __) =>
            Scanning(
          scannerState: bleScannerState ??
              const BleScannerState(
                discoveredDevices: [],
                scanIsInProgress: false,
              ),
          startScan: bleScanner.startScan,
          stopScan: bleScanner.stopScan,
          deviceConnector: deviceConnector,
          userName: userName,
          connectionStatus: connectionStateUpdate.connectionState,
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
      super.key,
      required this.connectionStatus});
  final BleScannerState scannerState;
  final void Function(List<Uuid>) startScan;
  final VoidCallback stopScan;
  final BleDeviceConnector deviceConnector;
  final String userName;
  @override
  final DeviceConnectionState connectionStatus;
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
          title: Text(
            TKeys.bleStatusTitle.translate(context),
            style: const TextStyle(
                color: Colors.brown, fontWeight: FontWeight.bold),
          ),
          content: Text(
            TKeys.bleStatusHeadline.translate(context),
            style: TextStyle(fontSize: 17, color: Colors.brown.shade700),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.brown,
                  backgroundColor: Colors.brown.shade200,
                  disabledForegroundColor: Colors.brown.shade600,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                TKeys.ok.translate(context),
                style: TextStyle(color: Colors.brown.shade800, fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
  }
  Stream<ConnectionStatus> _connectionStatusController = Stream<ConnectionStatus>.value(ConnectionStatus.connected);
  StreamSubscription<ConnectionStatus>? subscribeStream;
  void connect() {
    for (var device in widget.scannerState.discoveredDevices) {
      widget.deviceConnector.connect(device.id);
      subscribeStream = _connectionStatusController.listen((event) {
        print('event $event');
        if(event == ConnectionStatus.connected){
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
          subscribeStream?.cancel();
        } else if(event == ConnectionStatus.connecting){
          Fluttertoast.showToast(msg: 'connecting', toastLength: Toast.LENGTH_LONG,);
        }
      });
      // if(widget.connectionStatus == ConnectionStatus.connected){
      //   Navigator.push<void>(
      //     context,
      //     MaterialPageRoute(
      //       builder: (_) =>
      //           DeviceInteractionTab(
      //             device: device,
      //             characteristic:
      //             QualifiedCharacteristic(
      //               characteristicId: Uuid.parse(
      //                   "0000ffe1-0000-1000-8000-00805f9b34fb"),
      //               serviceId: Uuid.parse(
      //                   "0000ffe0-0000-1000-8000-00805f9b34fb"),
      //               deviceId: device.id,
      //             ),
      //             userName: widget.userName,
      //           ),
      //     ),
      //   );
      // } else if(widget.connectionStatus == ConnectionStatus.connecting){
      //   Fluttertoast.showToast(msg: 'connecting', toastLength: Toast.LENGTH_LONG,);
      // }else{
      //   Fluttertoast.showToast(msg: 'not connected', toastLength: Toast.LENGTH_LONG,);
      // }

    }
  }
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getCurrentDateTime();
      setState(() {
        if(widget.connectionStatus == DeviceConnectionState.connected){
          for(var device in widget.scannerState.discoveredDevices){
            if(device.name == 'UNAZANEOIPV4'){
              widget.deviceConnector.disconnect(device.id);
            }
          }
        }
        else{
          _startScanning();
        }
        getDocumentIDs();
        getUserFields(widget.userName);
      });
    });
  }

  void dispose() {
    super.dispose();
    subscribeStream?.cancel();
  }
  //alert dialog function
  Future<void> _showAlertDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must not tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.brown.shade50,
          title: Text(
            TKeys.skip.translate(context),
            style: const TextStyle(
                color: Colors.brown, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  TKeys.confirmSkipping.translate(context),
                  style: TextStyle(fontSize: 17, color: Colors.brown.shade700),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.brown,
                  backgroundColor: Colors.brown.shade200,
                  disabledForegroundColor: Colors.brown.shade600,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: Text(
                TKeys.scan.translate(context),
                style: TextStyle(color: Colors.brown.shade800, fontSize: 18),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                if(widget.connectionStatus == DeviceConnectionState.connected){
                  for(var device in widget.scannerState.discoveredDevices){
                    if(device.name == 'UNAZANEOIPV4'){
                      widget.deviceConnector.disconnect(device.id);
                    }
                  }
                }
                else{
                  _startScanning();
                }
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.brown,
                  backgroundColor: Colors.brown.shade600,
                  disabledForegroundColor: Colors.brown.shade600,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: Text(
                TKeys.skip.translate(context),
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push<void>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotConnected(
                      userName: widget.userName,
                    ),
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
    return Scaffold(
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
              padding: EdgeInsets.symmetric(horizontal: width * .07),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RippleAnimation(
                    size: screenSize * .5,
                    minRadius: 100,
                    repeat: true,
                    color: Colors.brown.shade400,
                    ripplesCount: 6,
                    child: Icon(
                      Icons.bluetooth_rounded,
                      size: width * .4,
                      color: Colors.brown.shade700,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if(widget.connectionStatus == DeviceConnectionState.connected){
                          for(var device in widget.scannerState.discoveredDevices){
                            if(device.name == 'UNAZANEOIPV4'){
                              widget.deviceConnector.disconnect(device.id);
                            }
                          }
                        }
                        else{
                          _startScanning();
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.brown,
                      backgroundColor: Colors.brown.shade600,
                      disabledForegroundColor: Colors.brown.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      widget.scannerState.scanIsInProgress
                          ? TKeys.scanning.translate(context)
                          : TKeys.scan.translate(context),
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      TKeys.skip.translate(context),
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                  Visibility(
                    visible: !widget.scannerState.scanIsInProgress,
                    child: Text(
                      found
                          ? '${TKeys.connect.translate(context)} $deviceName'
                          : TKeys.notFound.translate(context),
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade800),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
