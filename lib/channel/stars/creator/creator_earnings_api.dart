import 'package:frontenduser/auth/config/api_client.dart';

class CreatorEarningsApi {

  static Future<Map<String, dynamic>> getSummary() async {
    final res = await ApiClient.dio.get(
      "/api/creator/earnings/summary",
    );

    if (res.data == null) return {};
    return Map<String, dynamic>.from(res.data);
  }

  static Future<List<Map<String, dynamic>>> getChannelEarnings() async {
    final res = await ApiClient.dio.get(
      "/api/creator/earnings/channels",
    );

    final data = res.data;

    if (data == null) return [];

    // ✅ Case 1 — Proper List
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }

    // ✅ Case 2 — Wrapped inside { data: [...] }
    if (data is Map && data["data"] is List) {
      return List<Map<String, dynamic>>.from(data["data"]);
    }

    // ✅ Case 3 — Map of channelId → object
    if (data is Map) {
      return data.values
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    return [];
  }
}