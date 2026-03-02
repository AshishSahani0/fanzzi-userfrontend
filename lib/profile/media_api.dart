import 'dart:io';
import 'package:dio/dio.dart';
import 'package:frontenduser/auth/config/api_client.dart';

class MediaApi {

  /// 👤 Upload Profile Image via Presigned URL
  static Future<Map<String, String>> uploadProfileImage(File file) async {

    final mimeType = _getMimeType(file.path);

    // 1️⃣ Get upload URL
    final res = await ApiClient.dio.post(
      "/api/media/profile/upload-url",
      queryParameters: {
        "contentType": mimeType,
      },
      data: {},
    );

    final key = res.data["key"];
    final uploadUrl = res.data["uploadUrl"];

    // 2️⃣ Upload directly to R2 (NO auth header)
    final uploadDio = Dio();

    await uploadDio.put(
      uploadUrl,
      data: await file.readAsBytes(), 
      options: Options(
        headers: {
          "Content-Type": mimeType,
          "Content-Length": await file.length(),
        },
      ),
    );

    return {
      "key": key,
    };
  }

  static String _getMimeType(String path) {
    final lower = path.toLowerCase();

    if (lower.endsWith(".png")) return "image/png";
    if (lower.endsWith(".webp")) return "image/webp";

    return "image/jpeg";
  }
}