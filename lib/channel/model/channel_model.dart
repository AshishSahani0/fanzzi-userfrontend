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
 

  // 🔐 ACCESS FLAGS FROM BACKEND
  final bool owner;
  final bool member;
  final bool subscribed;
  final bool canRead;
  final bool blurred;
  final bool canPost;

  final int? monthlyPrice;
  final bool hasActiveStatus;

  ChannelModel({
    required this.id,
    required this.name,
    this.visibility,
    this.type,
    this.slug,
    this.inviteToken,
    this.profileImageUrl,
    this.inviteLink,
    required this.owner,
    required this.member,
    required this.subscribed,
    required this.canRead,
    required this.blurred,
    required this.canPost,
    this.monthlyPrice,
    this.description,
    this.profileImageKey,
    required this.hasActiveStatus,
    
    

  });

  factory ChannelModel.fromJson(Map<String, dynamic> json) {
    return ChannelModel(
      id: json["id"] ?? "",
      name: json["name"] ?? "",

      visibility: json["visibility"],
      type: json["type"],

      slug: json["slug"],
      inviteToken: json["inviteToken"],
      profileImageKey: json["profileImageKey"],

      profileImageUrl: json["profileImageUrl"],
      inviteLink: json["inviteLink"],

      owner: json["owner"] ?? false,
      member: json["member"] ?? false,
      subscribed: json["subscribed"] ?? false,
      canRead: json["canRead"] ?? false,
      blurred: json["blurred"] ?? false,
      canPost: json["canPost"] ?? false,

      monthlyPrice: json["monthlyPrice"],
      description: json["description"],
      hasActiveStatus: json['hasActiveStatus'] ?? false,
    );
  }

  // 🧠 Convenience helpers (optional but very useful)
  bool get isPaid => type == "PAID";
  bool get isFree => type == "FREE";
  bool get isPublic => visibility == "PUBLIC";
  bool get isPrivate => visibility == "PRIVATE";
  
}