import 'dart:io';
import 'package:dio/dio.dart';
import 'package:frontenduser/auth/config/api_client.dart';
import 'media_model.dart';
import 'post_model.dart';

class PostApi {

  // =====================================================
  // CREATE POST
  // =====================================================
  static Future<PostModel> createPost({
    required String channelId,
    required String text,
    required List<MediaModel> media,
    required String type,
    int price = 0,
  }) async {

    final res = await ApiClient.dio.post(
      "/api/channels/$channelId/posts",
      data: {
        "text": text,
        "attachments": media.map((e) => e.toJson()).toList(),
        "type": type,
        "price": price,
      },
    );

    return PostModel.fromJson(res.data);
  }

  // =====================================================
  // GET POSTS
  // =====================================================
  static Future<List<PostModel>> getPosts(
    String channelId, {
    DateTime? before,
  }) async {

    final res = await ApiClient.dio.get(
      "/api/channels/$channelId/posts",
      queryParameters:
          before == null ? null : {"before": before.toIso8601String()},
    );

    return (res.data as List)
        .map((e) => PostModel.fromJson(e))
        .toList();
  }

  // =====================================================
  // 🔓 UNLOCK POST
  // =====================================================
  static Future<void> unlockPost(String postId) async {
    try {
      await ApiClient.dio.post(
        "/api/posts/$postId/unlock",
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception("NOT_ENOUGH_STARS");
      }
      rethrow;
    }
  }

  // =====================================================
  // 📌 CHECK POST STATUS
  // =====================================================
  static Future<bool> getPostStatus(String postId) async {

    final res = await ApiClient.dio.get(
      "/api/posts/$postId/status",
    );

    return res.data["unlocked"] == true;
  }

  // =====================================================
  // MEDIA UPLOAD
  // =====================================================
  static Future<MediaModel> uploadMedia(File file) async {

    final fileName = file.path.split("/").last;
    final mime = _detectMime(fileName);

    final presign = await ApiClient.dio.post(
      "/api/media/post/upload-url",
      queryParameters: {
        "fileName": fileName,
        "contentType": mime,
      },
    );

    final uploadUrl = presign.data["uploadUrl"];
    final key = presign.data["key"];

    final bytes = await file.readAsBytes();

    await Dio().put(
      uploadUrl,
      data: bytes,
      options: Options(headers: {"Content-Type": mime}),
    );

    return MediaModel(
      key: key,
      url: "",
      type: _resolveType(fileName),
    );
  }

  static Future<void> recordView(String postId) async {
    try {
      await ApiClient.dio.post(
        "/api/posts/$postId/view",
      );
    } catch (_) {
      // Silently ignore view errors
      // View tracking should NEVER break UI
    }
  }
// =====================================================
  // 🗑 DELETE SINGLE POST
  // =====================================================

  static Future<void> deletePost(
    String channelId,
    String postId,
  ) async {
    await ApiClient.dio.delete(
      "/api/channels/$channelId/posts/$postId",
    );
  }

  // =====================================================
  // 🗑 DELETE MULTIPLE POSTS
  // =====================================================

  static Future<void> deleteMultiple(
  String channelId,
  List<String> postIds,
) async {
  if (postIds.isEmpty) return;

  await ApiClient.dio.post(
    "/api/channels/$channelId/posts/bulk-delete",
    data: postIds,
    options: Options(
      contentType: Headers.jsonContentType, 
    ),
  );
}

static Future<PostModel> editPost({
  required String channelId,
  required String postId,
  String? text,
  List<MediaModel>? media,
  String? type,
  int? price,
}) async {

  final Map<String, dynamic> body = {};

  if (text != null) body["text"] = text;

  if (media != null) {
    body["attachments"] = media
        .where((m) => m.key.isNotEmpty)
        .map((m) => {
              "key": m.key,
              "type": m.type,
            })
        .toList();
  }

  if (type != null) body["type"] = type;
  if (price != null) body["price"] = price;

  final res = await ApiClient.dio.put(
    "/api/channels/$channelId/posts/$postId",
    data: body,
  );

  return PostModel.fromJson(res.data);
}


  

  // =====================================================
  // MIME DETECTION
  // =====================================================
  static String _detectMime(String name) {
    final e = name.toLowerCase();

    if (e.endsWith(".png")) return "image/png";
    if (e.endsWith(".webp")) return "image/webp";
    if (e.endsWith(".jpg") || e.endsWith(".jpeg")) return "image/jpeg";

    if (e.endsWith(".mp4")) return "video/mp4";
    if (e.endsWith(".webm")) return "video/webm";

    if (e.endsWith(".mp3")) return "audio/mpeg";
    if (e.endsWith(".wav")) return "audio/wav";

    if (e.endsWith(".pdf")) return "application/pdf";

    return "application/octet-stream";
  }

  static String _resolveType(String name) {
    final e = name.toLowerCase();

    if (e.endsWith(".mp4") || e.endsWith(".webm")) return "VIDEO";
    if (e.endsWith(".mp3") || e.endsWith(".wav")) return "AUDIO";
    if (e.endsWith(".pdf") ||
        e.endsWith(".doc") ||
        e.endsWith(".docx")) {
      return "DOCUMENT";
    }

    return "IMAGE";
  }
}