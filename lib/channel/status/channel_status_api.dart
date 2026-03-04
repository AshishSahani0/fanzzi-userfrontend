import 'dart:io';
import 'package:dio/dio.dart';
import 'package:frontenduser/auth/config/api_client.dart';
import 'package:frontenduser/channel/status/views/channel_status_view_model.dart';
import 'channel_status_model.dart';

class ChannelStatusApi {
  static Future<void> uploadStatus({
    required String channelId,
    required File file,
    required String type,
    required String caption,
    required void Function(double) onProgress,
  }) async {
    final fileName = file.path.split('/').last;

    final uploadRes = await ApiClient.dio.post(
      "/api/channels/$channelId/status/upload-url",
      queryParameters: {
        "fileName": fileName,
        "contentType": _resolveContentType(fileName),
      },
    );

    final uploadUrl = uploadRes.data["uploadUrl"];
    final key = uploadRes.data["key"];

    final bytes = await file.readAsBytes();

    await Dio().put(
      uploadUrl,
      data: Stream.fromIterable([bytes]),
      options: Options(
        headers: {
          "Content-Type": _resolveContentType(fileName),
          "Content-Length": bytes.length,
        },
      ),
      onSendProgress: (sent, total) {
        if (total > 0) onProgress(sent / total);
      },
    );

    await ApiClient.dio.post(
      "/api/channels/$channelId/status",
      data: {
        "type": type,
        "text": caption.isEmpty ? null : caption,
        "media": [
          {"mediaType": type, "mediaKey": key, "duration": null},
        ],
      },
    );
  }

  static Future<List<ChannelStatusModel>> fetchActive(
      String channelId) async {

    final res = await ApiClient.dio.get(
      "/api/channels/$channelId/status/active",
      queryParameters: {"page": 0, "size": 20},
    );

    final List content = res.data["content"] ?? [];

    return content
        .map((e) => ChannelStatusModel.fromJson(e))
        .toList();
  }

  static Future<void> markViewed(
      String channelId,
      String statusId,
      ) async {

    await ApiClient.dio.post(
        "/api/channels/$channelId/status/$statusId/view"
    );
  }


  static Future<int> getViewCount(
    String channelId,
    String statusId,
) async {
  final res = await ApiClient.dio.get(
      "/api/channels/$channelId/status/$statusId/views/count");

  return res.data;
}

static Future<List<ChannelStatusViewModel>> getViewers(
      String channelId,
      String statusId,
      ) async {

    final res = await ApiClient.dio.get(
      "/api/channels/$channelId/status/$statusId/views",
      queryParameters: {
        "page": 0,
        "size": 50,
      },
    );

    final List content = res.data["content"] ?? [];

    return content
        .map((e) => ChannelStatusViewModel.fromJson(e))
        .toList();
  }

  static String _resolveContentType(String name) {
    if (name.endsWith(".mp4")) return "video/mp4";
    if (name.endsWith(".png")) return "image/png";
    if (name.endsWith(".webp")) return "image/webp";
    return "image/jpeg";
  }
}
