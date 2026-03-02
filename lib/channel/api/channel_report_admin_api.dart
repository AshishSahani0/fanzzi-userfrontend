

import 'package:frontenduser/auth/config/api_client.dart';
import 'package:frontenduser/channel/model/channel_report_model.dart';

class ChannelReportAdminApi {
  static Future<List<ChannelReportModel>> fetchReports(
    String channelId,
  ) async {
    final res = await ApiClient.dio.get(
      "/api/channels/$channelId/reports",
    );

    final List list = res.data as List;

    return list
        .map((e) => ChannelReportModel.fromJson(e))
        .toList();
  }

  static Future<int> fetchReportCount(String channelId) async {
    final res = await ApiClient.dio.get(
      "/api/channels/$channelId/reports/count",
    );
    return res.data["count"] as int;
  }
}