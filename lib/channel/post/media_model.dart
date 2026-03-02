class MediaModel {
  final String key;
  final String url;        // signed URL from backend
  final String? previewUrl; // optional unpaid preview
  final String type;

  // 🔥 NEW: for local preview before refresh
  final String? localPath;

  MediaModel({
    required this.key,
    required this.url,
    required this.type,
    this.previewUrl,
    this.localPath,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      key: json["key"] ?? "",
      url: json["url"] ?? "",
      previewUrl: json["previewUrl"],
      type: json["type"] ?? "IMAGE",
    );
  }

  MediaModel copyWith({
  String? key,
  String? url,
  String? previewUrl,
  String? type,
  String? localPath,
}) {
  return MediaModel(
    key: key ?? this.key,
    url: url ?? this.url,
    previewUrl: previewUrl ?? this.previewUrl,
    type: type ?? this.type,
    localPath: localPath ?? this.localPath,
  );
}

  // IMPORTANT: never send url or localPath to backend
  Map<String, dynamic> toJson() => {
        "key": key,
        "type": type,
      };



}