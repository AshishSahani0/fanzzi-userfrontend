class ChannelSubscriberModel {
  final String userId;
  final String userName;
  final String? profileImageUrl;

  ChannelSubscriberModel({
    required this.userId,
    required this.userName,
    this.profileImageUrl,
  });

  factory ChannelSubscriberModel.fromJson(Map<String, dynamic> json) {
    return ChannelSubscriberModel(
      userId: json["userId"],
      userName: json["userName"] ?? "User",
      profileImageUrl: json["profileImageUrl"],
    );
  }
}