import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:android_id/android_id.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DeviceService {
  static const storage = FlutterSecureStorage();
  static const _key = "device_id";

  static Future<String> getDeviceId() async {

    // ✅ Return saved ID if exists
    String? saved = await storage.read(key: _key);
    if (saved != null) return saved;

    String id;

    if (Platform.isAndroid) {

      // ⭐ REAL ANDROID_ID
      const androidIdPlugin = AndroidId();
      id = await androidIdPlugin.getId() ?? "android-unknown";

    } else if (Platform.isIOS) {

      final info = await DeviceInfoPlugin().iosInfo;
      id = info.identifierForVendor ?? "ios-unknown";

    } else {
      id = "unsupported-device";
    }

    // ✅ Persist so it never changes
    await storage.write(key: _key, value: id);

    return id;
  }
}