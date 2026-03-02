
import 'package:dio/dio.dart';
import 'package:frontenduser/auth/config/api_client.dart';
import 'package:frontenduser/channel/createpage/create_channel_request.dart';

class ChannelCreateApi {

  static Future<Map<String, dynamic>> createChannel(
    CreateChannelRequest req,
  ) async {

    try {
      final res = await ApiClient.dio.post(
        "/api/channels",
        data: req.toJson(),
      );

      return Map<String, dynamic>.from(res.data);
    } on DioException catch (e) {
      final msg = e.response?.data?["message"] ?? "Channel creation failed";
      throw msg;
    }
  }
}