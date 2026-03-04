class ChannelStatusViewModel {
  final String viewerId;
  final String viewerName;
  final String? viewerProfile;
  final DateTime viewedAt;

  ChannelStatusViewModel({
    required this.viewerId,
    required this.viewerName,
    required this.viewerProfile,
    required this.viewedAt,
  });

  factory ChannelStatusViewModel.fromJson(Map<String, dynamic> json) {
    return ChannelStatusViewModel(
      viewerId: json["viewerId"] ?? "",
      viewerName: json["viewerName"] ?? "User",
      viewerProfile: json["viewerProfile"],
      viewedAt: json["viewedAt"] != null
          ? DateTime.parse(json["viewedAt"])
          : DateTime.now(),
    );
  }
}