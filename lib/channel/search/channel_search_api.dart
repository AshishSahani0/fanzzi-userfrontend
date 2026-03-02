import '../../auth/config/api_client.dart';
import '../model/channel_model.dart';

class ChannelSearchApi {
  static Future<Map<String, List<ChannelModel>>> searchChannels(
      String query) async {

    final res = await ApiClient.dio.get(
      "/api/channels/search",
      queryParameters: {"q": query},
    );

    final data = res.data as Map<String, dynamic>;

    final joinedData = data["joined"];
    final publicData = data["public"];

    final joinedList = (joinedData != null &&
            joinedData["content"] is List)
        ? (joinedData["content"] as List)
            .map((e) => ChannelModel.fromJson(e))
            .toList()
        : <ChannelModel>[];

    final publicList = (publicData != null &&
            publicData["content"] is List)
        ? (publicData["content"] as List)
            .map((e) => ChannelModel.fromJson(e))
            .toList()
        : <ChannelModel>[];

    return {
      "joined": joinedList,
      "public": publicList,
    };
  }
}