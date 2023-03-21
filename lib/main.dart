import 'package:flutter/material.dart';
import 'package:flutter_ble_supabase_socketio_demo/app.dart';
import 'package:flutter_ble_supabase_socketio_demo/constants/supabase.dart';
import 'package:flutter_ble_supabase_socketio_demo/provider_scope.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(child: App());
  }
}
