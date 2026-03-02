class BlockedChannel {
  final String id;
  final String name;
  final String? avatarUrl;

  BlockedChannel({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  factory BlockedChannel.fromJson(Map<String, dynamic> json) {
    return BlockedChannel(
      id: json["id"],
      name: json["name"],
      avatarUrl: json["avatarUrl"],
    );
  }
}