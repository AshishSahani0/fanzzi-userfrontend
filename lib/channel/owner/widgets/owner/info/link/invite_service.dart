import 'package:frontenduser/auth/config/api_client.dart';
import 'package:frontenduser/channel/model/channel_model.dart';

class InviteService {
  static Future<void> sendToChannel({
    required String targetChannelId,
    required ChannelModel inviteChannel,
  }) async {
    await ApiClient.dio.post(
      "/api/channels/invite/send",
      data: {
        "targetChannelId": targetChannelId,
        "inviteChannelId": inviteChannel.id,
      },
    );
  }
}