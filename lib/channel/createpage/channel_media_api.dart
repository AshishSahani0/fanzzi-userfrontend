import 'dart:io';
import 'package:dio/dio.dart';
import 'package:frontenduser/auth/config/api_client.dart';

class ChannelMediaApi {

  static Future<String> uploadChannelProfile(File file) async {
    final contentType = _getContentType(file.path);

    if (contentType == "application/octet-stream") {
      throw "Unsupported image format";
    }

    // Step 1: Get presigned URL
    final urlRes = await ApiClient.dio.post(
      "/api/media/channel-profile/upload-url",
      queryParameters: {"contentType": contentType},
    );

    final uploadUrl = urlRes.data["uploadUrl"];
    final key = urlRes.data["key"];

    if (uploadUrl == null || key == null) {
      throw "Invalid upload URL response";
    }

    // Step 2: Upload to S3 directly
    await Dio().put(
      uploadUrl,
      data: file.openRead(),
      options: Options(
        headers: {
          "Content-Type": contentType,
          "Content-Length": await file.length(),
        },
      ),
    );

    return key;
  }

  static String _getContentType(String path) {
    final lower = path.toLowerCase();

    if (lower.endsWith(".png")) return "image/png";
    if (lower.endsWith(".webp")) return "image/webp";
    if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) {
      return "image/jpeg";
    }

    return "application/octet-stream";
  }
}