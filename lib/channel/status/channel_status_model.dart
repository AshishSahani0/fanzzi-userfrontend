import 'package:frontenduser/channel/status/views/channel_status_view_model.dart';

class ChannelStatusModel {

  final String id;
  final String type;
  final String? text;
  final List<String> mediaUrls;

  final int viewCount;
  final List<ChannelStatusViewModel> viewerPreview;

  final DateTime? createdAt;
  final DateTime? expiresAt;

  bool viewed = false;

  ChannelStatusModel({
    required this.id,
    required this.type,
    this.text,
    required this.mediaUrls,
    required this.viewCount,
    required this.viewerPreview,
    this.createdAt,
    this.expiresAt,
  });

  factory ChannelStatusModel.fromJson(Map<String, dynamic> json) {
    return ChannelStatusModel(
      id: json["id"] ?? "",
      type: json["type"] ?? "",
      text: json["text"],
      mediaUrls: List<String>.from(json["mediaUrls"] ?? []),
      viewCount: json["viewCount"] ?? 0,
      viewerPreview: (json["viewerPreview"] ?? [])
          .map<ChannelStatusViewModel>(
              (e) => ChannelStatusViewModel.fromJson(e))
          .toList(),
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : null,
      expiresAt: json["expiresAt"] != null
          ? DateTime.parse(json["expiresAt"])
          : null,
    );
  }
}