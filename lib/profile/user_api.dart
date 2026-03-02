import 'package:frontenduser/auth/config/api_client.dart';
import 'package:frontenduser/core/services/base_api_service.dart';

class UserApi {

  /// 👤 Get Current User
  static Future<Map<String, dynamic>> getMe() async {
    final res = await ApiClient.dio.get("/api/users/me");

    if (res.data is! Map) {
      throw Exception("Invalid backend response");
    }

    return Map<String, dynamic>.from(res.data);
  }

  /// ✏️ Update Profile
  static Future<void> updateProfile(Map<String, dynamic> data) async {
    await BaseApiService.handleRequest(() async {
      await ApiClient.dio.put("/api/users/me", data: data);
    });
  }
}