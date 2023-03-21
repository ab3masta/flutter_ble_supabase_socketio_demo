import 'package:flutter/material.dart';
import 'package:flutter_ble_supabase_socketio_demo/provider_consumer.dart';
import 'package:flutter_ble_supabase_socketio_demo/ui/home.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderConsumer(builder: ((context, appwriteProvider, bLEProvider) {
      return MaterialApp(
        title: 'Flutter BLE Supabase Socketio Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(),
      );
    }));
  }
}
