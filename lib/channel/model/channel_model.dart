class ChannelModel {
  final String id;
  final String name;

  final String? visibility; // PUBLIC / PRIVATE
  final String? type;       // FREE / PAID

  final String? slug;
  final String? inviteToken;

  final String? profileImageUrl;
  final String? profileImageKey;
  final String? inviteLink;

  final String? description;

  // 🔐 ACCESS FLAGS
  final bool owner;
  final bool member;
  final bool subscribed;
  final bool canRead;
  final bool blurred;
  final bool canPost;
  final bool joined;

  final bool hasActiveStatus;

  final int? monthlyPrice;
  final int memberCount;   // ✅ NEW (important)

  ChannelModel({
    required this.id,
    required this.name,
    this.visibility,
    this.type,
    this.slug,
    this.inviteToken,
    this.profileImageUrl,
    this.profileImageKey,
    this.inviteLink,
    this.description,
    required this.owner,
    required this.member,
    required this.subscribed,
    required this.canRead,
    required this.blurred,
    required this.canPost,
    required this.joined,
    required this.hasActiveStatus,
    this.monthlyPrice,
    required this.memberCount,
  });

  factory ChannelModel.fromJson(Map<String, dynamic> json) {
    return ChannelModel(
      id: json["id"] ?? "",
      name: json["name"] ?? "",

      visibility: json["visibility"],
      type: json["type"],

      slug: json["slug"],
      inviteToken: json["inviteToken"],

      profileImageUrl: json["profileImageUrl"],
      profileImageKey: json["profileImageKey"],
      inviteLink: json["inviteLink"],

      description: json["description"],

      owner: json["owner"] ?? false,
      member: json["member"] ?? false,
      subscribed: json["subscribed"] ?? false,
      canRead: json["canRead"] ?? false,
      blurred: json["blurred"] ?? false,
      canPost: json["canPost"] ?? false,
      joined: json["joined"] ?? false,
      hasActiveStatus: json["hasActiveStatus"] ?? false,

      monthlyPrice: (json["monthlyPrice"] is num)
          ? (json["monthlyPrice"] as num).toInt()
          : null,

      memberCount: (json["memberCount"] is num)
          ? (json["memberCount"] as num).toInt()
          : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "visibility": visibility,
      "type": type,
      "slug": slug,
      "inviteToken": inviteToken,
      "profileImageUrl": profileImageUrl,
      "profileImageKey": profileImageKey,
      "inviteLink": inviteLink,
      "description": description,
      "owner": owner,
      "member": member,
      "subscribed": subscribed,
      "canRead": canRead,
      "blurred": blurred,
      "canPost": canPost,
      "joined": joined,
      "hasActiveStatus": hasActiveStatus,
      "monthlyPrice": monthlyPrice,
      "memberCount": memberCount,
    };
  }

  ChannelModel copyWith({
  String? name,
  bool? owner,
  bool? member,
  bool? subscribed,
  bool? canRead,
  bool? blurred,
  bool? canPost,
  bool? joined,
  bool? hasActiveStatus,
  int? monthlyPrice,
  int? memberCount,
}) {
  return ChannelModel(
    id: id,
    name: name ?? this.name,
    visibility: visibility,
    type: type,
    slug: slug,
    inviteToken: inviteToken,
    profileImageUrl: profileImageUrl,
    profileImageKey: profileImageKey,
    inviteLink: inviteLink,
    description: description,
    owner: owner ?? this.owner,
    member: member ?? this.member,
    subscribed: subscribed ?? this.subscribed,
    canRead: canRead ?? this.canRead,
    blurred: blurred ?? this.blurred,
    canPost: canPost ?? this.canPost,
    joined: joined ?? this.joined,
    hasActiveStatus: hasActiveStatus ?? this.hasActiveStatus,
    monthlyPrice: monthlyPrice ?? this.monthlyPrice,
    memberCount: memberCount ?? this.memberCount,
  );
}

  // 🧠 Helpers
  bool get isPaid => type == "PAID";
  bool get isFree => type == "FREE";
  bool get isPublic => visibility == "PUBLIC";
  bool get isPrivate => visibility == "PRIVATE";
}