import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:platform_device_id/platform_device_id.dart';

class ThisDevice {
  Future<String?> uuid() async {
    if (kIsWeb) {
      throw UnsupportedError(
        'This project is only use for android - ',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        String? createdAndroidDeviceUUID =
            await createDeviceUUIDFromAndroidDeviceInfo();
        return createdAndroidDeviceUUID;
      case TargetPlatform.iOS:
        return throw UnsupportedError(
          'This project is only use for android',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError('This project is only use for android');
      case TargetPlatform.windows:
        throw UnsupportedError('This project is only use for android ');
      case TargetPlatform.linux:
        throw UnsupportedError('This project is only use for android');
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  Future<String?> name() async {
    if (kIsWeb) {
      throw UnsupportedError(
        'This project is only use for android - ',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        String? createdAndroidDeviceModelName =
            await createDeviceModelNameFromAndroidDeviceInfo();
        return createdAndroidDeviceModelName;
      case TargetPlatform.iOS:
        return throw UnsupportedError(
          'This project is only use for android',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError('This project is only use for android');
      case TargetPlatform.windows:
        throw UnsupportedError('This project is only use for android ');
      case TargetPlatform.linux:
        throw UnsupportedError('This project is only use for android');
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  Future<String?> password() async {
    if (kIsWeb) {
      throw UnsupportedError(
        'This project is only use for android - ',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        String? createdPasswordOfDevice =
            await createDevicePasswordFromAndroidDeviceInfo();
        return createdPasswordOfDevice;
      case TargetPlatform.iOS:
        return throw UnsupportedError(
          'This project is only use for android',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError('This project is only use for android');
      case TargetPlatform.windows:
        throw UnsupportedError('This project is only use for android ');
      case TargetPlatform.linux:
        throw UnsupportedError('This project is only use for android');
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  //
  Future<String?> emailAddress() async {
    if (kIsWeb) {
      throw UnsupportedError(
        'This project is only use for android - ',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        String? createdEmailAddressOfDevice =
            await createEmailAddressFromAndroidDeviceInfo();
        return createdEmailAddressOfDevice;
      case TargetPlatform.iOS:
        return throw UnsupportedError(
          'This project is only use for android',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError('This project is only use for android');
      case TargetPlatform.windows:
        throw UnsupportedError('This project is only use for android ');
      case TargetPlatform.linux:
        throw UnsupportedError('This project is only use for android');
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
}

//
Future<String?> createDeviceUUIDFromAndroidDeviceInfo() async {
  try {
    String? deviceId = await PlatformDeviceId.getDeviceId;
    if (deviceId == null) {
      throw 'device Id is null';
    }
    String deviceUuid =
        "organizationName-0101-2018-${deviceId.substring(0, 4)}-${deviceId.substring(4)}";
    return deviceUuid.trim();
  } on PlatformException {
    throw 'Failed to get device id.';
  }
}

//
Future<String?> createDeviceModelNameFromAndroidDeviceInfo() async {
  try {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (androidInfo.model == null) {
      throw 'device model name is null';
    }
    String deviceModelName = "organizationName-${androidInfo.model}";
    return deviceModelName.trim();
  } on PlatformException {
    throw 'Failed to create device model name.';
  }
}

//
Future<String?> createDevicePasswordFromAndroidDeviceInfo() async {
  try {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (androidInfo.board == null ||
        androidInfo.display == null ||
        androidInfo.model == null) {
      throw 'some needed device data are null';
    }
    String devicePassword =
        "organizationName-@organizationName!!@-${androidInfo.board}-${androidInfo.display}-${androidInfo.model}";
    return devicePassword.trim();
  } on PlatformException {
    throw 'Failed to create device password.';
  }
}

Future<String?> createEmailAddressFromAndroidDeviceInfo() async {
  // e.g. board-@gmail.com  ==> board=full_oppo6750_15331
  try {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (androidInfo.board == null) {
      throw 'device board name is null';
    }
    String deviceEmailAddress = "${androidInfo.board}@gmail.com";
    return deviceEmailAddress.trim();
  } on PlatformException {
    throw 'Failed to create device email address.';
  }
}
