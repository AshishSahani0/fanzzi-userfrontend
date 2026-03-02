import '../../auth/config/api_client.dart';

class ChannelJoinApi {

  static Future<void> joinByChannelId(String channelId) async {
    await ApiClient.dio.post("/api/channels/join/$channelId");
  }

  // Keep these ONLY for deep link usage
  static Future<void> joinBySlug(String slug) async {
    await ApiClient.dio.post("/api/channels/join/slug/$slug");
  }

  static Future<void> joinByToken(String token) async {
    await ApiClient.dio.post("/api/channels/join/invite/$token");
  }
}