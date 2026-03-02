import 'media_model.dart';

class PostModel {
  final String id;
  final String text;
  final List<MediaModel> media;
  final String type;
  final int price;
  final DateTime createdAt;
  final int views;
  final bool isUnlocked;
  final bool edited;
  final DateTime? updatedAt;

  bool get isPaid => type == "PAID";

  final bool pinned;
  final DateTime? pinnedAt;

  /// Optional helper for formatted views (1.2K, 3.4M)
  String get formattedViews {
    if (views >= 1000000) {
      return "${(views / 1000000).toStringAsFixed(1)}M";
    } else if (views >= 1000) {
      return "${(views / 1000).toStringAsFixed(1)}K";
    }
    return views.toString();
  }

  PostModel({
    required this.id,
    required this.text,
    required this.media,
    required this.type,
    required this.price,
    required this.createdAt,
    required this.views,
    required this.isUnlocked,
    required this.edited,
    this.updatedAt,
    this.pinned = false,
    this.pinnedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    /// 🔥 Safe createdAt parsing
    DateTime parsedCreatedAt;
    try {
      parsedCreatedAt = json["createdAt"] != null
          ? DateTime.parse(json["createdAt"]).toLocal()
          : DateTime.now();
    } catch (_) {
      parsedCreatedAt = DateTime.now();
    }

    /// 🔥 Safe updatedAt parsing
    DateTime? parsedUpdatedAt;
    try {
      if (json["updatedAt"] != null) {
        parsedUpdatedAt = DateTime.parse(json["updatedAt"]).toLocal();
      }
    } catch (_) {
      parsedUpdatedAt = null;
    }

    /// 🔥 Safe views parsing
    int parsedViews = 0;
    final viewsValue = json["views"];
    if (viewsValue is int) {
      parsedViews = viewsValue;
    } else if (viewsValue is num) {
      parsedViews = viewsValue.toInt();
    }

    /// 🔥 Safe price parsing
    int parsedPrice = 0;
    final priceValue = json["price"];
    if (priceValue is int) {
      parsedPrice = priceValue;
    } else if (priceValue is num) {
      parsedPrice = priceValue.toInt();
    }

    return PostModel(
      id: json["id"] ?? "",
      text: json["text"] ?? "",
      media: (json["attachments"] as List? ?? [])
          .map((e) => MediaModel.fromJson(e))
          .toList(),
      type: json["type"] ?? "FREE",
      price: parsedPrice,
      createdAt: parsedCreatedAt,
      views: parsedViews,
      isUnlocked: json["isUnlocked"] ?? false,
      edited: json["edited"] ?? false,
      pinned: json["pinned"] ?? false,
      pinnedAt: json["pinnedAt"] != null
          ? DateTime.parse(json["pinnedAt"])
          : null,
      updatedAt: parsedUpdatedAt, // ✅ FIXED
    );
  }

  PostModel copyWith({
    String? id,
    String? text,
    List<MediaModel>? media,
    String? type,
    int? price,
    DateTime? createdAt,
    int? views,
    bool? isUnlocked,
    bool? edited,
    DateTime? updatedAt,
    bool? pinned,
    DateTime? pinnedAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      text: text ?? this.text,
      media: media ?? this.media,
      type: type ?? this.type,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      views: views ?? this.views,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      edited: edited ?? this.edited,
      updatedAt: updatedAt ?? this.updatedAt,
      pinned: pinned ?? this.pinned,
      pinnedAt: pinnedAt ?? this.pinnedAt,
    );
  }
}
