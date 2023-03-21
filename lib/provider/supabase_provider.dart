import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProvider extends ChangeNotifier {
  // It's handy to then extract the Supabase client in a variable for later uses
  final supabase = Supabase.instance.client;
  SupabaseProvider();

  Future<void> uploadFile(String filePath, String fileName) async {
    try {
      return await supabase.storage
          .from('e-bani')
          .upload(
            fileName,
            File(filePath),
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
              contentType: 'application/csv;charset=UTF-8',
            ),
          )
          .then((value) {
        print("//? supabase upload file value ==> $value");
      });
    } catch (e) {
      print("//? supabase upload file error ==> $e");
    }
  }
}
