// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_ble_supabase_socketio_demo/constants/appwrite.dart';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// import 'package:location_permissions/location_permissions.dart';

// class BLEProvider extends ChangeNotifier {
//   /// Initializing
//   ///
//   final FlutterReactiveBle _ble = FlutterReactiveBle();
//   bool scanStarted = false;
//   bool permGranted = false;
//   List<DiscoveredDevice> discoveredDevices = [];
//   DeviceConnectionState deviceConnectionState =
//       DeviceConnectionState.disconnected;
//   // stream subscription
//   StreamSubscription? _connectToDeviceStreamSubscription;
//   StreamSubscription<DiscoveredDevice>? _scanDeviceStream;
//   final StreamController<List<DiscoveredDevice>> _discoveredDeviceController =
//       StreamController<List<DiscoveredDevice>>();
//   // ble servcies
//   final Uuid ebaniServiceUUID = Uuid(ebaniServiceUUIDListOfInt);
//   //1
//   final Uuid characteristic1 = Uuid(characteristic1UUIDListOfInt);
//   StreamSubscription<List<int>>? characteristic1StreamSubscription;
//   StreamController<List<int>> _characteristic1StreamController =
//       StreamController<List<int>>();
//   //2
//   final Uuid characteristic2 = Uuid(characteristic2UUIDListOfInt);
//   StreamSubscription<List<int>>? characteristic2StreamSubscription;
//   final StreamController<List<int>> _characteristic2StreamController =
//       StreamController<List<int>>();

//   //3
//   final Uuid characteristic3 = Uuid(characteristic3UUIDListOfInt);
//   StreamSubscription<List<int>>? characteristic3StreamSubscription;
//   final StreamController<List<int>> _characteristic3StreamController =
//       StreamController<List<int>>();

//   //2
//   final Uuid characteristic4 = Uuid(characteristic4UUIDListOfInt);
//   StreamSubscription<List<int>>? characteristic4StreamSubscription;
//   final StreamController<List<int>> _characteristic4StreamController =
//       StreamController<List<int>>();

//   // get Methods
//   FlutterReactiveBle get getBLE => _ble;
//   bool get getScanStatus => scanStarted;
//   List<DiscoveredDevice> get getDiscoveredDevices => discoveredDevices;
//   StreamSubscription<DiscoveredDevice>? get getScanDeviceStream =>
//       _scanDeviceStream;
//   StreamController<List<DiscoveredDevice>> get getDiscoveredDeviceController =>
//       _discoveredDeviceController;

//   StreamSubscription? get getConnectToDeviceStreamSubscription =>
//       _connectToDeviceStreamSubscription;
//   DeviceConnectionState get getDeviceConnectionState => deviceConnectionState;
//   //1
//   StreamSubscription<List<int>>? get getCharacteristic1StreamSubscription =>
//       characteristic1StreamSubscription;
//   StreamController<List<int>> get getCharacteristic1StreamController =>
//       _characteristic1StreamController;
// //2
//   StreamSubscription<List<int>>? get getCharacteristic2StreamSubscription =>
//       characteristic2StreamSubscription;
//   StreamController<List<int>> get getCharacteristic2StreamController =>
//       _characteristic2StreamController;
//   //3
//   StreamSubscription<List<int>>? get getCharacteristic3StreamSubscription =>
//       characteristic3StreamSubscription;
//   StreamController<List<int>> get getCharacteristic3StreamController =>
//       _characteristic3StreamController;
//   //4
//   StreamSubscription<List<int>>? get getCharacteristic4StreamSubscription =>
//       characteristic4StreamSubscription;
//   StreamController<List<int>> get getCharacteristic4StreamController =>
//       _characteristic4StreamController;

//   /// ble provider
//   ///
//   BLEProvider();

//   // Discovering BLE devices
//   Future<void> discoverDevices() async {
//     // TODO check if bluetooth is on before start scan
//     print("//? discoverDevices start ");
//     if (!scanStarted) {
//       scanStarted = true;
//       notifyListeners();

//       // print("//? 1 permGranted ==> $permGranted ");

//       PermissionStatus permission;
//       permission = await LocationPermissions().checkPermissionStatus();
//       print(
//           "//? permission == PermissionStatus.granted ===> ${permission == PermissionStatus.granted} ");
//       if (!permGranted && permission != PermissionStatus.granted) {
//         print("//? PermissionStatus 1");
//         if (Platform.isAndroid) {
//           print("//? PermissionStatus 2");
//           permission = await LocationPermissions().requestPermissions();
//           if (permission == PermissionStatus.granted) permGranted = true;
//         } else if (Platform.isIOS) {
//           permGranted = true;
//         }
//         notifyListeners();
//       } else if (permission == PermissionStatus.granted) {
//         permGranted = true;
//         notifyListeners();
//       }

//       // print("//? 2 permGranted ==> $permGranted ");

