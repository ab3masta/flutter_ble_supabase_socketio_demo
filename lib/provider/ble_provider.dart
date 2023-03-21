import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:location_permissions/location_permissions.dart';

class BLEProvider extends ChangeNotifier {
  /// Initializing
  ///
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  bool scanStarted = false;
  bool permGranted = false;
  List<DiscoveredDevice> discoveredDevices = [];
  List<Uuid> discoveredCharacteristic = [];
  Uuid? connectedDeviceServiceId;
  String? connectedDeviceDeviceId;

  DeviceConnectionState deviceConnectionState =
      DeviceConnectionState.disconnected;
  // stream subscription
  StreamSubscription? _connectToDeviceStreamSubscription;
  StreamSubscription<DiscoveredDevice>? _scanDeviceStream;
  final StreamController<List<DiscoveredDevice>> _discoveredDeviceController =
      StreamController<List<DiscoveredDevice>>();

  // get Methods
  FlutterReactiveBle get getBLE => _ble;
  bool get getScanStatus => scanStarted;
  List<DiscoveredDevice> get getDiscoveredDevices => discoveredDevices;
  StreamSubscription<DiscoveredDevice>? get getScanDeviceStream =>
      _scanDeviceStream;
  StreamController<List<DiscoveredDevice>> get getDiscoveredDeviceController =>
      _discoveredDeviceController;

  StreamSubscription? get getConnectToDeviceStreamSubscription =>
      _connectToDeviceStreamSubscription;
  DeviceConnectionState get getDeviceConnectionState => deviceConnectionState;
  List<Uuid> get getDiscoveredCharacteristic => discoveredCharacteristic;

  Uuid? get getConnectedDeviceServiceId => connectedDeviceServiceId;
  String? get getConnectedDeviceDeviceId => connectedDeviceDeviceId;

  /// ble provider
  ///
  BLEProvider();

  // Discovering BLE devices
  Future<void> discoverDevices() async {
    // TODO check if bluetooth is on before start scan

    if (!scanStarted) {
      scanStarted = true;
      discoveredCharacteristic = [];
      notifyListeners();

      PermissionStatus permission;
      permission = await LocationPermissions().checkPermissionStatus();

      if (!permGranted && permission != PermissionStatus.granted) {
        if (Platform.isAndroid) {
          permission = await LocationPermissions().requestPermissions();
          if (permission == PermissionStatus.granted) permGranted = true;
        } else if (Platform.isIOS) {
          permGranted = true;
        }
        notifyListeners();
      } else if (permission == PermissionStatus.granted) {
        permGranted = true;
        notifyListeners();
      }

      if (permGranted) {
        _scanDeviceStream =
            _ble.scanForDevices(withServices: []).listen((device) {
          if (device.name != "" &&
              (discoveredDevices
                  .where((element) => element.name == device.name)
                  .isEmpty)) {
            discoveredDevices.add(device);
            _discoveredDeviceController.sink.add(discoveredDevices);
            notifyListeners();
          }
        });
        await Future.delayed(const Duration(seconds: 10), (() {
          _scanDeviceStream!.cancel();
          _discoveredDeviceController.close();
          scanStarted = false;
          notifyListeners();
        }));
      } else {
        scanStarted = false;
        notifyListeners();
      }
    }
  }

  void connectToScannedDevice(String deviceId, Uuid serviceId) {
    discoveredCharacteristic = [];
    connectedDeviceServiceId = serviceId;
    connectedDeviceDeviceId = deviceId;
    notifyListeners();
    _connectToDeviceStreamSubscription = _ble
        .connectToDevice(
      id: deviceId,
      // servicesWithCharacteristicsToDiscover: {serviceId: []},
      connectionTimeout: const Duration(seconds: 10),
    )
        .listen((connectionState) {
      if (deviceConnectionState != connectionState.connectionState) {
        deviceConnectionState = connectionState.connectionState;
        notifyListeners();
      }
      if (connectionState.connectionState == DeviceConnectionState.connected) {
        discoverServices(
          deviceId: deviceId,
        );
      }
      log("//? connected device state ==> $connectionState ");
      // Handle connection state updates
    }, onError: (Object error) {
      // Handle a possible error
      log("//? connected device error ==> $error ");
      // deviceConnectionState = DeviceConnectionState.disconnected;
      // notifyListeners();
    });
  }

  Future<List<Uuid>> discoverServices({
    required String deviceId,
  }) async {
    List<Uuid> characteristicIds = [];
    await _ble.discoverServices(deviceId).then((discoveredService) {
      for (DiscoveredService d in discoveredService) {
        for (DiscoveredCharacteristic discoveredCharacteristic
            in d.characteristics) {
          characteristicIds.add(discoveredCharacteristic.characteristicId);
        }
      }
    });
    discoveredCharacteristic = characteristicIds.toSet().toList();
    notifyListeners();
    return discoveredCharacteristic;
  }
}
