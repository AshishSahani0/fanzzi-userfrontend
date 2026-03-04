import '../../auth/config/api_client.dart';
import '../model/channel_model.dart';

class ChannelJoinApi {

  static Future<ChannelModel> joinByChannelId(String channelId) async {
    final response =
        await ApiClient.dio.post("/api/channels/join/$channelId");

    return ChannelModel.fromJson(response.data);
  }

  // For deep link usage
  static Future<ChannelModel> joinBySlug(String slug) async {
    final response =
        await ApiClient.dio.post("/api/channels/join/slug/$slug");

    return ChannelModel.fromJson(response.data);
  }

  static Future<ChannelModel> joinByToken(String token) async {
    final response =
        await ApiClient.dio.post("/api/channels/join/invite/$token");

    return ChannelModel.fromJson(response.data);
  }
}