//       if (permGranted) {
//         print("//? start can ");
//         _scanDeviceStream =
//             _ble.scanForDevices(withServices: []).listen((device) {
//           if (device.name != "" &&
//               (discoveredDevices
//                   .where((element) => element.name == device.name)
//                   .isEmpty)) {
//             discoveredDevices.add(device);
//             _discoveredDeviceController.sink.add(discoveredDevices);
//             notifyListeners();
//           }
//         });
//         await Future.delayed(const Duration(seconds: 10), (() {
//           _scanDeviceStream!.cancel();
//           _discoveredDeviceController.close();
//           scanStarted = false;
//           notifyListeners();
//         }));
//       } else {
//         scanStarted = false;
//         notifyListeners();
//       }
//     }
//   }

//   void connectToScannedDevice(String deviceId) {
//     _connectToDeviceStreamSubscription = _ble
//         .connectToDevice(
//       id: deviceId,
//       // servicesWithCharacteristicsToDiscover: {serviceId: []},
//       connectionTimeout: const Duration(seconds: 10),
//     )
//         .listen((connectionState) {
//       if (deviceConnectionState != connectionState.connectionState) {
//         deviceConnectionState = connectionState.connectionState;
//         notifyListeners();
//       }
//       print("//? connected device state ==> $connectionState ");
//       // Handle connection state updates
//     }, onError: (Object error) {
//       // Handle a possible error
//       print("//? connected device error ==> $error ");
//       // deviceConnectionState = DeviceConnectionState.disconnected;
//       // notifyListeners();
//     });
//   }

//   /// params deviceId
//   ///
//   void subscribeToCharacteristic1(String deviceId) {
//     final characteristic = QualifiedCharacteristic(
//         serviceId: ebaniServiceUUID,
//         characteristicId: characteristic1,
//         deviceId: deviceId);
//     characteristic1StreamSubscription =
//         _ble.subscribeToCharacteristic(characteristic).listen((data) {
//       // code to handle incoming data
//       _characteristic1StreamController.sink.add(data);
//       notifyListeners();
//     }, onError: (dynamic error) {
//       // code to handle errors
//       print("//? subscribeToCharacteristic error ==> $error ");
//     });
//   }

//   Future<void> cancelCharacteristic1Subscription() async {
//     print(
//         "//? cancelCharacteristic1Subscription characteristic1StreamSubscription called ${characteristic1StreamSubscription != null} ");
//     if (characteristic1StreamSubscription != null) {
//       print("//? cancelCharacteristic1Subscription called ");
//       await characteristic1StreamSubscription!.cancel();
//       await _characteristic1StreamController.close();
//       _characteristic1StreamController = StreamController<List<int>>();
//       print("//? cancelCharacteristic1Subscription called ");
//       characteristic1StreamSubscription = null;
//       notifyListeners();
//     }
//   }

//   //2
//   void subscribeToCharacteristic2(String deviceId) {
//     final characteristic = QualifiedCharacteristic(
//         serviceId: ebaniServiceUUID,
//         characteristicId: characteristic2,
//         deviceId: deviceId);
//     characteristic2StreamSubscription =
//         _ble.subscribeToCharacteristic(characteristic).listen((data) {
//       // code to handle incoming data
//       _characteristic2StreamController.sink.add(data);
//       notifyListeners();
//     }, onError: (dynamic error) {
//       // code to handle errors
//       print("//? subscribeToCharacteristic error ==> $error ");
//     });
//     notifyListeners();
//   }

//   //3
//   void subscribeToCharacteristic3(String deviceId) {
//     final characteristic = QualifiedCharacteristic(
//         serviceId: ebaniServiceUUID,
//         characteristicId: characteristic3,
//         deviceId: deviceId);
//     characteristic3StreamSubscription =
//         _ble.subscribeToCharacteristic(characteristic).listen((data) {
//       // code to handle incoming data
//       print("//? subscribeToCharacteristic data ==> $data ");
//       _characteristic3StreamController.sink.add(data);
//       notifyListeners();
//     }, onError: (dynamic error) {
//       // code to handle errors
//       print("//? subscribeToCharacteristic error ==> $error ");
//     });
//     notifyListeners();
//   }

//   //4
//   void subscribeToCharacteristic4(String deviceId) {
//     final characteristic = QualifiedCharacteristic(
//         serviceId: ebaniServiceUUID,
//         characteristicId: characteristic4,
//         deviceId: deviceId);
//     characteristic4StreamSubscription =
//         _ble.subscribeToCharacteristic(characteristic).listen((data) {
//       // code to handle incoming data
//       print("//? subscribeToCharacteristic data ==> $data ");
//       _characteristic4StreamController.sink.add(data);
//       notifyListeners();
//     }, onError: (dynamic error) {
//       // code to handle errors
//       print("//? subscribeToCharacteristic error ==> $error ");
//     });
//     notifyListeners();
//   }
// }
