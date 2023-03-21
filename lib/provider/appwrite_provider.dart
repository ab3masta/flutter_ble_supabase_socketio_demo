import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ble_supabase_socketio_demo/constants/appwrite.dart';
import 'package:flutter_ble_supabase_socketio_demo/constants/this_device.dart';
import 'package:uuid/uuid.dart';

class AppwriteProvider extends ChangeNotifier {
  // device ids
  String? _deviceUUID, _deviceNAME, _devicePASSWROD, _deviceEMAILADDRESS;
  final ThisDevice _thisDevice = ThisDevice();
  // Appwrite
  final Client _client = Client();
  Account? _account;
  User? _user;
  Session? _session;
  Storage? _storage;
  bool _isLoggedIn = false;
  // get methods
  Client get client => _client;
  Account? get account => _account;
  User? get user => _user;
  Session? get session => _session;
  bool get isLoggedIn => _isLoggedIn;
  //
  AppwriteProvider() {
    initializer();
  }
  //
  Future<void> initializer() async {
    if (_session != null) return;
    _client
        .setEndpoint(appwriteEndpoint)
        .setProject(appwriteProjectId)
        .setSelfSigned(status: true);
    _account = Account(_client);
    _storage = Storage(_client);
    notifyListeners();

    // update device vars
    _deviceUUID = await _thisDevice.uuid();
    _deviceNAME = await _thisDevice.name();
    _devicePASSWROD = await _thisDevice.password();
    _deviceEMAILADDRESS = await _thisDevice.emailAddress();
    if (_deviceUUID == null ||
        _deviceNAME == null ||
        _devicePASSWROD == null ||
        _deviceEMAILADDRESS == null) {
      throw "Can't get device uuid, name, password, emailAddress to login";
    }
    notifyListeners();
    print("//? createMonitorSession");
    await createMonitorSession();
  }

  //
  Future<void> createMonitorAccount() async {
    if (_isLoggedIn) return;
    try {
      _user = await _account!.create(
          userId: _deviceUUID!,
          email: _deviceEMAILADDRESS!,
          password: _devicePASSWROD!,
          name: _deviceNAME);
      await createMonitorSession();
      if (_user != null) {
        _isLoggedIn = true;
        notifyListeners();
      } else {
        _isLoggedIn = false;
        notifyListeners();
      }
      notifyListeners();
    } on AppwriteException catch (e) {
      print("//? createMonitorAccount ==> erreur $e");
      //show message to user or do other operation based on error as required
      if (e.type == "user_already_exists") {
        await createMonitorSession();
      }
    }
  }

  Future<void> createMonitorSession() async {
    if (_isLoggedIn) return;
    Account account = Account(client);
    try {
      _session = await account.createEmailSession(
        email: _deviceEMAILADDRESS!,
        password: _devicePASSWROD!,
      );
      _user = await _account!.get();
      _isLoggedIn = true;
      notifyListeners();
    } on AppwriteException catch (e) {
      print("//? createMonitorSession ==> erreur $e");
      //show message to user or do other operation based on error as required
      if (e.type == "user_invalid_credentials") {
        await createMonitorAccount();
      }
    }
  }

  //
  Future<void> storeFile(String path) async {
    print("//? appwrite store _storage ==> $_storage");
    if (_storage == null) return;
    try {
      Future result = _storage!.createFile(
        bucketId: '63b6e5731c37c07b808b',
        fileId: Uuid().v1(),
        file: InputFile(
            path: path,
            filename: 'characteristic${DateTime.now().toIso8601String()}.txt'),
      );

      return await result.then((response) {
        print("//? appwrite store file response ==> $response");
      }).catchError((error) {
        print("//? appwrite store file error ${error.response} ");
      });
    } catch (e) {
      print("//? appwrite store file catch error $e ");
    }
  }

  Future<void> logout() async {
    await account!.deleteSessions();
    _user = null;
    _session = null;
    notifyListeners();
  }
}
