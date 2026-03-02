import 'package:frontenduser/auth/config/api_client.dart';
import 'package:frontenduser/channel/block/block_channel_model.dart';

class ChannelBlockApi {
  static Future<void> blockChannel(String channelId) async {
    await ApiClient.dio.post("/api/channels/$channelId/block");
  }

  static Future<void> unblockChannel(String channelId) async {
    await ApiClient.dio.delete("/api/channels/$channelId/block");
  }

  static Future<bool> isBlocked(String channelId) async {
    final res =
        await ApiClient.dio.get("/api/channels/$channelId/block");

    return res.data as bool;
  }

  static Future<List<BlockedChannel>> getBlockedChannels() async {
  final res = await ApiClient.dio.get("/api/user/blocked-channels");

  return (res.data as List)
      .map((e) => BlockedChannel.fromJson(e))
      .toList();
}
}