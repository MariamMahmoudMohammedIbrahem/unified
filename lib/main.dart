import 'package:azan/classes/auto_login.dart';
import 'package:azan/functions.dart';
import 'package:azan/t_key.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:azan/localization_service.dart';
import 'ble/ble_device_connector.dart';
import 'ble/ble_device_interactor.dart';
import 'ble/ble_logger.dart';
import 'ble/ble_scanner.dart';
import 'ble/ble_status_monitor.dart';
import 'ble/ble_status_screen.dart';
import 'constants.dart';
import 'firebase_options.dart';

Future<void> main() async {
  /// widgets binding
  // final WidgetsBinding widgetsBinding = widgetsFlutterBinding.ensureInitialized();
  /// GetX Local Storage
  await GetStorage.init();
  /// Await Splash until items load
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  final localizationController =
      Get.put(LocalizationController(initialLanguage: 'ar'));
  statusLocation = await Permission.location.status;
  statusBluetoothConnect = await Permission.bluetoothConnect.status;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final ble = FlutterReactiveBle();
  final bleLogger = BleLogger(ble: ble);
  final scanner = BleScanner(ble: ble, logMessage: bleLogger.addToLog);
  final monitor = BleStatusMonitor(ble);
  final connector = BleDeviceConnector(
    ble: ble,
    logMessage: bleLogger.addToLog,
  );
  final serviceDiscoverer = BleDeviceInteractor(
    bleDiscoverServices: (deviceId) async {
      await ble.discoverAllServices(deviceId);
      return ble.getDiscoveredServices(deviceId);
    },
    readCharacteristic: ble.readCharacteristic,
    writeWithResponse: ble.writeCharacteristicWithResponse,
    writeWithOutResponse: ble.writeCharacteristicWithoutResponse,
    subscribeToCharacteristic: ble.subscribeToCharacteristic,
    logMessage: bleLogger.addToLog,
  );
  runApp(MultiProvider(
    providers: [
      Provider.value(value: scanner),
      Provider.value(value: monitor),
      Provider.value(value: connector),
      Provider.value(value: serviceDiscoverer),
      Provider.value(value: bleLogger),
      StreamProvider<BleScannerState?>(
        create: (_) => scanner.state,
        initialData: const BleScannerState(
          discoveredDevices: [],
          scanIsInProgress: false,
        ),
      ),
      StreamProvider<BleStatus?>(
        create: (_) => monitor.state,
        initialData: BleStatus.unknown,
      ),
      ChangeNotifierProvider(
        create: (context) => PermissionProvider(),
      ),
      StreamProvider<ConnectionStateUpdate>(
        create: (_) => connector.state,
        initialData: const ConnectionStateUpdate(
          deviceId: 'Unknown device',
          connectionState: DeviceConnectionState.disconnected,
          failure: null,
        ),
      ),
    ],
    child: GetBuilder<LocalizationController>(
        init: localizationController,
        builder: (LocalizationController controller) => MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: controller.currentLanguage != ''
                  ? Locale(controller.currentLanguage, '')
                  : null,
              localeResolutionCallback:
                  LocalizationService.localeResolutionCallBack,
              supportedLocales: LocalizationService.supportedLocales,
              localizationsDelegates: const [
                ...LocalizationService.localizationsDelegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                DefaultCupertinoLocalizations.delegate,
                FallbackCupertinoLocalisationsDelegate(),
              ],
              home: const HomeScreen(),
            )
        // child: const MyApp(),
        ),
  ));
  FlutterReactiveBle();
}
class PermissionProvider extends ChangeNotifier {
  // Define the permissions you want to manage
  PermissionStatus _locationStatus = statusLocation;
  PermissionStatus _bluetoothStatus = statusBluetoothConnect;

  // Getters for permission statuses
  PermissionStatus get locationStatus => _locationStatus;
  PermissionStatus get bluetoothStatus => _bluetoothStatus;

