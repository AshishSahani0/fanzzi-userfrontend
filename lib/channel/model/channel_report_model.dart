class ChannelReportModel {
  final String reason;
  final String description;
  final DateTime reportedAt;
  final String reportedByName;
  final String? reportedByAvatar;

  ChannelReportModel({
    required this.reason,
    required this.description,
    required this.reportedAt,
    required this.reportedByName,
    this.reportedByAvatar,
  });

  factory ChannelReportModel.fromJson(Map<String, dynamic> json) {
    return ChannelReportModel(
      reason: json["reason"],
      description: json["description"] ?? "",
      reportedAt: DateTime.parse(json["reportedAt"]).toLocal(),
      reportedByName: json["reportedByName"] ?? "User",
      reportedByAvatar: json["reportedByAvatar"],
    );
  }
}