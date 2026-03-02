import 'dart:io';
import 'package:dio/dio.dart';
import 'package:frontenduser/auth/config/api_client.dart';
import 'package:frontenduser/channel/model/channel_status_model.dart';
// ignore: depend_on_referenced_packages


class ChannelStatusApi {
  static Future<void> uploadStatus({
    required String channelId,
    required File file,
    required String type,
    required String caption,
    required void Function(double) onProgress,
  }) async {
    final form = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path),
      "type": type,
      "caption": caption,
    });

    await ApiClient.dio.post(
      "/api/channels/$channelId/status",
      data: form,
      options: Options(headers: {"Content-Type": "multipart/form-data"}),
      onSendProgress: (sent, total) {
        if (total > 0) onProgress(sent / total);
      },
    );
  }

  static Future<List<ChannelStatusModel>> fetchActive(String channelId) async {
    final res = await ApiClient.dio.get(
      "/api/channels/$channelId/status/active",
    );

    return (res.data as List)
        .map((e) => ChannelStatusModel.fromJson(e))
        .toList();
  }
}
