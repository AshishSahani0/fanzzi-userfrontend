class CreateChannelRequest {
  final String name;
  final String? description;
  final String? profileImageKey;
  final String visibility; // PUBLIC / PRIVATE
  final String type;       // FREE / PAID
  final int? monthlyPrice;
  final String? category;
  final String? language;
  final bool? discoverable;

  CreateChannelRequest({
    required this.name,
    this.description,
    this.profileImageKey,
    required this.visibility,
    required this.type,
    this.monthlyPrice,
    this.category,
    this.language,
    this.discoverable,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      "name": name,
      "visibility": visibility,
      "type": type,
    };

    if (description != null) data["description"] = description;
    if (profileImageKey != null) data["profileImageKey"] = profileImageKey;
    if (monthlyPrice != null) data["monthlyPrice"] = monthlyPrice;
    if (category != null) data["category"] = category;
    if (language != null) data["language"] = language;
    if (discoverable != null) data["discoverable"] = discoverable;

    return data;
  }
}