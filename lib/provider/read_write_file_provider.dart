import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

const String? test = "";

class ReadWriteFileProvider extends ChangeNotifier {
  // Variables
  IOSink? _fileOpenedForWrite;
  // Get Methods
  IOSink? get getFileOpenedForWrite => _fileOpenedForWrite;
  // Constructor
  ReadWriteFileProvider();

  // request storage permission
  Future<void> requestStoragePermission() async {
    var status = await Permission.storage.status;

    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  // get path of temporary directory
  Future<String> get _localPath async {
    // await requestStoragePermission();
    // final directory =
    //     await getApplicationDocumentsDirectory(); // getTemporaryDirectory();
    // return directory.path;

    return await requestDownloadFolderPathService() ?? "/sdcard/download/";
  }

  Future<String> getFilePath(String fileNameWithExtension) async {
    final path = await _localPath;
    return '$path/$fileNameWithExtension';
  }

  // create file using _localPath path and fileName with extensions
  Future<File> _localFile(String fileNameWithExtension) async {
    await requestStoragePermission();
    final path = await _localPath;
    return File('$path/$fileNameWithExtension');
  }

  Future<File> writeCharacteristicData(String fileName, String data) async {
    await requestStoragePermission();
    final file = await _localFile(fileName);
    return file.writeAsString(data);
  }

  void openFileForWriteData(String fileName) async {
    await requestStoragePermission();
    final file = await _localFile(fileName);
    _fileOpenedForWrite = file.openWrite();
    notifyListeners();
  }

  Future<void> readFileByFileNameWithExtension(String fileName) async {
    await requestStoragePermission();
    try {
      final file = await _localFile(fileName);
      await saveFileInDownloadFolder(fileName, file);
      // Read the file
      final openedFileForRead = file.openRead();
      openedFileForRead.listen((event) {
        print('//? file data $event ');
      });
    } catch (e) {
      print("//? readFileByFileNameWithExtension error ==>  $e ");
    }
  }

  Future<void> saveFileInDownloadFolder(
      String fileNameWithExtension, File characteristicFile) async {
    String? path = await requestDownloadFolderPathService();
    File file = File('$path/$fileNameWithExtension');
    file = characteristicFile;
    file.createSync();
  }

  Future<String?> requestDownloadFolderPathService() async {
    var _permissionStatus = await Permission.storage.status;
    if (_permissionStatus == PermissionStatus.granted) {
      if (Platform.isAndroid) {
        return "/sdcard/download/";
      } else {
        return (await getApplicationDocumentsDirectory()).path;
      }
    } else if (_permissionStatus == PermissionStatus.permanentlyDenied) {
      return null;
    }
    return null;
  }

  Future<void> closeOpenedFile() async {
    await requestStoragePermission();
    if (_fileOpenedForWrite != null) {
      await _fileOpenedForWrite!.close();
      _fileOpenedForWrite = null;
      notifyListeners();
    }
  }
}
