class UpdateChannelRequest {
  final String? name;
  final String? description;
  final String? profileImageKey;
  final String? visibility;
  final String? type;
  final int? monthlyPrice;

  //  ADD THESE
  final String? category;
  final String? language;
  final bool? discoverable;
  final bool? isNsfw;

  UpdateChannelRequest({
    this.name,
    this.description,
    this.profileImageKey,
    this.visibility,
    this.type,
    this.monthlyPrice,

    //  ADD THESE
    this.category,
    this.language,
    this.discoverable,
    this.isNsfw,
  });

  Map<String, dynamic> toJson() => {
        if (name != null) "name": name,
        if (description != null) "description": description,
        if (profileImageKey != null) "profileImageKey": profileImageKey,
        if (visibility != null) "visibility": visibility,
        if (type != null) "type": type,
        if (monthlyPrice != null) "monthlyPrice": monthlyPrice,

        // 🔥 ADD THESE
        if (category != null) "category": category,
        if (language != null) "language": language,
        if (discoverable != null) "discoverable": discoverable,
        if (isNsfw != null) "isNsfw": isNsfw,
      };
}