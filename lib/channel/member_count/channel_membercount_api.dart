import '../../auth/config/api_client.dart';

class ChannelMemberCountApi {

  static Future<int> fetch(String channelId) async {
    final res = await ApiClient.dio.get(
      "/api/channels/$channelId/members/count",
    );

    return res.data["count"] ?? 0;
  }
}