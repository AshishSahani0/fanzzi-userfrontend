
import 'package:frontenduser/auth/config/api_client.dart';
import 'package:frontenduser/channel/post/post_model.dart';

class PinnedApi {

  // ===============================================
  // 📌 1. Get Banner (collapsed view)
  // ===============================================
  static Future<Map<String, dynamic>?> getPinnedBanner(
    String channelId,
  ) async {
    try {
      final res = await ApiClient.dio.get(
        "/api/channels/$channelId/pinned/banner",
      );

      final data = res.data;

      if (data == null || data["count"] == 0) {
        return null;
      }

      return Map<String, dynamic>.from(data);
    } catch (_) {
      return null;
    }
  }

  // ===============================================
  // 📌 2. Get All Pinned Posts
  // ===============================================
  static Future<List<PostModel>> getAllPinned(
    String channelId,
  ) async {
    final res = await ApiClient.dio.get(
      "/api/channels/$channelId/pinned",
    );

    final data = Map<String, dynamic>.from(res.data);

    final List posts = data["posts"] ?? [];

    return posts
        .map((e) => PostModel.fromJson(e))
        .toList();
  }

  // ===============================================
  // 📌 3. Pin Post
  // ===============================================
  static Future<void> pinPost(
    String channelId,
    String postId,
  ) async {
    await ApiClient.dio.post(
      "/api/channels/$channelId/posts/$postId/pin",
    );
  }

  // ===============================================
  // 📌 4. Unpin Post
  // ===============================================
  static Future<void> unpinPost(
    String channelId,
    String postId,
  ) async {
    await ApiClient.dio.delete(
      "/api/channels/$channelId/posts/$postId/pin",
    );
  }
}