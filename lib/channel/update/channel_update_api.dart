import 'package:frontenduser/channel/update/update_channel_request.dart';

import '../../auth/config/api_client.dart';


/// ======================================================
/// CHANNEL UPDATE API
/// ======================================================
/// Owner-only channel modifications
class ChannelUpdateApi {

  /// Update channel info/settings
  static Future<void> updateChannel(
    String channelId,
    UpdateChannelRequest req,
  ) async {
    await ApiClient.dio.put(
      "/api/channels/$channelId",
      data: req.toJson(),
    );
  }
}