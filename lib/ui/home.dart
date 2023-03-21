import 'package:flutter/material.dart';
import 'package:flutter_ble_supabase_socketio_demo/provider/appwrite_provider.dart';
import 'package:flutter_ble_supabase_socketio_demo/provider/ble_provider.dart';
import 'package:flutter_ble_supabase_socketio_demo/provider/read_write_file_provider.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const menuItems = <String>["Scan BLE Devices"];
  // providers

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Provider.of<AppwriteProvider>(context, listen: false).initializer();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appwriteProvider =
        Provider.of<AppwriteProvider>(context, listen: true);
    final bLEProvider = Provider.of<BLEProvider>(context, listen: true);

    final List<PopupMenuItem<String>> _popUpMenuItems = menuItems
        .map((String value) => PopupMenuItem<String>(
              value: value,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    value,
                    style: Theme.of(context).textTheme.subtitle2,
                  )
                ],
              ),
            ))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Demo",
        ),
        actions: [
          PopupMenuButton<String>(
              onSelected: (String value) {
                if (value == "Scan BLE Devices") {
                  bLEProvider.discoverDevices();
                }
              },
              itemBuilder: (BuildContext context) => _popUpMenuItems),
        ],
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: StreamBuilder<List<DiscoveredDevice>?>(
                  stream: bLEProvider.getDiscoveredDeviceController.stream,
                  builder: ((context, snapshot) {
                    List<DiscoveredDevice>? scannedDevices = snapshot.data;
                    print("//? scanned device ==> $scannedDevices ");
                    if (scannedDevices != null) {
                      return ListView.builder(
                          itemCount: scannedDevices.length,
                          itemBuilder: ((context, index) {
                            return Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.bluetooth,
                                    color: Colors.blue[800],
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(scannedDevices[index].name,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                        Text(scannedDevices[index].id),
                                        Row(
                                          children: [],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          bLEProvider.connectToScannedDevice(
                                              scannedDevices[index].id,
                                              scannedDevices[index]
                                                  .serviceUuids[0]);
                                        },
                                        child: Text(bLEProvider
                                                    .getDeviceConnectionState ==
                                                DeviceConnectionState.connecting
                                            ? "Connecting..."
                                            : bLEProvider
                                                        .getDeviceConnectionState ==
                                                    DeviceConnectionState
                                                        .connected
                                                ? "Connected"
                                                : "Connect"),
                                        style: ElevatedButton.styleFrom(
                                            primary: bLEProvider
                                                        .getDeviceConnectionState ==
                                                    DeviceConnectionState
                                                        .connecting
                                                ? Colors.grey
                                                : bLEProvider
                                                            .getDeviceConnectionState ==
                                                        DeviceConnectionState
                                                            .connected
                                                    ? const Color.fromARGB(
                                                        255, 27, 146, 31)
                                                    : Colors.blue[800]),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }));
                    } else {
                      return Center(
                        child: ElevatedButton(
                            onPressed: () {
                              if (bLEProvider.getDeviceConnectionState !=
                                  DeviceConnectionState.connecting) {
                                bLEProvider.discoverDevices();
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                bLEProvider.getScanStatus
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation(
                                              Colors.white),
                                        ))
                                    : const SizedBox(),
                                const SizedBox(
                                  width: 10,
                                ),
                                const Text("Scan BLE Devices"),
                              ],
                            ),
                            style: ElevatedButton.styleFrom(
                                primary: Colors.blue[800])),
                      );
                    }
                  })),
            ),
            bLEProvider.getDiscoveredCharacteristic.isNotEmpty
                ? Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.all(8.0),
                      decoration: const BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: ListView(
                        children:
                            bLEProvider.getDiscoveredCharacteristic.map((e) {
                          return StreamBuilder<List<int>>(
                              stream: bLEProvider.getBLE
                                  .subscribeToCharacteristic(
                                      QualifiedCharacteristic(
                                          serviceId: bLEProvider
                                              .getConnectedDeviceServiceId!,
                                          characteristicId: e,
                                          deviceId: bLEProvider
                                              .getConnectedDeviceDeviceId!)),
                              builder: ((context, snapshot) {
                                if (snapshot.data != null) {
                                  return Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Column(
                                      children: [
                                        Text.rich(
                                          TextSpan(
                                            children: [
                                              const TextSpan(
                                                  text: 'Characteristic ',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                              TextSpan(
                                                text: '$e',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                              const TextSpan(
                                                  text: ' data : ',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text(
                                            " ${snapshot.data!.map((e) => String.fromCharCode(e)).toString()} ",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return const SizedBox();
                                }
                              }));
                        }).toList(),
                      ),
                    ),
                  )
                : const SizedBox(),
            const Divider(
              height: 0,
              color: Colors.black,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "BLE : ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            bLEProvider.getScanStatus
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text("searching",
                                          style: TextStyle(fontSize: 15)),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      SizedBox(
                                        height: kToolbarHeight * 0.2,
                                        width: kToolbarHeight * 0.2,
                                        child: CircularProgressIndicator(
                                          color: Colors.black,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text("scanning paused",
                                    style: TextStyle(fontSize: 15)),
                          ],
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "Appwrite : ",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  appwriteProvider.isLoggedIn
                                      ? "connected"
                                      : "disconnected",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: appwriteProvider.isLoggedIn
                                          ? Colors.green
                                          : Colors.red),
                                )
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  "Supabase : ",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "initialized",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green),
                                )
                              ],
                            )
                          ],
                        )
                      ]),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
