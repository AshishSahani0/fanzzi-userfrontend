import 'package:frontenduser/auth/config/api_client.dart';

class ChannelDeleteApi {
  static Future<void> deleteChannel(String channelId) async {
    await ApiClient.dio.delete("/api/channels/$channelId");
  }
}