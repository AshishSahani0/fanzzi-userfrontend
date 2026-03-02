import '../../auth/config/api_client.dart';
import '../model/channel_subscriber_model.dart';

class ChannelSubscriberApi {

  /// 💎 PAID channel → List<ChannelSubscriberModel>
  /// 🟢 FREE channel → empty list []
  static Future<List<ChannelSubscriberModel>> getSubscribers(
      String channelId) async {

    final res = await ApiClient.dio.get(
      "/api/channels/$channelId/subscribers",
    );

    // Backend guarantees: always List
    return (res.data as List)
        .map((e) => ChannelSubscriberModel.fromJson(e))
        .toList();
  }

  static Future<int> fetchSubscriberCount(String channelId) async {
    final res = await ApiClient.dio.get(
      "/api/channels/$channelId/subscribers/count",
    );

    return res.data["count"] ?? 0;
  }
}