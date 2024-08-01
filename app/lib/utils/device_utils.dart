import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

Future<String> getDeviceId() async {
  final deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id; // Unique ID on Android, fallback to 'unknown'
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    return iosInfo.identifierForVendor ??
        "NO_DEVICE_ID"; // Unique ID on iOS, fallback to 'unknown'
  } else {
    return "NO_DEVICE_ID";
  }
}
