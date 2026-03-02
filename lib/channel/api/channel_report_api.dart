

import 'package:frontenduser/auth/config/api_client.dart';

class ChannelReportApi {
  static Future<void> reportChannel(
    String channelId,
    String reason,
    String description,
  ) async {
    await ApiClient.dio.post(
      "/api/channels/$channelId/reports",
      data: {
        "reason": reason,
        "description": description,
      },
    );
  }
}