import '../../auth/config/api_client.dart';
import '../model/channel_model.dart';

class ChannelSearchApi {

  static Future<List<ChannelModel>> searchPublic(
      String query,
      {int page = 0, int size = 20}) async {

    if (query.trim().isEmpty) return [];

    final res = await ApiClient.dio.get(
      "/api/channels/search/public",
      queryParameters: {
        "q": query.trim(),
        "page": page,
        "size": size,
      },
    );

    final data = res.data;

    if (data == null || data["content"] is! List) {
      return [];
    }

    return (data["content"] as List)
        .map((e) => ChannelModel.fromJson(e))
        .toList();
  }
}