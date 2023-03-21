import 'package:flutter/material.dart';
import 'package:flutter_ble_supabase_socketio_demo/provider/appwrite_provider.dart';
import 'package:flutter_ble_supabase_socketio_demo/provider/ble_provider.dart';
import 'package:flutter_ble_supabase_socketio_demo/provider/read_write_file_provider.dart';
import 'package:provider/provider.dart';

// global providers
class ProviderScope extends StatelessWidget {
  const ProviderScope({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppwriteProvider>(
          create: (context) => AppwriteProvider(),
        ),
        ChangeNotifierProvider<BLEProvider>(
          create: (context) => BLEProvider(),
        ),
        ChangeNotifierProvider<ReadWriteFileProvider>(
          create: (context) => ReadWriteFileProvider(),
        ),
      ],
      child: child,
    );
  }
}