  // Function to request location permission
  Future<void> requestLocationPermission() async {
    final status = await Permission.location.status;
    _locationStatus = status;
    notifyListeners();
  }

  // Function to request camera permission
  Future<void> requestBluetoothPermission() async {
    final status = await Permission.bluetoothConnect.status;
    _bluetoothStatus = status;
    notifyListeners();
  }
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Azan',
      theme: ThemeData(
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
        textSelectionTheme:
            TextSelectionThemeData(selectionHandleColor: Colors.brown.shade700),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer2<BleStatus?, PermissionProvider>(
        builder: (_, status, permission, __) {
          // statusLocation = permissionProvider.locationStatus;
          // statusCamera = permissionProvider.cameraStatus;
          if (status == BleStatus.ready && permission.bluetoothStatus.isGranted && permission.locationStatus.isGranted) {
            return const AutoLogin();
          }
          // else if(statusCamera.isDenied){
          //     print('consumer $statusCamera');
          //     return const CameraPermission();
          // }
          // else if(statusBluetooth.isDenied){
          //   return const BluetoothPermission();
          // }
          else if(permission.locationStatus.isDenied){
            permission.requestLocationPermission();
              return const LocationPermission();
          }
          else if(permission.bluetoothStatus.isDenied){
            permission.requestBluetoothPermission();
            return const BluetoothPermission();
          }
          else {
            return BleStatusScreen(status: status ?? BleStatus.unknown);
          }
        },
      );
}
class LocationPermission extends StatefulWidget {
  const LocationPermission({super.key});

  @override
  State<LocationPermission> createState() => _LocationPermissionState();
}

class _LocationPermissionState extends State<LocationPermission> {
  Future<void> _requestPermission() async {
    // statusLocation = await Permission.location.status;

    if(statusLocation.isDenied){
      statusLocation = await Permission.location.request();
      if(statusLocation.isGranted){
        setState(() {
          statusLocation = PermissionStatus.granted;
        });
        Fluttertoast.showToast(msg: 'location granted');
      }
    }
  }
  @override
  void initState(){
    super.initState();
    // Preload images
    // precacheImage(const AssetImage('images/pattern.jpg'), context);
    // precacheImage(const AssetImage('images/appIcon.jpg'), context);
  }
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
            width: width,
            child: Image.asset('images/location.png'),
            ),
            // Text(TKeys.authorize.translate(context)),
            ElevatedButton(
              onPressed: _requestPermission,
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.brown,
                  backgroundColor: Colors.brown.shade500, //replace with 855A2D
                  disabledForegroundColor: Colors.brown.shade600,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text(TKeys.accessLocation.translate(context),style: const TextStyle(color: Colors.white,fontSize: 18),),
            ),
          ],
        ),
      ),
    );
  }
}

class BluetoothPermission extends StatefulWidget {
  const BluetoothPermission({super.key});

  @override
  State<BluetoothPermission> createState() => _BluetoothPermissionState();
}

class _BluetoothPermissionState extends State<BluetoothPermission> {
  Future<void> _requestPermission() async {

    if(statusBluetoothConnect.isDenied){
      statusBluetoothConnect = await Permission.bluetoothConnect.request();
      if(statusBluetoothConnect.isGranted){
        setState(() {
          statusBluetoothConnect = PermissionStatus.granted;
          Permission.bluetoothScan.request();
        });
        Fluttertoast.showToast(msg: 'bluetooth granted');
      }
    }
  }
  @override
  void initState(){
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: width,
              child: Image.asset('images/bluetooth.png'),
            ),
            // Text(TKeys.authorize.translate(context)),
            ElevatedButton(
              onPressed: _requestPermission,
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.brown,
                  backgroundColor: Colors.brown.shade600,
                  disabledForegroundColor: Colors.brown.shade600,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text(TKeys.accessBluetooth.translate(context),style: const TextStyle(color: Colors.white,fontSize: 18),),
            ),
          ],
        ),
      ),
    );
  }
}