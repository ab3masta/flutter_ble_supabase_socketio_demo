import 'package:flutter/material.dart';
import 'package:flutter_ble_supabase_socketio_demo/provider/appwrite_provider.dart';
import 'package:flutter_ble_supabase_socketio_demo/provider/ble_provider.dart';
import 'package:flutter_ble_supabase_socketio_demo/provider/read_write_file_provider.dart';
import 'package:provider/provider.dart';

// global providers
class ProviderConsumer extends StatelessWidget {
  const ProviderConsumer({
    Key? key,
    required this.builder,
  }) : super(key: key);
  final Widget Function(
    BuildContext context,
    AppwriteProvider appwriteProvider,
    BLEProvider bLEProvider,
  ) builder;

  @override
  Widget build(BuildContext context) {
    return Consumer<BLEProvider>(
      builder: (_, bLEProvider, __) {
        return Consumer<AppwriteProvider>(
          builder: (_, appwriteProvider, __) {
            return Consumer<ReadWriteFileProvider>(
              builder: (_, readWriteFileProvider, __) {
                return builder(context, appwriteProvider, bLEProvider);
              },
            );
          },
        );
      },
    );
  }
}
