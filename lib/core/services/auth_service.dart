// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:frontenduser/auth/config/api_client.dart';
import 'package:frontenduser/core/services/session_service.dart';
import 'package:frontenduser/core/device/device_service.dart';

import '../../dashboard/user_dashboard.dart';
import '../../auth/pages/start_page.dart';

class AuthService {
  static const storage = FlutterSecureStorage();

  // Backend Login
  static Future<void> backendLogin(
  String firebaseToken,
  String countryCode,
  BuildContext context,
) async {
  try {
    final deviceId =
        await DeviceService.getDeviceId();

    final res = await ApiClient.dio.post(
      "/auth/user/login",
      options: Options(
        headers: {
          "Authorization": "Bearer $firebaseToken",
          "X-Device-Id": deviceId,
          "X-Country-Code": countryCode,
        },
      ),
    );

    await SessionService.saveToken(
      res.data["accessToken"],
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const UserDashboard(),
      ),
    );
  } catch (e) {
    throw Exception(e.toString());
  }
}

  // Logout
  static Future<void> logout(BuildContext context) async {
  try {
    final deviceId =
        await DeviceService.getDeviceId();

    await ApiClient.dio.post(
      "/auth/user/logout",
      options: Options(
        headers: {"X-Device-Id": deviceId},
      ),
    );

  } catch (_) {}

  await SessionService.clearAll();
  await ApiClient.cookieJar.deleteAll();

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) => const StartPage(),
    ),
    (_) => false,
  );
}
}