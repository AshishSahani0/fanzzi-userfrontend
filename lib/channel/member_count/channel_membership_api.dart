import '../../auth/config/api_client.dart';

class ChannelMembershipApi {

  static Future<bool> isMember(String channelId) async {
    final res = await ApiClient.dio.get(
      "/api/channels/membership/$channelId",
    );

    return res.data == true;
  }

  static Future<void> leaveChannel(String channelId) async {
  await ApiClient.dio.post(
    "/api/channels/$channelId/leave",
  );
}
}