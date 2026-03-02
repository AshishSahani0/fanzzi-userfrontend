class ChannelStatusModel {
  final String id;
  final String type; // IMAGE | VIDEO
  final String mediaUrl;
  final String? caption;

  ChannelStatusModel({
    required this.id,
    required this.type,
    required this.mediaUrl,
    this.caption,
  });

  factory ChannelStatusModel.fromJson(Map<String, dynamic> json) {
    return ChannelStatusModel(
      id: json['id'],
      type: json['type'],
      mediaUrl: json['mediaUrl'],
      caption: json['caption'],
    );
  }
}