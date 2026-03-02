import 'package:frontenduser/auth/config/api_client.dart';
import 'package:frontenduser/channel/model/channel_model.dart';

class ChannelApi {

  static List _extractContent(dynamic data) {
    if (data["content"] != null) return data["content"];
    if (data["data"]?["content"] != null) return data["data"]["content"];
    return [];
  }

  static Future<List<ChannelModel>> getMyChannels() async {
    final res = await ApiClient.dio.get("/api/channels/my");

    print("RAW MY CHANNELS: ${res.data}");

    final list = _extractContent(res.data);

    return list.map((e) => ChannelModel.fromJson(e)).toList();
  }

  static Future<List<ChannelModel>> getJoinedChannels() async {
    final res = await ApiClient.dio.get("/api/channels/joined");

    print("RAW JOINED: ${res.data}");

    final list = _extractContent(res.data);

    return list.map((e) => ChannelModel.fromJson(e)).toList();
  }

  static Future<List<ChannelModel>> getExploreChannels() async {
    final res = await ApiClient.dio.get("/api/channels/explore");

    final list = _extractContent(res.data);

    return list.map((e) => ChannelModel.fromJson(e)).toList();
  }
}